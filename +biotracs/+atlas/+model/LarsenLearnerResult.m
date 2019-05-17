% BIOASTER
%> @file		LarsenLearnerResult.m
%> @class		biotracs.atlas.model.LarsenLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef LarsenLearnerResult < biotracs.atlas.model.BaseLearnerResult
     
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = LarsenLearnerResult( varargin )
            this@biotracs.atlas.model.BaseLearnerResult( varargin{:} );
            this.classNameOfElements = {'biotracs.data.model.DataObject'};
            this.set('WeightPaths', biotracs.data.model.DataObject());
            this.set('ProbPaths', biotracs.data.model.DataObject());
            this.set('Theta', biotracs.data.model.DataMatrix());
            this.bindView( biotracs.atlas.view.LarsenLearnerResult );
        end
        
        %-- G --
        
        function W = getWeightData( this )
            W = this.get('Weights').getData();
        end

        function [ selectedVariables ] = getSelectedVariables( this, iNbVarToSelect )
            [pathData, varIndexes] = this.doGetSelectionPaths();

            %retrieve the step at which @a iNbVarToSelect are selected
            nbVarSelected = sum(pathData ~= 0, 1);
            if nargin == 1
                iNbVarToSelect = this.process.getConfig()...
                    .getParamValue('NbVariablesToSelect');
            end            

            if isinf(iNbVarToSelect)
                idx = size(pathData,2);
            else
                idx = find( nbVarSelected >= iNbVarToSelect, 1 );
            end
                
            variableNames = this.get('Weight').getRowNames();
            selectedVariables = biotracs.data.model.DataMatrix( pathData(:,idx), {'Score'}, variableNames(varIndexes) );

            %remove unselected variable
            isSelected = (selectedVariables.data ~= 0);
            selectedVariables = selectedVariables.selectByRowIndexes( isSelected );

            %add variable indices
            varIdx = this.get('Weight').getRowIndexesByName( strcat('^',regexptranslate('escape', selectedVariables.rowNames),'$') );
            t = biotracs.data.model.DataMatrix(varIdx(:), {'VariableIndex'});
          
            selectedVariables = biotracs.atlas.model.SelectedVariableDataMatrix.fromDataMatrix( horzcat( selectedVariables, t ) );
        end
        
        function [ W ] = getWeightPaths( this )
            [ W ] = this.get('WeightPaths');
        end
        
        %-- S --
        
        function this = setWeightData( this, iW, iVariableNames )
            ds = biotracs.data.model.DataMatrix( iW );
            ds.setColumnNames( 'Iteration' );
            ds.setRowNames( iVariableNames );
            this.set('Weight', ds);
        end
        
        function this = setWeightPaths( this, iW, varargin )
            do = biotracs.data.model.DataObject( iW );
            this.set('WeightPaths', do);
        end
        
        function this = setProbPaths( this, iP, varargin )
            do = biotracs.data.model.DataObject( iP );
            this.set('ProbPaths', do);
        end
        
        function this = setTheta( this, iFitInfo )
            ds = biotracs.data.model.DataMatrix( iFitInfo );
            this.set('Theta', ds);
        end

    end
    
    methods( Access = protected )

        function [paths, varIndexes] = doGetSelectionPaths( this )
            %Wpaths = this.get('WeightPaths');
            %[nbVar, nbSteps] = size(Wpaths.data{1});
            %nbOutputDirections = length(Wpaths.data);
            
            probBaths = this.get('ProbPaths');
            [nbVar, nbSteps] = size(probBaths.data{1});
            nbOutputDirections = length(probBaths.data);
            paths = zeros(nbVar,nbSteps);

            for k=1:nbSteps
                for q = 1:nbOutputDirections
                    %A = Wpaths.data{q}(:,1:k) ~= 0;
                    A = probBaths.data{q}(:,1:k);
                    sumA = A(:,1);
                    for i=2:k
                        % Strategy 1
                        % Reset the total weight if the variable path is broken at step i
                        % The reset is inactive when stability selection is
                        % performed (i.e kFoldCrossValidation is used)
                        % since the path is smoothed
                        sumA = (sumA + A(:,i)) .* A(:,i);
                        
                        %Strategy 2: Do not reset the total weight (smooth selection)
                        %sumA = (sumA + A(:,i));
                    end
                    paths(:,k) = paths(:,k) + sumA;
                end
            end

            paths = paths ./ (1:nbSteps);   %with implicit row expansion
            
            %remove unselected variables
            varIndexes = find(sum(paths,2));
            paths = paths(varIndexes,:);     
        end
  
    end
    
end
