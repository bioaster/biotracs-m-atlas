% BIOASTER
%> @file		VariableSelector.m
%> @class		biotracs.atlas.model.VariableSelector
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef (Abstract)VariableSelector < biotracs.atlas.model.BaseLearner
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = VariableSelector()
            this@biotracs.atlas.model.BaseLearner();
            
            this.addOutputSpecs({...
                struct(...
                    'name', 'Result',...
                    'class', 'biotracs.atlas.model.VariableSelectorResult' ...
                ) ...
            });
        end

    end
    
    methods(Access = protected)

        
    end
    
end
