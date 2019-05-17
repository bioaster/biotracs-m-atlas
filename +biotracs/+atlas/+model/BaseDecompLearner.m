% BIOASTER
%> @file		BaseDecompLearner.m
%> @class		biotracs.atlas.model.BaseDecompLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract)BaseDecompLearner < biotracs.atlas.model.BaseLearner
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseDecompLearner()
            this@biotracs.atlas.model.BaseLearner();
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
end