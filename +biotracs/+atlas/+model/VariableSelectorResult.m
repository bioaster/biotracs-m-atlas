% BIOASTER
%> @file		VariableSelectorResult.m
%> @class		biotracs.atlas.model.VariableSelectorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef (Abstract)VariableSelectorResult < biotracs.atlas.model.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = VariableSelectorResult()
            this@biotracs.atlas.model.BaseLearnerResult()
        end

    end
    
    methods(Abstract)
        [this] = getSelectedVariables( this, iNbVar )
    end
    
end
