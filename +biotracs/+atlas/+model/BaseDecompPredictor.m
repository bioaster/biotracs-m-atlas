% BIOASTER
%> @file		BaseDecompPredictor.m
%> @class		biotracs.atlas.model.BaseDecompPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract)BaseDecompPredictor < biotracs.atlas.model.BasePredictor
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseDecompPredictor()
            %#function biotracs.atlas.model.BaseDecompPredictorConfig biotracs.atlas.model.BaseDecompPredictorResult
            this@biotracs.atlas.model.BasePredictor();
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        % Set prediction results
        % Must be overloaded if required
        function doSetPredictorResult( this, predStruct )
            this.doSetPredictorResult@biotracs.atlas.model.BasePredictor(predStruct);
            if isfield(predStruct, 'projX0test')
                predictionResult = this.getOutputPortData('Result');
                predictionResult.setXProjectionData( predStruct.projX0test );
            end
        end
        
    end

    
end
