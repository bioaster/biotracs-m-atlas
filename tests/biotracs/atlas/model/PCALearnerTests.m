classdef PCALearnerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PCATests');
    end

    methods (Test)

        function testRunLearningProcess(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';

            %configuration
            method = 'kmeans';             %'kmeans' or 'hca'
            maxNbClusters = 2;
            nbComponents = 3;
            
            %parse data
            trainingSet = biotracs.data.model.DataSet.import(filePath,'WorkingDirectory', testCase.workingDir);
            trainingSet.setRowNamePatterns( {'Group'} );
            
            %--------------------------------------------------------------
            % Test Learning
            %--------------------------------------------------------------
            
            learningProcess = biotracs.atlas.model.PCALearner();
            learningProcess.getConfig()...
                .updateParamValue('NbComponents', nbComponents)...
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Training'));
            learningProcess.setInputPortData('TrainingSet', trainingSet );     
            learningProcess.run();
            
            %--------------------------------------------------------------
            %Plot PCA scores
            learningResults = learningProcess.getOutputPortData('Result');
            learningResults.view( ...
                'ScorePlot', ...
                'PlotType', 'X', ...       
                'NbComponents', nbComponents ...
            );
            fileName1 = 'score_plot.jpg';
            biotracs.core.fig.helper.Figure.save(...
            	fullfile(testCase.workingDir, fileName1) ...
            );
        
            %--------------------------------------------------------------
            %Clustering Learner
            clustProcess = biotracs.atlas.model.KmeansLearner();
            c = clustProcess.getConfig();
            c.updateParamValue('Center', false);
            c.updateParamValue('Scale', 'none');
            c.updateParamValue('MaxNbClusters', maxNbClusters);
            c.updateParamValue('Method', method);
            c.updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Clust'));
            
            dataMatrix = learningResults.getXScores();
            clustProcess.setInputPortData( ...
                'TrainingSet', ...
                biotracs.data.model.DataSet.fromDataMatrix(dataMatrix) ...
            );
            clustProcess.run();
            clustResults = clustProcess.getOutputPortData('Result');
            
            %--------------------------------------------------------------
            %Plot Clusters in PCA score plot 2D
            ndim = 2;
            learningResults.view(...
                'ScorePlot', ...
                'ClusteringResult', clustResults, ...
                'NbDimensions', ndim ...
                );
        
            %--------------------------------------------------------------
            %Plot Clusters in PCA score plot 3D
            ndim = 3;
            h  = learningResults.view(...
                'ScorePlot', ...
                'ClusteringResult', clustResults, ...
                'NbDimensions', ndim ...
                );
            fileName2 = 'clust_plot.fig';
            biotracs.core.fig.helper.Figure.save(...
            	fullfile(testCase.workingDir, fileName2) ...
            );

            testCase.verifyTrue( isfile([testCase.workingDir, '/', fileName1]) );
            testCase.verifyTrue( isfile([testCase.workingDir, '/', fileName2]) );
            
            
            %--------------------------------------------------------------
            % Test Prediction
            %--------------------------------------------------------------
            testSet = trainingSet.selectByRowIndexes([1,2,8,10]);
            testSet = biotracs.data.model.DataSet.fromDataSet( testSet );
            data = testSet.getData();
            m = size(data, 1);
            n = size(data, 2);
            data = data + rand(m,n) .* repmat(std(data),m,1) .* 0.2;
            testSet.setData( data, false ); %preserve row and column names

            predictionProcess = biotracs.atlas.model.PCAPredictor();
            predictionProcess.getConfig()...
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Prediction'));
            predictionProcess.setInputPortData( 'TestSet', testSet );
            predictionProcess.setInputPortData('PredictiveModel', learningResults);
            predictionProcess.run();
            predictorResults = predictionProcess.getOutputPortData('Result');
            predictorResults.view(...
                'XProjectionOnScorePlot', ...
                'NbComponents', nbComponents, ...
                'ScorePlotAxes', h.Children(1) ...
                );
        end
        
    end
    
end
