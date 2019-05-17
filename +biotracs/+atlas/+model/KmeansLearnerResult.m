% BIOASTER
%> @file		KmeansLearnerResult.m
%> @class		biotracs.atlas.model.KmeansLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef KmeansLearnerResult < biotracs.atlas.model.BaseClustererResult
	 
	 properties(Constant)
	 end
	 
	 properties(Dependent)
		  
	 end
	 
	 events
	 end
	 
	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = KmeansLearnerResult( varargin )
              this@biotracs.atlas.model.BaseClustererResult();
              this.bindView( biotracs.atlas.view.KmeansLearnerResult );
		  end

		  %-- C --
		  
		  %-- G --
		  
		  %-- S --
	 end
	 
end
