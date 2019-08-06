% BIOASTER
%> @file		DiffProcessConfig.m
%> @class		biotracs.atlas.model.DiffProcessConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef DiffProcessConfig < biotracs.core.mvc.model.ProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = DiffProcessConfig()
				this@biotracs.core.mvc.model.ProcessConfig();
				this.setDescription('Differential analysis config');
                this.createParam('Method', 'ttest', 'Constraint', biotracs.core.constraint.IsInSet({'ttest', 'MannWhitney'}));
                this.createParam('PValueThreshold', 0.05, 'Constraint', biotracs.core.constraint.IsBetween([0,1]));
                this.createParam('FoldChangeThreshold', 1.5, 'Constraint', biotracs.core.constraint.IsGreaterThan(1));
                this.createParam('GroupPatterns', {}, 'Constraint', biotracs.core.constraint.IsText('IsScalar', false));
                this.createParam('GroupsToCompare', [], 'Constraint', biotracs.core.constraint.IsText('IsScalar', false));
                this.createParam('NegativeValuesImputation', false, 'Constraint', biotracs.core.constraint.IsBoolean());
		  end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
