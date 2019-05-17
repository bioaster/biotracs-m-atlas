% BIOASTER
%> @file		PoolPredictorResult.m
%> @class		biotracs.atlas.view.PoolLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolPredictorResult < biotracs.atlas.view.BaseLearnerResult
    
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
            this@biotracs.atlas.view.BaseLearnerResult()
        end

        
    end
end
