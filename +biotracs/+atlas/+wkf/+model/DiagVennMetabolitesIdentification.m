% BIOASTER
%> @file 		DiagVennMetabolitesIdentification.m
%> @class 		biotracs.atlas.model.DiagVennMetabolitesIdentification
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019

classdef DiagVennMetabolitesIdentification < biotracs.core.mvc.model.Process
    
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
        function this = DiagVennMetabolitesIdentification()
            this@biotracs.core.mvc.model.Process();
            this.configType = 'biotracs.atlas.model.DiagVennMetabolitesIdentificationConfig';
            this.setDescription('Identify the metabolites of the output of the Venn Diagram');
          
            this.setInputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                ),...
                struct(...
                'name', 'VennDiagDataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });
            
             % set outputs specs
            this.setOutputSpecs({...
                struct(...
                'name', 'DataTable',...
                'class', 'biotracs.data.model.DataTable' ...
                )...
                });
   
        end
        
    end
    
  
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

 
        
        function [ mergedIDs ] = doMergeIdentification(~, dataFileSet)
            n = dataFileSet.getLength();
            for i=1:n
                file= dataFileSet.getAt(i);
                dt{i} = biotracs.data.model.DataTable.import(file.getPath());
                
            end
            
            for j= 1:n
                dtFiltered{j} = dt{j}.selectByColumnName({'^ID$', 'Nomenclature'});
            end

            mergedIDs = vertmerge(dtFiltered{:});
        end
        
        function doRun( this )
            ds = this.getInputPortData('DataFileSet');
            mergedIDs = this.doMergeIdentification(ds);
            
            diagVenn = this.getInputPortData('VennDiagDataFileSet');
            outputDiagVenn= diagVenn.getAt(1);
            outputDiagVennDt = biotracs.data.model.DataTable.import(outputDiagVenn.getPath());
            [n, ~] = getSize(mergedIDs);
            
            data = outputDiagVennDt.data;
            for i=1:n
                data = strrep(data, mergedIDs.getRowNames(i), mergedIDs.data(i));
            end
            dataAnnotated = biotracs.data.model.DataTable(data);
            dataAnnotated.setLabel(outputDiagVennDt.getLabel());
            dataAnnotated.setColumnNames(outputDiagVennDt.getColumnNames);
            this.setOutputPortData('DataTable', dataAnnotated);
        end


    end
    
    
end
