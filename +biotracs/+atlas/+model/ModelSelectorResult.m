% BIOASTER
%> @file		ModelSelectorResult.m
%> @class		biotracs.atlas.model.ModelSelectorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef ModelSelectorResult < biotracs.atlas.model.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ModelSelectorResult()
            this@biotracs.atlas.model.BaseLearnerResult()
            this.bindView(biotracs.atlas.view.ModelSelectorResult());
            this.add(biotracs.data.model.DataSet, 'SmallestSelectedDataSet');
            this.add(biotracs.data.model.DataSet, 'LargestSelectedDataSet');
            this.add(biotracs.atlas.model.SelectedModelMap, 'SelectedModelMap');
            
            this.add(biotracs.data.model.DataSet, 'OptimalSelectedDataSet');
            this.add(biotracs.atlas.model.SelectedVariableDataMatrix, 'OptimalSelectedVariableDataMatrix');
            
        end

        %-- C --
        
        function [ stats ] = computeOptimalModelStatistics( this, varargin )
            p = inputParser();
            p.addParameter('PValue', 0.05, @isnumeric);
            p.addParameter('Delta', 0.05, @isnumeric);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            perfMatrix = this.get('Stats').get('ModelSelectPerf');
            stats = struct();
            if this.isDiscriminantAnalysis()  
                criterion = perfMatrix.getDataByColumnName('CV_E2');
                criterionToMinimize = criterion;
                stats.name = 'CV_E2';
            else
                criterion = perfMatrix.getDataByColumnName('Q2Y');
                criterionToMinimize = 1-criterion;
                stats.name = 'Q2Y';
            end
            
            %Determine a cuttof for the criterion
            espilon = abs(max(criterionToMinimize) - min(criterionToMinimize)) * p.Results.Delta;    %singificance magnitude
            cutoff = min(criterionToMinimize) + espilon;
            idx = criterionToMinimize <= cutoff;
            minNbVariables = find(idx, 1, 'first');
            maxNbVariables = find(idx, 1, 'last');
            
            %Determine the best criterion value that validate the cuttof and pValue
            pValues = perfMatrix.getDataByColumnName('PValue');
            if ~isempty( minNbVariables )
                minNbVariablesWithPValue = find( pValues(1:minNbVariables) <= p.Results.PValue, 1, 'last' );
                maxNbVariablesWithPValue = find( pValues(1:maxNbVariables) <= p.Results.PValue, 1, 'last' );
                if isempty(minNbVariablesWithPValue)
                    minNbVariablesWithPValue = minNbVariables;
                    maxNbVariablesWithPValue = maxNbVariables;
                end
            else
                minNbVariablesWithPValue = find( pValues == min(pValues), 1, 'first' );
                maxNbVariablesWithPValue = find( pValues == min(pValues), 1, 'last' );
            end

            stats.NbVariables   = [minNbVariablesWithPValue, maxNbVariablesWithPValue];
            stats.PValue        = pValues(stats.NbVariables);
            stats.TStatistics   = criterion(stats.NbVariables);
            stats.H = (stats.PValue(1) <= p.Results.PValue);
        end
        
        %-- G --

    end
    
    methods

        
    end
    
end
