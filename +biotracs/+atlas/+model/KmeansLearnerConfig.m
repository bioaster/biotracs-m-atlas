% BIOASTER
%> @file		KmeansLearnerConfig.m
%> @class		biotracs.atlas.model.KmeansLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef KmeansLearnerConfig < biotracs.atlas.model.BaseClustererConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = KmeansLearnerConfig( )
            this@biotracs.atlas.model.BaseClustererConfig( );
            this.getParam('Method')...
                .setConstraint( biotracs.core.constraint.IsInSet({'kmeans'}) )...
                .setValue('kmeans');
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
