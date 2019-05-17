% BIOASTER
%> @file		PoolPredictorResult.m
%> @class		biotracs.atlas.model.PoolLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolPredictorResult < biotracs.atlas.model.BasePredictorResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolPredictorResult()
            this@biotracs.atlas.model.BasePredictorResult()
            this.bindView(biotracs.atlas.view.PoolLearnerResult());
        end

        %-- G --

        
        %-- S --

        function setXPredictionData( this, predData )
            teSet = this.process.getInputPortData('TestSet');
            predModel = this.process.getInputPortData('PredictiveModel');
            
            ds = biotracs.data.model.DataSet(predData);
            ds.setRowNames( teSet.rowNames );
            ds.setMeta( teSet.meta );
            varNames = predModel.get('PoolingVariables').getRowNames();
            ds.setColumnNames( varNames );
                        
            if teSet.hasResponses()
                ds = horzcat(ds, teSet.selectYSet());
            end
            this.set( 'XPredictions', ds );
        end
        
    end
    
    methods

        
    end
    
end
