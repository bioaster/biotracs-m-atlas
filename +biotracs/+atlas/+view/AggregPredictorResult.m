% BIOASTER
%> @file		AggregPredictorResult.m
%> @class		biotracs.atlas.view.AggregPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregPredictorResult < biotracs.atlas.view.BaseLearnerResult
    
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
            this@biotracs.atlas.view.BaseLearnerResult()
        end

        
    end
end
