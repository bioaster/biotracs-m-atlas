% BIOASTER
%> @file		DataFilter.m
%> @class		biotracs.atlas.model.VennDiagram
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019

classdef VennDiagram < biotracs.core.shell.model.Shell
    
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
        function this = VennDiagram()
            this@biotracs.core.shell.model.Shell();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });
            
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        
        function doBeforeRun( this )
            df  = this.getInputPortData('DataFileSet');
            dataFile = df.getAt(1);
            inputDataFile = biotracs.data.model.DataTable.import( dataFile.getPath() , 'ReadRowNames', false);
            [~, m] = getSize(inputDataFile);
            conditionsNames = inputDataFile.getColumnNames;
            this.config.updateParamValue('InputFilePath', inputDataFile.getRepository());
            this.config.updateParamValue('ConditionsNames', conditionsNames);
            this.config.updateParamValue('ConditionsNumber', m);
            
        end
        
        function [ n ] = doComputeNbCmdToPrepare( this )
            dataFileSet = this.getInputPortData('DataFileSet');
            n = dataFileSet.getLength();
        end
        
        function [ outputDataFilePath ] = doPrepareInputAndOutputFilePaths( this, iIndex )
            dataFileSet = this.getInputPortData('DataFileSet');
            inputDataFile = dataFileSet.getAt(iIndex);

            outputFileName = this.config.getParamValue('OutputFileName');
            outputFileExtension = '.csv';
            outputDataFilePath = fullfile([this.config.getParamValue('WorkingDirectory'), '/',outputFileName, outputFileExtension]);

            this.config.updateParamValue('InputFilePath', inputDataFile.getPath());
            this.config.updateParamValue('OutputFilePath', outputDataFilePath);
        end
        
        function [listOfCmd, outputDataFilePaths, nbOut ] = doPrepareCommand (this)
            nbOut = this.doComputeNbCmdToPrepare();
            outputDataFilePaths = cell(1,nbOut);
            listOfCmd = cell(1,nbOut);
            for i=1:nbOut
                % -- prepare file paths
                [  outputDataFilePaths{i} ] = this.doPrepareInputAndOutputFilePaths( i );
                % -- config file export
                if this.config.getParamValue('UseShellConfigFile')
                    this.doUpdateConfigFilePath();
                    this.exportConfig( this.config.getParamValue('ShellConfigFilePath'), 'Mode', 'Shell' );
                end
                % -- exec
                [ listOfCmd{i} ] = this.doBuildCommand();
            end
            %nbOut = length(listOfCmd);
        end
        
        function doRun( this )
            [listOfCmd, outputDataFilePaths, nbOut] = this.doPrepareCommand();
            nbCmd = length(listOfCmd);
            cmdout = cell(1,nbOut);
            biotracs.core.parallel.startpool();
            if nbOut == 0
                fprintf('No input data found\n');
            else
                parfor sliceIndex=1:nbCmd
                    [~, cmdout{sliceIndex}] = system( listOfCmd{sliceIndex} );
                    
                end
            end
            outputFileName = {this.config.getParamValue('OutputFileName')};
            
            this.doSetResultAndWriteOutLog(nbOut, outputFileName, listOfCmd, cmdout, outputDataFilePaths);
        end
        
        function this = doSetResultAndWriteOutLog(this, numberOfOutFile, outputFileName, listOfCmd, cmdout, outputDataFilePaths)
            results = this.getOutputPortData('DataFileSet');
            results.allocate(numberOfOutFile);
            %store main log file name
            mainLogFileName = this.logger.getLogFileName();
            this.logger.closeLog(true);
            
            %shell log streams in separate files
            for i=1:numberOfOutFile
                this.logger.setLogFileName(outputFileName{i});
                this.logger.openLog('w');
                this.logger.setShowOnScreen(false);
                
                this.logger.writeLog('# Command');
                this.logger.writeLog('%s', listOfCmd{i});
                this.logger.writeLog('# Command outputs');
                this.logger.writeLog('%s', cmdout{i});
                outputDataFile = biotracs.data.model.DataFile(outputDataFilePaths{i});
                results.setAt(i, outputDataFile);
                
                this.logger.closeLog();
            end
            
            %restore maim log stream
            this.logger.setLogFileName(mainLogFileName);
            this.logger.openLog('a');
            this.logger.setShowOnScreen(true);
            for i=1:numberOfOutFile
                this.logger.writeLog('Resource %s processed', outputFileName{i});
            end
            
            this.setOutputPortData('DataFileSet', results);
        end
    end
end
