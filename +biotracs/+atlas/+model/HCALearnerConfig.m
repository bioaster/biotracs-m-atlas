% BIOASTER
%> @file		HCALearnerConfig.m
%> @class		biotracs.atlas.model.HCALearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef HCALearnerConfig < biotracs.atlas.model.BaseClustererConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = HCALearnerConfig( )
            this@biotracs.atlas.model.BaseClustererConfig( );
            this.getParam('Method')...
                    .setConstraint(biotracs.core.constraint.IsInSet({'hca', 'hcca'}))...
                    .setValue('hca');
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
