% BIOASTER
%> @file		BaseDecompLearnerConfig.m
%> @class		biotracs.atlas.model.BaseDecompLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef BaseDecompLearnerConfig < biotracs.atlas.model.BaseLearnerConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseDecompLearnerConfig( )
            this@biotracs.atlas.model.BaseLearnerConfig( );
            this.createParam('NbComponents', 2, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true));
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
