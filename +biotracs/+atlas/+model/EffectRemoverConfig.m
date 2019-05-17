% BIOASTER
%> @file		EffectRemoverConfig.m
%> @class		biotracs.atlas.model.EffectRemoverConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef EffectRemoverConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = EffectRemoverConfig( )
            this@biotracs.core.mvc.model.ProcessConfig( );
            this.createParam( 'Method', 'linear', 'Constraint', biotracs.core.constraint.IsInSet({'linear'}), 'Description', 'Name of the effect to filter from samples' );
            this.createParam( 'EffectsToRemove', '', 'Constraint', biotracs.core.constraint.IsText('IsScalar', false), 'Description', 'Name of the effect to filter from samples' );
            this.createParam( 'ReferenceGroups', '', 'Constraint', biotracs.core.constraint.IsText('IsScalar', false), 'Description', 'Name of the effect to filter from samples' );
            this.createParam( 'NbComponentsPerEffect', 1, 'Constraint', biotracs.core.constraint.IsPositive(), 'Description', 'Number of component per effect to use' );
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
