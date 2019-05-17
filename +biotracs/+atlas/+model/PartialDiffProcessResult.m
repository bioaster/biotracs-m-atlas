% BIOASTER
%> @file		PartialDiffProcessResult.m
%> @class		biotracs.atlas.model.PartialDiffProcessResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PartialDiffProcessResult < biotracs.data.model.DataMatrix
    
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

        function this = PartialDiffProcessResult( varargin )
            this@biotracs.data.model.DataMatrix( varargin{:} );
            %this.bindView( biotracs.atlas.view.BaseLearnerResult );
        end

    end
end
