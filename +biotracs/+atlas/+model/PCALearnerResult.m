% BIOASTER
%> @file		PCALearnerResult.m
%> @class		biotracs.atlas.model.PCALearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PCALearnerResult < biotracs.atlas.model.BaseDecompLearnerResult
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PCALearnerResult( varargin )
            this@biotracs.atlas.model.BaseDecompLearnerResult();
            this.bindView( biotracs.atlas.view.PCALearnerResult );
        end
        
        %-- G --

    end
    
end
