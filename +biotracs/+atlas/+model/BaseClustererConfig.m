% BIOASTER
%> @file		BaseClustererConfig.m
%> @class		biotracs.atlas.model.BaseClustererConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef (Abstract) BaseClustererConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseClustererConfig( )
            this@biotracs.atlas.model.BaseLearnerConfig( );
            this.createParam('MaxNbClusters', [], 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true) );
            this.createParam('Method', '', 'Constraint', biotracs.core.constraint.IsText());
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
