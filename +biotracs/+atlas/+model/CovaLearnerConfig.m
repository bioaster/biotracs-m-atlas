% BIOASTER
%> @file		CovaLearnerConfig.m
%> @class		biotracs.atlas.model.CovaLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef CovaLearnerConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(Constant)
    end
    
    properties(Dependent = true)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = CovaLearnerConfig()
            error('Not yet available');
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('MaxNbClusters', 10, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true) );
            this.createParam('Method', 'kmeans', 'Constraint', biotracs.core.constraint.IsInSet({'kmeans', 'hca', 'hcca'}));
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
    end
    
end
