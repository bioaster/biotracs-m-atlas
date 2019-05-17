% BIOASTER
%> @file		VennDiagramConfig.m
%> @class		biotracs.atlas.model.VennDiagramConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019


classdef VennDiagramConfig < biotracs.core.shell.model.ShellConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  %> @param[in] iInstrument The instrument of which this configuration is addressed
		  function this = VennDiagramConfig( )
				this@biotracs.core.shell.model.ShellConfig( );
                this.updateParamValue('ExecutableFilePath', biotracs.core.env.Env.vars('RExecutableFilePath'));
                this.createParam('RScript', [' --vanilla "' , biotracs.core.env.Env.vars('VennDiagramFilePath'), '"'], 'Constraint', biotracs.core.constraint.IsText());
                this.createParam('ConditionsNumber', 2, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'Number of conditions to be compared');
				this.createParam('ConditionsNames','', ...
                    'Description', 'Names of the conditions to be compared');
                this.createParam('OutputFileName', '', 'Constraint', biotracs.core.constraint.IsText(),...
                    'Description', 'Name of the output file');                 
                
                c = this.getParam('WorkingDirectory').getConstraint();
                c.setApplyFilter(false);
                
               nameCallback = @(x)(this.doFormatName(x));

                this.optionSet.addElements(...
                    'RScript', biotracs.core.shell.model.Option('%s'),...
                    'InputFilePath',        biotracs.core.shell.model.Option('-i "%s"'), ...
                    'ConditionsNumber',        biotracs.core.shell.model.Option('-n "%g"'), ...
                    'ConditionsNames',        biotracs.core.shell.model.Option('-m "%s"', 'FormatFunction', nameCallback), ...
                    'OutputFilePath',  biotracs.core.shell.model.Option('-o %s%') ...
                );
            

            
          end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
     
     methods(Access = protected)
         
         function joinNames = doFormatName( ~, names )
             joinNames = strjoin(names, ',');
         end
         
         
     end

end
