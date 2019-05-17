% BIOASTER
%> @file		AggregPredictorResult.m
%> @class		biotracs.atlas.model.AggregLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregPredictorResult < biotracs.atlas.model.BasePredictorResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregPredictorResult()
            this@biotracs.atlas.model.BasePredictorResult();
            this.set( 'AggregatedDataSet', biotracs.data.model.DataSet.empty() );
            this.bindView(biotracs.atlas.view.AggregPredictorResult());
        end

        %-- G --

        
        %-- S --

        function setXPredictionData( ~, varargin )
            %override superclass method to prevent errors
        end
        
    end
    
    methods

        
    end
    
end