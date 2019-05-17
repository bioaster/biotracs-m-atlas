classdef PLSDATests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PLSDATests');
    end
    
    methods (Test)

        function testPLSDA(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trainingSet = biotracs.data.model.DataSet.import( filePath, 'WorkingDirectory', testCase.workingDir );
            
            trainingSet.setRowNamePatterns({'Group'});
            trainingSet = trainingSet.createXYDataSet();
            
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);
            
            %process
            pls = biotracs.atlas.model.PLSLearner();
            c = pls.getConfig();
            c.updateParamValue('NbComponents', 20);
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows() ); %leave-one-out
            c.updateParamValue( 'Scale', 'uv' );
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            
            pls.setInputPortData( 'TrainingSet', trainingSet );
            pls.run();
            learningResults = pls.getOutputPortData('Result');
            learningResults.view('VipPlot', 'TopNCount', 10);

             % Plot Clusters in score plot
            h = learningResults.view( ...
                'ScorePlot', ...
                'NbComponents', 5, ...
                'NbDimensions', 3, ...
                'GroupList', {'Group'}, ...
                'LabelFormat', 'long' ...
                );

            cVip5 = learningResults.getCrossValidationVip(5);
            cVip5.sortRows(-1).summary();
            stats = learningResults.getStats();
            msep = stats.get('MSEP_Y');
            %msep.export('../testdata/metabo1/MSEP_Y_ncomp=20.csv');
            
            expectedYMsep = biotracs.data.model.DataMatrix.import('../testdata/pls/metabo1/MSEP_Y_ncomp=20.csv','WorkingDirectory', testCase.workingDir);
            testCase.verifyEqual( msep.data, expectedYMsep.data, 'AbsTol', 1e-6 );
            
            %view MSE plot
            learningResults.view('MsePlot');
            learningResults.view('E2Plot');
            learningResults.view('Q2Plot');
            
            %class separator            
            learningStats = learningResults.get('Stats');
            classSep = learningStats.get('ClassSep');
            classSep.summary();
            %classSep.export('../testdata/metabo1/ClassSeparation.csv');
            
            expectClassSep = biotracs.data.model.DataMatrix.import('../testdata/pls/metabo1/ClassSeparation.csv','WorkingDirectory', testCase.workingDir);
            testCase.verifyEqual( classSep.data, expectClassSep.data, 'AbsTol', 1e-5 );
            testCase.verifyEqual( classSep.rowNames, expectClassSep.rowNames );
            testCase.verifyEqual( classSep.columnNames, expectClassSep.columnNames );
            
            %prediction
            predictor = biotracs.atlas.model.PLSPredictor();
            predictor.getConfig().updateParamValue('ReplicatePatterns', 'Group');
            predictor.setInputPortData('TestSet', trainingSet );
            predictor.setInputPortData('PredictiveModel', learningResults);
            predictor.run();
            
            predictorResult = predictor.getOutputPortData('Result');
            predictorResult.view(...
                'YPredictionPlot', ...
                'GroupList', {'Group'}, ...
                'LabelFormat', {'pattern', {'Group:([^_]*)'}} ...
                );
            
            %check that the predictions are the same as expected
            testCase.verifyEqual( learningResults.getYPredictions().data, predictorResult.get('YPredictions').data );
            
%             predictorResult.get('Stats').summary();
            
            % test average predictions
%             predictorResult.get('YPredictions').summary() 
%             predictorResult.get('YPredictionMeans').summary()
%             predictorResult.get('YPredictionStds').summary()
            
            pred = predictorResult.get('YPredictions').selectByRowName('Group:E');
            expectedAvg = mean(pred);
            expectedStd = std(pred);
            
            avgPred = predictorResult.get('YPredictionMeans').selectByRowName('Group:E');
            stdPred = predictorResult.get('YPredictionStds').selectByRowName('Group:E');
            
            testCase.verifyEqual( avgPred.data, expectedAvg.data );
            testCase.verifyEqual( stdPred.data, expectedStd.data );
            
%             predictorResult.get('YPredictionScores').summary
%             predictorResult.get('YPredictionScoreMeans').summary
%             predictorResult.get('YPredictionScoreStds').summary
            
            predictorResult.view('YPredictionScoreHeatMap');
            
            predictorResult.view(...
                'YPredictionScoreHeatMap',...
                'ShowAverage', true );
            
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end

    end
    
    methods( Access = private )

    end
    
end
