% BIOASTER
%> @file		PoolLearnerConfig.m
%> @class		biotracs.atlas.model.PoolPredictorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolPredictorConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolPredictorConfig()
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('Method', 'mean', 'Constraint', biotracs.core.constraint.IsInSet({'mean', 'max'}));
            this.createParam('ActivationOrder', 4, 'Constraint', biotracs.core.constraint.IsPositive());
        end
        
    end

end
