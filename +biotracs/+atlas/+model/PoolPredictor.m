% BIOASTER
%> @file		PoolPredictor.m
%> @class		biotracs.atlas.model.PoolPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolPredictor < biotracs.atlas.model.BasePredictor
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolPredictor()
            %#function biotracs.atlas.model.PoolPredictorConfig biotracs.atlas.model.PoolPredictorResult
            
            this@biotracs.atlas.model.BasePredictor();
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PoolPredictorResult' ...
                )...
                });            
        end
        
    end
    
    methods(Access = protected)
        
        function predStruct = doPredict( this, X0te, varargin )
            predModel = this.getInputPortData('PredictiveModel'); 
            poolingMap = predModel.get('PoolingMap');
            poolingVariables = predModel.get('PoolingVariables');
            poolingVariableIndexes = poolingVariables.getDataByColumnName('VariableIndex');
            np = length(poolingVariableIndexes);
                   
            method = this.config.getParamValue('Method');
            h = this.config.getParamValue('ActivationOrder');

            hasPooledData = ~isempty(find(poolingMap.data(:) ~= 0, 1)); % rho == poolingMap.data
            [m,n] = size(X0te);

            if n ~= size(poolingMap.data,1)
                error('SPECTRA:Mpool:Predictor', 'The test data must have the same number of column as the pooling map');
            end
            
            if hasPooledData
                pooledData = zeros(m,np);
                for i=1:m
                    for j=1:np
                        k = poolingVariableIndexes(j);
                        idx = poolingMap.data(:,k) ~= 0;
                        pooledData(i,j) = pool( X0te(i,idx) );
                    end
                end
                predStruct.predX0test = pooledData;
            else
                predStruct.predX0test = X0te;
            end

            %pooling function
            function y = pool(teX)
                switch method
                    case 'max'
                        y = coef(teX) * max(teX);
                    case 'mean'
                        y = coef(teX) * mean(teX);
                    otherwise
                        error('SPECTRA:Mpool:PoolPredictor', 'Invalid pooling method');
                end
            end
            
            %Threshoding coefficient
            %Activated when the number of active features in the pool ~ K
            %K = size of the pool
            function th = coef(teX)
                nx = sum(teX > 0);      %# of non-zero features in the pool
                K = numel(teX);         %total size of the pool
                th = nx.^h ./ (nx.^h + (K/2).^h);
            end
            
        end
        
        % Overload the base function
        function predStruct = doReverseNormalize( ~, predStruct )
            % Overload the base function
            % Do not perform reverse normalization because the pooled data
            % cannot be properly un-normalized
        end
        
    end
    
end
