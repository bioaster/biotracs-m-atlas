% BIOASTER
%> @file		FeatureGrouperConfig.m
%> @class		biotracs.atlas.model.FeatureGrouperConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FeatureGrouperConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
        REDUNDANCY_FLAG_VALUE = 1;
        ISOFEATURE_FLAG_VALUE = 2;
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FeatureGrouperConfig()
            this@biotracs.core.mvc.model.ProcessConfig();
            this.createParam('MaxIsofeatureShift', Inf, 'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('MinNbOfAdjacentFeatures', 0, 'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('RedundancyCorrelation', 0.85, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
            this.createParam('RedundancyPValue', 0.05, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
            this.createParam('LinkingOrders', 0, 'Constraint', biotracs.core.constraint.IsPositive('IsScalar', false), 'Description', 'Isofeatures are linked if LinkingOrder > 0.');
            this.createParam('MinNbOfFeaturesPerGroup', 0, 'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('MaxNbOfFeaturesToUseForConsensus', Inf, 'Constraint', biotracs.core.constraint.IsPositive('Strict',true), 'Description', 'Number of top N features to use for the group. Set Inf to use all.');
            this.createParam('ConsensusFunction', 'mean', 'Constraint', biotracs.core.constraint.IsInSet({'mean','max'}));
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
