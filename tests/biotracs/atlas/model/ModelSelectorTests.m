classdef ModelSelectorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/ModelSelectorTests');
    end
    
    methods (Test)
            
        function testModelSelectorWithRegression(testCase)
            %return
            filePath = '../testdata/metabo2/metabolites_with_do.xlsx';
            trSet = biotracs.data.model.DataSet.import( filePath, 'WorkingDirectory', testCase.workingDir );
            lastVarIndex = trSet.getNbColumns();
            trSet.setOutputIndexes( lastVarIndex );
            
            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);
 
            learner = biotracs.atlas.model.ModelSelector();
            learner.bindEngine(biotracs.atlas.model.LarsenLearner(), 'VariableSelectionEngine');
            learner.getConfig()...
                .updateParamValue('NbComponents', 2)...
                .updateParamValue('kFoldCrossValidation', Inf )...
                .updateParamValue('MonteCarloPermutation', 100 )...
                .updateParamValue('MaxNbVariablesToSelect', trSet.getNbRows()*2 );
            learner.setInputPortData( 'TrainingSet', trSet );
            learner.run();
            result = learner.getOutputPortData('Result');
            
            result.view('PerformancePlot');
            result.view('SelectedModelMap');
            stats = result.get('Stats').get('ModelSelectPerf');

            %stats.export('../testdata/ModelSelector/StatisticsMetabo2.csv');
            expectedStats = biotracs.data.model.DataMatrix.import('../testdata/mselect/StatisticsMetabo2.csv', 'ReadRowNames', false);
            
            stats = stats.sortByRowNames().sortByColumnNames();
            expectedStats = expectedStats.sortByRowNames().sortByColumnNames();
            
            testCase.verifyEqual( stats.data, expectedStats.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( stats.columnNames, expectedStats.columnNames );
            testCase.verifyEqual( stats.rowNames, expectedStats.rowNames );
            testCase.verifyTrue( result.get('SmallestSelectedDataSet').hasResponses() );
            
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
        
        function testModelSelectorWithClassification(testCase)
            %return
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trSet = biotracs.data.model.DataSet.import( filePath, 'WorkingDirectory', testCase.workingDir );
            trSet.setRowNamePatterns({'Group'});
            trSet = trSet.createXYDataSet();
 
            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);
           
            learner = biotracs.atlas.model.ModelSelector();
            learner.bindEngine(biotracs.atlas.model.LarsenLearner(), 'VariableSelectionEngine');
            learner.getConfig()...
                .updateParamValue('NbComponents', 10)...
                .updateParamValue('kFoldCrossValidation', Inf )...
                .updateParamValue('MonteCarloPermutation', 100 )...
                .updateParamValue('MaxNbVariablesToSelect', trSet.getNbRows()*2 );
            learner.setInputPortData( 'TrainingSet', trSet );
            learner.run();            
            result = learner.getOutputPortData('Result');
            
            result.view('PerformancePlot');
            result.view('SelectedModelMap');
            stats = result.get('Stats').get('ModelSelectPerf');            
            
%             stats.export('../testdata/ModelSelector/StatisticsMetabo1.csv');    
%             result.get('SmallestSelectedDataSet')...
%                .export('SmallestSelectedDataSet.csv');
%             result.get('LargestSelectedDataSet')...
%                .export('LargestSelectedDataSet.csv');

            expectedStats = biotracs.data.model.DataMatrix.import('../testdata/mselect/StatisticsMetabo1.csv', 'ReadRowNames', false);
            
            stats = stats.sortByRowNames().sortByColumnNames();
            expectedStats = expectedStats.sortByRowNames().sortByColumnNames();
            
            testCase.verifyEqual( stats.data, expectedStats.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( stats.columnNames, expectedStats.columnNames );
            testCase.verifyEqual( stats.rowNames, expectedStats.rowNames );
            
            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
        
    end
    
end
