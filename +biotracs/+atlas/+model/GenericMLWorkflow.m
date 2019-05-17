% BIOASTER
%> @file 		GenericMLWorkflow.m
%> @class 		biotracs.atlas.model.GenericMLWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef GenericMLWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
    end
    
    methods
        
        % Constructor
        function this = GenericMLWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doBuildWorkflow();
        end
       
    end
    
    methods(Access = protected)
        
        function this =  doBuildWorkflow( this )
            [ trainingDataSetImporter ]                     = this.doAddDataFileImporter( 'TrainingDataImporter' );
            [ trainingDataParser, trainingDataParserDemux ] = this.doAddDataParser( 'TrainingDataParser' );
            [ dataFilter ]                                  = this.doAddDataFilter( 'TrainingDataFilter' );         
            
            [ testDataSetImporter ]                         = this.doAddDataFileImporter( 'TestDataImporter' );
            [ testDataParser, testDataParserDemux ]         = this.doAddDataParser( 'TestDataParser' );
            
            % full pca, pls
            [ pcaLearner, pcaViewExporter ]                 = this.doAddPcaLearner( 'PcaLearner' );
            [ plsLearner, plsViewExporter ]                 = this.doAddPlsLearner( 'PlsLearner' );
            [ plsLearnerResultExporter ]                    = this.doAddDataFileExporter( 'PlsLearnerResultExporter' );
            
            % differential analysis
            [ diff, ...
                diffViewExporter, ...
                diffDemux ]                                 = this.doAddDiffProcess();
            [ diffTableExporter ]                           = this.doAddDataFileExporter( 'DiffTableExporter' );

            % partial differential analysis
            [ pdiff ]                                       = this.doAddPartialDiffProcess();
            [ pdiffMatrixExporter ]                         = this.doAddDataFileExporter( 'PartialDiffMatrixExporter' );
            
            % model selection
            [ modelSelector, ...
                modelSelectorViewExporter, ...
                modelSelectorDemux ]                                    = this.doAddModelSelector();
            [ dataSetExporter ]                                         = this.doAddDataFileExporter( 'SelectedDataSetExporter' );
            
            % reduced pls
            [ reducedPlsLearnerResult, reducedPlsViewExporter ]        = this.doAddPlsLearner( 'ReducedPlsLearner' );
            [ reducedPlsLearnerResultExporter ]                         = this.doAddDataFileExporter( 'ReducedPlsLearnerResultExporter' );
            [ reducedPlsPredictor, reducedPlsPredictorViewExporter ]    = this.doAddPlsPredictor( 'ReducedPlsPredictor' );
            [ reducedPlsPredictorResultExporter ]                       = this.doAddDataFileExporter( 'ReducedPlsPredictorResultExporter' );
            
            % blind pls
            [ blindPlsPredictor, blindPlsPredictorViewExporter ]        = this.doAddPlsPredictor( 'BlindPlsPredictor' );
            [ blindPlsPredictorResultExporter ]                      	= this.doAddDataFileExporter( 'BlindPlsPredictorResultExporter' );
            
            % Connect i/o ports
            %--------------------------------------------------------------
            
            %-> import training set
            trainingDataSetImporter.getOutputPort('DataFileSet')        .connectTo( trainingDataParser.getInputPort('DataFile') );
            trainingDataParser.getOutputPort('ResourceSet')             .connectTo( trainingDataParserDemux.getInputPort('ResourceSet') );                 
            trainingDataParserDemux.getOutputPort('Resource')           .connectTo( dataFilter.getInputPort('DataMatrix') );          
            dataFilter.getOutputPort('DataMatrix')                      .connectTo( pcaLearner.getInputPort('TrainingSet') ); 
            
            %-> import test set
            testDataSetImporter.getOutputPort('DataFileSet')            .connectTo( testDataParser.getInputPort('DataFile') );
            testDataParser.getOutputPort('ResourceSet')                 .connectTo( testDataParserDemux.getInputPort('ResourceSet') );                 

            %-> full pca
            pcaLearner.getOutputPort('Result')                      .connectTo( pcaViewExporter.getInputPort('Resource') );
            
            %-> full pls
            dataFilter.getOutputPort('DataMatrix')                      .connectTo( plsLearner.getInputPort('TrainingSet') );
            plsLearner.getOutputPort('Result')                      .connectTo( plsViewExporter.getInputPort('Resource') );
            plsLearner.getOutputPort('Result')                      .connectTo( plsLearnerResultExporter.getInputPort('Resource') );

            %Differential & Partial differential analysis
            %--------------------------------------------------------------
            
            %-> diff
            dataFilter.getOutputPort('DataMatrix')                      .connectTo( diff.getInputPort('DataSet') );
            diff.getOutputPort('Result')                                .connectTo( diffViewExporter.getInputPort('Resource') );
            diff.getOutputPort('Result')                                .connectTo( diffDemux.getInputPort('ResourceSet') );
            diff.getOutputPort('Result')                                .connectTo( diffTableExporter.getInputPort('Resource') );

            %-> pdiff
            plsLearner.getOutputPort('Result')                          .connectTo( pdiff.getInputPort('LearningResult') );
            pdiff.getOutputPort('Result')                               .connectTo( pdiffMatrixExporter.getInputPort('Resource') );

            dataFilter.getOutputPort('DataMatrix')                      .connectTo( modelSelector.getInputPort('TrainingSet') );
            modelSelector.getOutputPort('Result')                       .connectTo( modelSelectorDemux.getInputPort('ResourceSet') );  
            modelSelector.getOutputPort('Result')                       .connectTo( modelSelectorViewExporter.getInputPort('Resource') );
            modelSelectorDemux.getOutputPort('OptimalSelectedDataSet')  .connectTo( dataSetExporter.getInputPort('Resource') );

            %-> ModelSelection -> PlsLearning
            modelSelectorDemux.getOutputPort('OptimalSelectedDataSet')  .connectTo( reducedPlsLearnerResult.getInputPort('TrainingSet') );
            reducedPlsLearnerResult.getOutputPort('Result')             .connectTo( reducedPlsViewExporter.getInputPort('Resource') );
            reducedPlsLearnerResult.getOutputPort('Result')             .connectTo( reducedPlsLearnerResultExporter.getInputPort('Resource') );

            %-> ModelSelection -> PlsLearning -> PlsPrediction
            modelSelectorDemux.getOutputPort('OptimalSelectedDataSet')  .connectTo( reducedPlsPredictor.getInputPort('TestSet') );
            reducedPlsLearnerResult.getOutputPort('Result')             .connectTo( reducedPlsPredictor.getInputPort('PredictiveModel') );
            reducedPlsPredictor.getOutputPort('Result')                 .connectTo( reducedPlsPredictorViewExporter.getInputPort('Resource') );
            reducedPlsPredictor.getOutputPort('Result')                 .connectTo( reducedPlsPredictorResultExporter.getInputPort('Resource') );
            
            %Blind prediction
            testDataParserDemux.getOutputPort('Resource')               .connectTo( blindPlsPredictor.getInputPort('TestSet') );
            reducedPlsLearnerResult.getOutputPort('Result')             .connectTo( blindPlsPredictor.getInputPort('PredictiveModel') );
            blindPlsPredictor.getOutputPort('Result')                   .connectTo( blindPlsPredictorViewExporter.getInputPort('Resource') );   
            blindPlsPredictor.getOutputPort('Result')                   .connectTo( blindPlsPredictorResultExporter.getInputPort('Resource') );            
        end

        function [ dataFileImporter ] = doAddDataFileImporter( this, iName )
            dataFileImporter = biotracs.core.adapter.model.FileImporter();
            dataFileImporter.getConfig()...
                .updateParamValue('FileExtensionFilter', '.xlsx,.csv,.mat');
            this.addNode( dataFileImporter, iName );
        end

        function [ dataFilter ] = doAddDataFilter( this, iName )
            dataFilter = biotracs.dataproc.model.DataFilter();
            dataFilter.getConfig()...
                .updateParamValue('MinStandardDeviation', 1e-9);
            this.addNode( dataFilter, iName );
        end
        
        function [ dataParser, dataParserDemux ] = doAddDataParser( this, iName )
            dataParser = biotracs.parser.model.TableParser();
            dataParser.getConfig()...
                .updateParamValue('TableClass', 'biotracs.data.model.DataSet');
            dataParserDemux = biotracs.core.adapter.model.Demux();
            dataParserDemux.resizeOutput(1);
            this.addNode(dataParser, iName);
        end

        function [ fileExporter ] = doAddDataFileExporter( this, iName, iExt )
            if nargin == 2
                iExt = '.csv';
            end
            fileExporter = biotracs.core.adapter.model.FileExporter();
            fileExporter.getConfig()...
                .updateParamValue('FileExtension', iExt);
            this.addNode( fileExporter, iName );
        end
        
        function [ pcaLearner, pcaViewExporter ] = doAddPcaLearner( this, iName )
            pcaLearner = biotracs.atlas.model.PCALearner();
            this.addNode(pcaLearner, iName);
            pcaViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(pcaViewExporter, [iName,'ViewExporter']);
        end
        
        function [ plsLearner, plsViewExporter ] = doAddPlsLearner( this, iName )
            plsLearner = biotracs.atlas.model.PLSLearner();
            this.addNode(plsLearner, iName);
            plsViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(plsViewExporter, [iName,'ViewExporter']);
        end
        
        function [ plsPredictor, plsViewExporter ] = doAddPlsPredictor( this, iName )
            plsPredictor = biotracs.atlas.model.PLSPredictor();
            this.addNode(plsPredictor, iName);
            plsViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(plsViewExporter, [iName,'ViewExporter']);
        end
        
        function [ diffProcess, diffViewExporter, diffDemux ] = doAddDiffProcess( this )
            diffProcess = biotracs.atlas.model.DiffProcess();
            this.addNode(diffProcess, 'DiffProcess');
            diffViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(diffViewExporter, 'DiffProcessViewExporter');
            
            diffDemux = biotracs.core.adapter.model.Demux();
            diffDemux.resizeOutputWith( diffProcess.getOutputPortData('Result') );
            this.addNode(diffDemux, 'DiffProcessDemux');
        end
        
        function [ pdiffProcess, pdiffViewExporter ] = doAddPartialDiffProcess( this )
            pdiffProcess = biotracs.atlas.model.PartialDiffProcess();
            this.addNode(pdiffProcess, 'PartialDiffProcess');
            pdiffViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(pdiffViewExporter, 'PartialDiffProcessViewExporter');
        end
        
        function [ modelSelector, modelSelectorViewExporter, modelSelectorDemux ] = doAddModelSelector( this )
            modelSelector = biotracs.atlas.model.ModelSelector();
            this.addNode(modelSelector, 'ModelSelector');
            
            modelSelectorDemux = biotracs.core.adapter.model.Demux();
            modelSelectorDemux.resizeOutputWith( modelSelector.getOutputPortData('Result') );
            this.addNode(modelSelectorDemux, 'ModelSelectorDemux');
            
            modelSelectorViewExporter = biotracs.core.adapter.model.ViewExporter();
            this.addNode(modelSelectorViewExporter, 'ModelSelectorViewExporter');
        end

    end
    
end