% BIOASTER
%> @file		PLSLearnerConfig.m
%> @class		biotracs.atlas.pls.model.PLSLearnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef PLSLearnerConfig < biotracs.atlas.model.BaseDecompLearnerConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = PLSLearnerConfig( )
				this@biotracs.atlas.model.BaseDecompLearnerConfig( );
%                 this.createParam('AnalysisType', 'functional', 'Constraint', biotracs.core.constraint.IsInSet({'functional', 'predictive'}));
				this.setDescription('Configuration for the partial least square (PLS) process');
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
