% BIOASTER
%> @file		PCAPredictorResult.m
%> @class		biotracs.atlas.model.PCAPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PCAPredictorResult < biotracs.atlas.model.BaseDecompPredictorResult
	 
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
		  function this = PCAPredictorResult( varargin )
				this@biotracs.atlas.model.BaseDecompPredictorResult();
				this.bindView( biotracs.atlas.view.PCAPredictorResult );
		  end
		  
	 end
	 
end
