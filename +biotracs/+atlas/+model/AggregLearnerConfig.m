% BIOASTER
%> @file		AggregLearnerConfig.m
%> @class		biotracs.atlas.model.AggregLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregLearnerConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregLearnerConfig()
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('CorrelationThreshold', 0.85, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
            this.createParam('CorrelationPValue', 0.05, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));           
            this.createParam('MaxNbOfFeaturesPerAggregation', Inf, 'Constraint', biotracs.core.constraint.IsPositive('Strict',true), 'Description', 'Number of top N features to use for the group. Set Inf to use all.');
            this.createParam('AggregationFunction', 'mean', 'Constraint', biotracs.core.constraint.IsInSet({'mean','max'}));
        end
        
    end

end
