% BIOASTER
%> @file		PLSPredictorConfig.m
%> @class		biotracs.atlas.pls.model.PLSPredictorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef PLSPredictorConfig < biotracs.atlas.model.BaseDecompPredictorConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = PLSPredictorConfig( )
				this@biotracs.atlas.model.BaseDecompPredictorConfig( );
                this.createParam('ReplicatePatterns', {}, 'Constraint', biotracs.core.constraint.IsText('IsScalar', false), 'Description', 'The pattern used to reference each replicate. Used to average prediction values');
		  end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
