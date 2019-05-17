classdef PermutationTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PermutationTests');
    end
    
    methods (Test)
             
        function testPermutationTesting(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trainingSet = biotracs.data.model.DataSet.import( filePath, 'WorkingDirectory', testCase.workingDir );
            trainingSet.setRowNamePatterns({'Group'});
            trainingSet = trainingSet.createXYDataSet();
            
            pls = biotracs.atlas.model.PLSLearner();
            c = pls.getConfig();
            c.updateParamValue('NbComponents', 5);
            c.updateParamValue('kFoldCrossValidation', Inf);
            c.updateParamValue('MonteCarloPermutation', 1000);
            c.updateParamValue( 'Scale', 'uv' );
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            
            pls.setInputPortData( 'TrainingSet', trainingSet );
            pls.run();
            learningResults = pls.getOutputPortData('Result');
            learningResults.getOptimalNbComponents();
            
            %view MSE plot
            learningResults.view('PermutationPlot', 'Criterion', 'E2');
            learningResults.view('PermutationPlot', 'Criterion', 'R2Y');

            r = learningResults.getPermutationTestSignificance('Criterion', 'R2Y');
            r.summary();
            
            r = learningResults.getPermutationTestSignificance('Criterion', 'R2Y', 'Test', 'tTest');
            r.summary();
        end

    end
    
end
