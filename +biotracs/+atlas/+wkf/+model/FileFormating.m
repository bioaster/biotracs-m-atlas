% BIOASTER
%> @file 		FileFormating.m
%> @class 		biotracs.atlas.model.FileFormating
%> @link			http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019

classdef FileFormating < biotracs.core.mvc.model.Process
    
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
        function this = FileFormating()
            this@biotracs.core.mvc.model.Process();
            this.configType = 'biotracs.atlas.model.FileFormatingConfig';
            this.setDescription('Formating files for venn diagram analysis');
            
            this.setInputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });
            
            this.setOutputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                ),...
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

 
        function doRun( this )
            ds = this.getInputPortData('DataFileSet');
            nbFiles = ds.getLength;
            for i=1:nbFiles
                file = ds.getAt(i);
                columnNames{i} = file.getLabel;
                table = biotracs.data.model.DataTable.import(file.getPath());
                l{i} = table.rowNames;
                
            end
            rowLength = cellfun('length', l);
            rows = max(rowLength);
            
            % Instatiate cell array of the max size.
            combinedData = cell(rows, nbFiles);
            
            % stuff each column in.
            for i=1:nbFiles
                combinedData(1:rowLength(i), i) = l{i};
            end
            mergedData = biotracs.data.model.DataTable(combinedData);
            if isempty(this.config.getParamValue('ColumnNames'))
                this.config.updateParamValue('ColumnNames', columnNames );
            end
            mergedData.setColumnNames(this.config.getParamValue('ColumnNames'));
            mergedData.setLabel('MergedData');

           this.setOutputPortData('DataTable', mergedData);
        end


    end
    
    
end
