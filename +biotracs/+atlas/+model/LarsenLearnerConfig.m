% BIOASTER
%> @file		LarsenLearnerConfig.m
%> @class		biotracs.atlas.model.LarsenLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef LarsenLearnerConfig < biotracs.atlas.model.VariableSelectorConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = LarsenLearnerConfig( )
				this@biotracs.atlas.model.VariableSelectorConfig( );	
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
