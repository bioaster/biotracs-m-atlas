classdef FileFormatingTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/atlas/FileFormatingTests');
    end
    
    methods (Test)
        
        
        function testLipidMatchAnnotator(testCase)
            a1 = biotracs.data.model.DataFile( [pwd, '/../../testdata/MetaboData/Analysis1.csv']);
            a2 = biotracs.data.model.DataFile( [pwd, '/../../testdata/MetaboData/Analysis2.csv']);
            a3 = biotracs.data.model.DataFile( [pwd, '/../../testdata/MetaboData/Analysis3.csv']);
            a4 = biotracs.data.model.DataFile( [pwd, '/../../testdata/MetaboData/Analysis4.csv']);
            
            ds = biotracs.data.model.DataFileSet();
            ds.add(a1);
            ds.add(a2);
            ds.add(a3);
            ds.add(a4);

            
            process = biotracs.atlas.model.FileFormating();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('ColumnNames', {'Analysis1', 'Analysis2', 'Analysis3', 'Analysis4'});

            process.run();
            result = process.getOutputPortData('DataTable');
            [~,m] = getSize(result);
            result.export([testCase.workingDir, '/FileFormatted.csv']);
            
            expectedOutputFilePaths = fullfile([ testCase.workingDir, '/FileFormatted.csv']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );

             testCase.verifyEqual(m, 4);
            testCase.verifyEqual(result.getColumnNames, {'Analysis1', 'Analysis2', 'Analysis3', 'Analysis4'});
           
     
        end
        
           function testLipidMatchAnnotatorNoColumnNames(testCase)
            a1 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis1.csv']);
            a2 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis2.csv']);
            a3 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis3.csv']);
            a4 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis4.csv']);
            
            ds = biotracs.data.model.DataFileSet();
            ds.add(a1);
            ds.add(a2);
            ds.add(a3);
            ds.add(a4);

            
            process = biotracs.atlas.model.FileFormating();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/NoColumnNames']);

            process.run();
            result = process.getOutputPortData('DataTable');
            result.export([testCase.workingDir, '/NoColumnNames/FileFormatted.csv']);
            
               [~,m] = getSize(result);
            
            expectedOutputFilePaths = fullfile([ testCase.workingDir, '/NoColumnNames/FileFormatted.csv']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );

             testCase.verifyEqual(m, 4);
            testCase.verifyEqual(result.getColumnNames, {'Analysis1', 'Analysis2', 'Analysis3', 'Analysis4'});
                
        end
        
    end
end