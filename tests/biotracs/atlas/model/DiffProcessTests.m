classdef DiffProcessTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/DiffTests');
    end
    
    methods (Test)
        
        function testDifferentialAnalysisTtest(testCase)
            s1 = RandStream.create('mrg32k3a','Seed', 42);
            s0 = RandStream.setGlobalStream(s1);
            
            e = biotracs.atlas.model.DiffProcess();
            e.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir) ...
                .updateParamValue('FoldChangeThreshold', 1.2);
            
            data = biotracs.data.model.DataSet.import( '../testdata/metabo1/metabolites.xlsx' );
            
            data.setRowNamePatterns( {'Group'} );
            e.config...
                .updateParamValue('GroupPatterns', {'Group'})...
                .updateParamValue('NegativeValuesImputation', true);
            e.setInputPortData('DataSet', data);
            e.run();
            
            result = e.getOutputPortData('Result');
            
            %test DiffTable
            diffTable = result.get('DiffTable');
            diffTable.summary('deep', true)
            
            testCase.verifyClass( diffTable, 'biotracs.core.mvc.model.ResourceSet' );
            
            idx = diffTable.getElementIndexesByNames({'Group:A_Group:B','Group:B_Group:A'});
            diffMatrix = diffTable.getAt(idx(1));    
            
            diffMatrix.export('../testdata/diff/diff_matrix.csv');
            
            testCase.verifyClass( diffMatrix, 'biotracs.data.model.DataMatrix' );
            name = diffTable.elementNames{idx(1)};
            testCase.verifyTrue( strcmp(name, 'Group:A_Group:B') || strcmp(name, 'Group:B_Group:A') );
            expectedData = biotracs.data.model.DataMatrix.import('../testdata/diff/diff_matrix.csv');
            testCase.verifyEqual( diffMatrix.data, expectedData.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( diffMatrix.columnNames, expectedData.columnNames );
            testCase.verifyEqual( diffMatrix.rowNames, expectedData.rowNames );

            %diffMatrix.export('diff_matrix.csv')
            
            %test StatMatrix
            statTable = result.get('StatTable');
            idx = statTable.getElementIndexesByNames('Group:A');
            statMatrix = statTable.getAt(idx(1));
            
            statMatrix.export('../testdata/diff/stats_matrix.csv');
            
            expectedData = biotracs.data.model.DataMatrix.import('../testdata/diff/stats_matrix.csv');
            testCase.verifyEqual( statMatrix.data, expectedData.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( statMatrix.columnNames, expectedData.columnNames );
            testCase.verifyEqual( statMatrix.rowNames, expectedData.rowNames );
            
            
            diffTable.export( fullfile(testCase.workingDir,'CSV','diffTable.csv') )
            %result.view('DiffPlot');
            %result.view('VolcanoPlot');
            %result.view('VolcanoPlot', 'LabelFormat', 'none');
            
            RandStream.setGlobalStream(s0);
        end
        
         function testDifferentialAnalysisMWXX(testCase)
            s1 = RandStream.create('mrg32k3a','Seed', 42);
            s0 = RandStream.setGlobalStream(s1);
            
            e = biotracs.atlas.model.DiffProcess();
            e.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir) ...
                .updateParamValue('Method', 'MannWhitney') ...
                .updateParamValue('FoldChangeThreshold', 1.2);
            
            data = biotracs.data.model.DataSet.import( '../testdata/metabo1/metabolites.xlsx' );
            
            data.setRowNamePatterns( {'Group'} );
            e.config...
                .updateParamValue('GroupPatterns', {'Group'})...
                .updateParamValue('NegativeValuesImputation', true);
            e.setInputPortData('DataSet', data);
            e.run();
            
            result = e.getOutputPortData('Result');
            
            %test DiffTable
            diffTable = result.get('DiffTable');
            diffTable.summary('deep', true)
            
            testCase.verifyClass( diffTable, 'biotracs.core.mvc.model.ResourceSet' );
            
            idx = diffTable.getElementIndexesByNames({'Group:A_Group:B','Group:B_Group:A'});
            diffMatrix = diffTable.getAt(idx(1));    
            
            diffMatrix.export('../testdata/diff/diff_matrix.csv');
            
            testCase.verifyClass( diffMatrix, 'biotracs.data.model.DataMatrix' );
            name = diffTable.elementNames{idx(1)};
            testCase.verifyTrue( strcmp(name, 'Group:A_Group:B') || strcmp(name, 'Group:B_Group:A') );
            expectedData = biotracs.data.model.DataMatrix.import('../testdata/diff/diff_matrix.csv');
            testCase.verifyEqual( diffMatrix.data, expectedData.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( diffMatrix.columnNames, expectedData.columnNames );
            testCase.verifyEqual( diffMatrix.rowNames, expectedData.rowNames );

            %diffMatrix.export('diff_matrix.csv')
            
            %test StatMatrix
            statTable = result.get('StatTable');
            idx = statTable.getElementIndexesByNames('Group:A');
            statMatrix = statTable.getAt(idx(1));
            
            statMatrix.export('../testdata/diff/stats_matrix.csv');
            
            expectedData = biotracs.data.model.DataMatrix.import('../testdata/diff/stats_matrix.csv');
            testCase.verifyEqual( statMatrix.data, expectedData.data, 'AbsTol', 1e-3 );
            testCase.verifyEqual( statMatrix.columnNames, expectedData.columnNames );
            testCase.verifyEqual( statMatrix.rowNames, expectedData.rowNames );
            
            
            diffTable.export( fullfile(testCase.workingDir,'CSV','diffTable.csv') )
            %result.view('DiffPlot');
            %result.view('VolcanoPlot');
            %result.view('VolcanoPlot', 'LabelFormat', 'none');
            
            RandStream.setGlobalStream(s0);
        end
    end
    
end
