classdef PLSRTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PLSRTest');
    end
    
    methods (Test)
        
        function testPLSR(testCase)
            filePath = '../testdata/metabo2/metabolites_with_do.xlsx';
            trainingSet = biotracs.data.model.DataSet.import( ...
                filePath, ...
                'WorkingDirectory', testCase.workingDir ...
            );
            lastVarIndex = trainingSet.getNbColumns();
            trainingSet.setOutputIndexes( lastVarIndex );
            
            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);
            
            %learning
            learningProcess = biotracs.atlas.model.PLSLearner();
            c = learningProcess.getConfig();
            c.updateParamValue('NbComponents', 2);
            c.updateParamValue('kFoldCrossValidation', 10 ); %leave-one-out
            c.updateParamValue( 'Scale', 'uv' );
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            learningProcess.setInputPortData( 'TrainingSet', trainingSet );
            learningProcess.run();
            
            %restore random stream
            RandStream.setGlobalStream(s0);

            learningResults = learningProcess.getOutputPortData('Result');
            learningResults.view(...
                'ScorePlot', ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'Group:([^_]*)'} ...
            );
            
            learningResults.view('VipPlot');
            learningResults.get('RegCoef').summary;
            
            varRanking = learningResults.getCrossValidationVariableRanking();
            expectedVarRanking = biotracs.data.model.DataSet.import( ...
                '../testdata/pls/metabo2/PlsrVarRanking_kfold=10.csv', ...
                'WorkingDirectory', testCase.workingDir ...
            );
            testCase.verifyEqual( varRanking.data, expectedVarRanking.data, 'AbsTol', 1e-9 );
            
            %prediction
            predictionProcess = biotracs.atlas.model.PLSPredictor();
            predictionProcess.setInputPortData('TestSet', trainingSet );
            predictionProcess.setInputPortData('PredictiveModel', learningResults);
            predictionProcess.run();
            predictionResults = predictionProcess.getOutputPortData('Result');
            predictionResults.view(...
                'YPredictionPlot', ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'Group:([^_]*)'} ...
                );
        end

    end
    
end
