classdef PoolPredictorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PoolLearnerTests');
    end
    
    methods (Test)
            
        function testPooler(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trSet = biotracs.data.model.DataSet.import( filePath );
            trSet.setRowNamePatterns({'Group'});
            trSet = trSet.createXYDataSet();
            
            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);

            %learning
            poolingVariables = biotracs.atlas.model.SelectedVariableDataMatrix.import('../testdata/mpool/metabo1/SelectedModelMap.csv');
            poolerResult = testCase.doPoolLearning(trSet, poolingVariables);
            
            %pool predictor
            predictor = biotracs.atlas.model.PoolPredictor();
            predictor.config.updateParamValue('Method', 'mean');
            predictor.setInputPortData( 'PredictiveModel', poolerResult );
            predictor.setInputPortData( 'TestSet', trSet );            
            predictor.run();
            predResult = predictor.getOutputPortData('Result');
            
            %learning
            testCase.doPls(trSet, true, {1, 3, 1});
            set(gcf, 'Unit', 'normalized', 'Position', [0.1870    0.4157    0.6047    0.3083]);
            
            poolingVariableIndexes = poolingVariables.getDataByColumnName('VariableIndex');
            selectedTrSet = trSet.selectByColumnIndexes( poolingVariableIndexes );
            selectedTrSet = selectedTrSet.createXYDataSet();
            testCase.doPls(selectedTrSet, false, {1, 3, 2});
            
            pooledDataSet = predResult.get('XPredictions');
            %pooledDataSet.setRowNamePatterns({'Group'});
            %pooledDataSet = pooledDataSet.createXYDataSet();
            testCase.doPls(pooledDataSet, false, {1, 3, 3});
            
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
     
        
    end
    
    methods
        
        function poolerResult = doPoolLearning( ~, trSet, poolingVariables )
            %pool learner
            learner = biotracs.atlas.model.PoolLearner();
            learner.getConfig()...
                .updateParamValue('CorrelationThreshold', 0.85)...
                .updateParamValue('CorrelationPValue', 0.001 );
            learner.setInputPortData( 'TrainingSet', trSet );
            learner.setInputPortData( 'PoolingVariables', poolingVariables );
            learner.run();
            poolerResult = learner.getOutputPortData('Result');
        end
        
        function doPls( testCase, trainingSet, isNewFigure, iSubplot )
            pls = biotracs.atlas.model.PLSLearner();
            c = pls.getConfig();
            c.updateParamValue('NbComponents', 20);
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows() ); %leave-one-out
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            pls.setInputPortData( 'TrainingSet', trainingSet );
            pls.run();
            plsResults = pls.getOutputPortData('Result');

            plsResults.view( ...
                'ScorePlot', ...
                'NewFigure', isNewFigure, ...
                'Subplot', iSubplot, ...
                'NbDimensions', 2, ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'Group:([^_]*)'} ...
                );
        end
    
    end
    
end
