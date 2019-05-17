% BIOASTER
%> @file		PCALearnerConfig.m
%> @class		biotracs.atlas.model.PCALearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef PCALearnerConfig < biotracs.atlas.model.BaseDecompLearnerConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = PCALearnerConfig( )
				this@biotracs.atlas.model.BaseDecompLearnerConfig( ); 
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
