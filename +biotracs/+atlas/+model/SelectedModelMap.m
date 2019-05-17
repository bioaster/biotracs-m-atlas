% BIOASTER
%> @file		SelectedModelMap.m
%> @class		biotracs.atlas.model.SelectedModelMap
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef SelectedModelMap < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = SelectedModelMap( varargin )
            this@biotracs.core.mvc.model.ResourceSet( varargin{:} )
            this.classNameOfElements = {'biotracs.atlas.model.SelectedVariableDataMatrix'};
        end

        %-- C --
        
        %-- G --
    end
    
    methods

        
    end
    
end
