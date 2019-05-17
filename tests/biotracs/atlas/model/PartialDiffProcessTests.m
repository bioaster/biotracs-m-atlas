classdef PartialDiffProcessTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PartialDiffTests');
    end
    
    methods (Test)

        function testDifferentialAnalysis(testCase)
            s1 = RandStream.create('mrg32k3a','Seed', 42);
            s0 = RandStream.setGlobalStream(s1);
            
            dataSet = biotracs.data.model.DataSet.import( '../testdata/metabo1/metabolites.xlsx' );
            dataSet.setRowNamePatterns( {'Group'} );
            
            % PCA
            e = biotracs.atlas.model.PCALearner();
            e.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir);
            e.setInputPortData('TrainingSet', dataSet.selectXSet());
            e.run();
            pcaResult = e.getOutputPortData('Result');
            
            % PDiff
            e = biotracs.atlas.model.PartialDiffProcess();
            e.config.updateParamValue('GroupPatterns', {'Group'});
            e.config.updateParamValue('MonteCarloPermutation', 1000);
            e.setInputPortData('LearningResult', pcaResult);
            e.run();
            pDiffResult = e.getOutputPortData('Result');
            pDiffResult.summary();
            
            %pDiffResult.export('./result.csv');
            expectedResult = biotracs.data.model.DataMatrix.import('../testdata/pdiff/result.csv');
            
            testCase.verifyEqual( pDiffResult.data, expectedResult.data, 'AbsTol', 1e-2 );
            testCase.verifyEqual( pDiffResult.columnNames, expectedResult.columnNames );
            testCase.verifyEqual( pDiffResult.rowNames, expectedResult.rowNames );
            
            RandStream.setGlobalStream(s0);
        end
        
    end
    
    
    methods( Static )
        
    end
    
end
