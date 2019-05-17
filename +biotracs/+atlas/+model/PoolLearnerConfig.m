% BIOASTER
%> @file		PoolLearnerConfig.m
%> @class		biotracs.atlas.model.PoolLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolLearnerConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolLearnerConfig()
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('CorrelationThreshold', 0.85, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
            this.createParam('CorrelationPValue', 0.001, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
        end
        
    end

end
