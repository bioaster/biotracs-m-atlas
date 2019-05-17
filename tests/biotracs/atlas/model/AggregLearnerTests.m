classdef AggregLearnerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/AggregLearnerTests');
    end
    
    methods (Test)
            
        function testAggreg(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trSet = biotracs.data.model.DataSet.import( filePath );
            trSet.setRowNamePatterns({'Group'});
            trSet = trSet.createXYDataSet();

            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);

            [ learnerResult ] = testCase.doLearningTests(trSet);
            learnerResult.view('GraphHtml');
            testCase.doPredictionTests(learnerResult, trSet);
            
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
        
    end
    
    methods
        
        function [ result ] = doLearningTests( testCase, trSet )
            learner = biotracs.atlas.model.AggregLearner();
            learner.getConfig()...
                .updateParamValue('CorrelationThreshold', 0.7)...
                .updateParamValue('CorrelationPValue', 0.1 )...
                .updateParamValue('WorkingDirectory', testCase.workingDir );
                
            learner.setInputPortData( 'TrainingSet', trSet );
            learner.run();
            result = learner.getOutputPortData('Result');

            isofeatureMap = result.get('IsoFeatureMap');
            isofeatureMap.summary()
            
            %isofeatureMap.export('../testdata/isofeaturemap.csv');
            isofeatureMapTable = isofeatureMap.toDataTable();
            expectedIsofeatureMap = biotracs.data.model.DataTable.import('../testdata/aggreg/isofeaturemap.csv');
            testCase.verifyEqual(isofeatureMapTable.data, expectedIsofeatureMap.data);
            testCase.verifyEqual(isofeatureMapTable.rowNames, expectedIsofeatureMap.rowNames);
            testCase.verifyEqual(isofeatureMapTable.columnNames, expectedIsofeatureMap.columnNames);
        end
        
        function doPredictionTests( testCase, learnerResult, teSet )
            %predictor
            learner = biotracs.atlas.model.AggregPredictor();
            learner.getConfig()...
                .updateParamValue('AggregationFunction', 'mean')...
                .updateParamValue('WorkingDirectory', testCase.workingDir );
            
            learner.setInputPortData( 'PredictiveModel', learnerResult );
            learner.setInputPortData( 'TestSet', teSet );
            learner.run();
            result = learner.getOutputPortData('Result');
            
            aggregDataSet = result.get('XPredictions');
            aggregDataSet.summary();            
            testCase.verifyTrue( teSet.getSize(2) > aggregDataSet.getSize(2) );
            testCase.verifyTrue( teSet.getSize(1) == aggregDataSet.getSize(1) );
            
            pca1 = biotracs.atlas.model.PCALearner();
            pca1.setInputPortData('TrainingSet', teSet);
            pca1.config.updateParamValue('NbComponents',2);
            pca1.run();
            r1 = pca1.getOutputPortData('Result');
            r1.view('ScorePlot',...
                'NbDimensions', 2, ...
                'Subplot', {1,2,1} ...
                );
            
            pca2 = biotracs.atlas.model.PCALearner();
            pca2.setInputPortData('TrainingSet', aggregDataSet);
            pca2.config.updateParamValue('NbComponents',2);
            pca2.run();
            r2 = pca2.getOutputPortData('Result');
            r2.view('ScorePlot',...
                'NbDimensions', 2, ...
                'NewFigure', false, ...
                'Subplot', {1,2,2} ...
                );
            
            set( gcf,  'Units', 'normalized', 'Position', [0.1995 0.4685 0.5453 0.3741] );
        end
        
    end
    
end
