% BIOASTER
%> @file		ModelSelectorConfig.m
%> @class		biotracs.atlas.model.ModelSelectorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef ModelSelectorConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ModelSelectorConfig()
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('SearchMethod','linear', 'Constraint', biotracs.core.constraint.IsInSet({'dichotomic','linear'}));
            this.createParam('NbComponents', 2, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true));
            this.createParam('MinNbVariablesToSelect', 1, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true));
            this.createParam('MaxNbVariablesToSelect', Inf, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true));
            this.createParam('PValue', 0.05, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
            
            this.updateParamValue('MonteCarloPermutation', 1000);
            this.updateParamValue('kFoldCrossValidation', Inf);     %leave-one-out by default
        end
        
    end

end
