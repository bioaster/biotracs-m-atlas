% BIOASTER
%> @file		FileFormatingConfig.m
%> @class		biotracs.atlas.model.FileFormatingConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019


classdef FileFormatingConfig < biotracs.atlas.model.BaseProcessConfig
    
    
    properties(Constant)
        
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FileFormatingConfig( )
            this@biotracs.atlas.model.BaseProcessConfig( );
           
            this.createParam('ColumnNames', {}, ...
                'Constraint', biotracs.core.constraint.IsText('IsScalar', false), ...
                'Description', 'Names of the analysis/conditions to analyze');
           
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
