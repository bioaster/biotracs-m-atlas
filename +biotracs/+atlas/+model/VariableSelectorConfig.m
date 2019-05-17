% BIOASTER
%> @file		VariableSelectorConfig.m
%> @class		biotracs.atlas.model.VariableSelectorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef (Abstract)VariableSelectorConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = VariableSelectorConfig()
            this@biotracs.atlas.model.BaseLearnerConfig();
            this.createParam('NbVariablesToSelect', [], 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true));
        end

    end

end
