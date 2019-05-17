% BIOASTER
%> @file		PartialDiffProcessConfig.m
%> @class		biotracs.atlas.model.PartialDiffProcessConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef PartialDiffProcessConfig < biotracs.core.mvc.model.ProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = PartialDiffProcessConfig()
				this@biotracs.core.mvc.model.ProcessConfig();
				this.setDescription('Configuration for partial differential analysis based on principal-components analysis');
                this.createParam('NbComponents', 2, 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true, 'Type', 'integer'));
                this.createParam('MonteCarloPermutation', [], 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true, 'Type', 'integer'));
                this.createParam('PValue', 0.05, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
                this.createParam('GroupPatterns', {}, 'Constraint', biotracs.core.constraint.IsText('IsScalar', false));
		  end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
