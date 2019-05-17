classdef SldaTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = [biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/LarsenTests'];
    end
    
    methods (Test)
       
        function testSlda( testCase )
            kfold = 1;
            selectedVariables = testCase.doRunSlda( kfold );
            
            %selectedVariables.export(['../testdata/larsen//metabo1/SelectedVariables_k=',num2str(kfold),'.csv'])
            expectedVariables = biotracs.data.model.DataMatrix.import(['../testdata/larsen/metabo1/SelectedVariables_k=',num2str(kfold),'.csv']);
            testCase.verifyEqual( selectedVariables.data, expectedVariables.data, 'AbsTol', 1e-6 );
            testCase.verifyEqual( selectedVariables.rowNames, expectedVariables.rowNames );
            testCase.verifyEqual( selectedVariables.columnNames, expectedVariables.columnNames );
            
            testCase.doRunPls( selectedVariables ) ;
        end

    end
    
    methods
        
        function selectedVariables = doRunSlda( testCase, kfold )
            s1 = RandStream.create('mrg32k3a','Seed', 42);
            s0 = RandStream.setGlobalStream(s1);
            
            filePath = '../testdata/metabo1/metabolites.xlsx';
            trainingSet = biotracs.data.model.DataSet.import( ...
                filePath, ...
                'WorkingDirectory', testCase.workingDir ...
            );
            trainingSet.setRowNamePatterns({'Group'});
            trainingSet = trainingSet.createXYDataSet();
            
            % Variable selection
            sldaProcess = biotracs.atlas.model.LarsenLearner();
            c = sldaProcess.getConfig();
            c.updateParamValue('Center', true);
            c.updateParamValue('Scale', 'uv');
            c.updateParamValue('NbVariablesToSelect', 20);
            c.updateParamValue('kFoldCrossValidation', kfold);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            sldaProcess.setInputPortData( 'TrainingSet', trainingSet );
            sldaProcess.run();
            r = sldaProcess.getOutputPortData('Result');
            selectedVariables = r.getSelectedVariables();

            RandStream.setGlobalStream(s0);
        end
        
        function doRunPls( testCase, selectedVariables )  
            % Full PLS model
            filePath = '../testdata/metabo1/metabolites.xlsx';
            trainingSet = biotracs.data.model.DataSet.import( ...
                filePath, ...
                'WorkingDirectory', testCase.workingDir ...
            );
            trainingSet.setRowNamePatterns({'Group'});
            trainingSet = trainingSet.createXYDataSet();
            
            plsProcess = biotracs.atlas.model.PLSLearner();
            c = plsProcess.getConfig();
            c.updateParamValue('Center', true);
            c.updateParamValue('Scale', 'uv');
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows());
            plsProcess.setInputPortData( 'TrainingSet', trainingSet );
            plsProcess.run();
            r2 = plsProcess.getOutputPortData('Result');
            r2.view(...
                'ScorePlot', ...
                'Subplot', {1, 2, 1}, ...
                'GroupList', {'Group'}, ...
                'title', 'Before variable selection' ...
                );
            
            % Simplified PLS model with selected variables
            idx = selectedVariables.getDataByColumnName('VariableIndex');
            XSet = trainingSet.selectXSet();
            subXSet = XSet.selectByColumnIndexes( idx );
            subXSet.setRowNamePatterns({'Group'});
            subXYSet = subXSet.createXYDataSet();
            
            plsProcess = biotracs.atlas.model.PLSLearner();
            c = plsProcess.getConfig();
            c.updateParamValue('Center', true);
            c.updateParamValue('Scale', 'uv');
            c.updateParamValue('kFoldCrossValidation', trainingSet.getNbRows());
            c.updateParamValue('StandardizeOutputs', false);
            plsProcess.setInputPortData( 'TrainingSet', subXYSet );
            plsProcess.run();
            r3 = plsProcess.getOutputPortData('Result');
            r3.view(...
                'ScorePlot', ...
                'NewFigure', false, ...
                'Subplot', {1, 2, 2}, ...
                'GroupList', {'Group'}, ...
                'title', 'After variable selection' ...
                );
            
            set(gcf, 'Unit', 'Normalized', 'Position', [0.2312    0.3389    0.4693    0.3889]); 
        end
    end
    

end
