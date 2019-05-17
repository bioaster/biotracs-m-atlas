classdef LarsenTests < matlab.unittest.TestCase

    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/Larsen');
    end
    
    methods (Test)
        function testLarsen(testCase)
            doLarsen(testCase, 1)
            doLarsen(testCase, 10)
        end
    end
    
    methods
        function doLarsen(testCase, kfold)
            %Fix stream of random numbers
            s1 = RandStream.create('mrg32k3a','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);
            wd = fullfile(testCase.workingDir, 'LarsenWithSeveralOutputs');
            
            filePath = '../testdata/metabo2/metabolites_with_do.xlsx';
            trainingSet = biotracs.data.model.DataSet.import( ...
                filePath, ...
                'WorkingDirectory', wd ...
            );
            
            lastVarIndex = trainingSet.getNbColumns();
            trainingSet.setOutputIndexes( lastVarIndex );
            
            YSet = trainingSet.selectYSet();
            
            m = getSize(YSet, 1); s = std(YSet.data);
            rnd = normrnd(0, s/5,m,1);
            YSet.setData(YSet.data + rnd, false);
                        
            trainingSet = horzmerge( trainingSet, YSet );
            
            learningProcess = biotracs.atlas.model.LarsenLearner();
            learningProcess.getConfig()...
                .updateParamValue('Center', true)...
                .updateParamValue('Scale', 'uv')...
                .updateParamValue('NbVariablesToSelect', 10)...
                .updateParamValue('kFoldCrossValidation', kfold)...
                .updateParamValue('WorkingDirectory', wd);
            learningProcess.setInputPortData( 'TrainingSet', trainingSet );
            learningProcess.run();
            r = learningProcess.getOutputPortData('Result');
            selectedVariables = r.getSelectedVariables( 10 );
            
            selectedVariables.summary
            %selectedVariables.export(['../testdata/metabo2/SelectedVariables_k=',num2str(kfold),'.csv']);
            
            expectedVariables = biotracs.data.model.DataMatrix.import(['../testdata/larsen/metabo2/SelectedVariables_k=',num2str(kfold),'.csv']);
            testCase.verifyEqual( selectedVariables.data, expectedVariables.data, 'AbsTol', 1e-6 );
            testCase.verifyEqual( selectedVariables.rowNames, expectedVariables.rowNames );
            testCase.verifyEqual( selectedVariables.columnNames, expectedVariables.columnNames );
            
            
            % Full PLS before model
            plsProcess = biotracs.atlas.model.PLSLearner();
            c = plsProcess.getConfig();
            c.updateParamValue('Center', true);
            c.updateParamValue('Scale', 'uv');
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows());
            c.updateParamValue('WorkingDirectory', wd);
            plsProcess.setInputPortData( 'TrainingSet', trainingSet );
            plsProcess.run();
            result2 = plsProcess.getOutputPortData('Result');
            predictionProcess = biotracs.atlas.model.PLSPredictor();
            predictionProcess.setInputPortData('TestSet', trainingSet );
            predictionProcess.setInputPortData('PredictiveModel', result2);
            predictionProcess.run();
            predictionResults = predictionProcess.getOutputPortData('Result');
            predictionResults.view(...
                'YPredictionPlot', ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'pattern', {'Group:([^_]*)'}}, ...
                'title', 'PLS Prediction before variable selection' ...
                );
            
            % Full PLS after model
            varIndexes = selectedVariables.getDataByColumnName('VariableIndex');
            trainingSet = horzmerge( trainingSet.selectByColumnIndexes(varIndexes), trainingSet.selectYSet() );
            plsProcess = biotracs.atlas.model.PLSLearner();
            c = plsProcess.getConfig();
            c.updateParamValue('Center', true);
            c.updateParamValue('Scale', 'uv');
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows());
            c.updateParamValue('WorkingDirectory', wd);
            plsProcess.setInputPortData( 'TrainingSet', trainingSet );
            plsProcess.run();
            result2 = plsProcess.getOutputPortData('Result');
            predictionProcess = biotracs.atlas.model.PLSPredictor();
            predictionProcess.setInputPortData('TestSet', trainingSet );
            predictionProcess.setInputPortData('PredictiveModel', result2);
            predictionProcess.run();
            predictionResults = predictionProcess.getOutputPortData('Result');
            predictionResults.view(...
                'YPredictionPlot', ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'pattern', {'Group:([^_]*)'}}, ...
                'title', 'PLS Prediction after variable selection' ...
                );
                
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
     
    end
    
end
