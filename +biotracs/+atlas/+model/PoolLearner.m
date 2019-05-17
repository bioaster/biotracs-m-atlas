% BIOASTER
%> @file		PoolLearner.m
%> @class		biotracs.atlas.model.PoolLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolLearner < biotracs.atlas.model.BaseLearner
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolLearner()
            this@biotracs.atlas.model.BaseLearner();
            this.addInputSpecs({...
                struct(...
                'name', 'PoolingVariables',...
                'class', {{'biotracs.atlas.model.SelectedModelMap','biotracs.atlas.model.SelectedVariableDataMatrix'}} ...
                )...
                });
            
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PoolLearnerResult' ...
                )...
                });
            
            this.bindEngine( biotracs.atlas.model.PLSLearner(), 'ModelLearningEngine' );
        end
        
    end
    
    methods(Access = protected)
        
        function doLearnPerm( varargin )
            % do nothing
        end	
        
        function doLearnCv( varargin )
            % do nothing
        end  	
        
        function doLearn( this, ~, ~ )
            %verbose = this.config.getParamValue('Verbose');
            trSet = this.getInputPortData('TrainingSet').selectXSet();
            [~,n] = getSize(trSet);

            poolingVariables = this.getInputPortData('PoolingVariables');   
            if isa( poolingVariables, 'biotracs.atlas.model.SelectedModelMap' )
                optIdx = fix(getLength(poolingVariables)/2); %take at the middle
                poolingVariables = poolingVariables.getAt(optIdx);
                poolingVariableIndexes = poolingVariables.getDataByColumnName('VariableIndex');
            elseif isa( poolingVariables, 'biotracs.atlas.model.SelectedVariableDataMatrix' )
                poolingVariableIndexes = poolingVariables.getDataByColumnName('VariableIndex');
            end
            logicalPoolingVariableIndexes = false(1,n);
            logicalPoolingVariableIndexes(poolingVariableIndexes) = true;
            np = length(poolingVariableIndexes);

            corrThreshold = this.config.getParamValue('CorrelationThreshold');
            pvalueThreshold = this.config.getParamValue('CorrelationPValue');
            [rho, pval] = corr(trSet.data, trSet.data);
            rho( abs(rho) < corrThreshold | pval > pvalueThreshold ) = 0;
            rho(logical(eye(n))) = 0;
            rho(:,~logicalPoolingVariableIndexes) = 0;
            for i = 1:np
                k = poolingVariableIndexes(i);
                rho(k,k) = 1;
            end
            rho = sparse(triu(rho));      
            poolingMap = biotracs.data.model.DataMatrix( rho, trSet.columnNames, trSet.columnNames );

            result = this.getOutputPortData('Result');
            result.set('PoolingMap', poolingMap);
            result.set('PoolingVariables', poolingVariables.copy());
            this.setOutputPortData('Result', result);

        end
        
    end
    
end
