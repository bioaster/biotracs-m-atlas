% BIOASTER
%> @file		LarsenPredictorResult.m
%> @class		biotracs.atlas.model.LarsenPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef LarsenPredictorResult < biotracs.atlas.model.BasePredictorResult
	 
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
		  function this = LarsenPredictorResult( varargin )
				this@biotracs.atlas.model.BasePredictorResult( varargin{:} );
				this.classNameOfElements = {'biotracs.data.model.DataTable'};
				this.bindView( biotracs.atlas.view.PredictorResult );
		  end

	 end
	 
end
