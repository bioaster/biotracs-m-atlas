classdef VennDiagramTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/dataproc/VennDiagramTests');
    end
    
    methods (Test)
        
        function testVennDiagTwo(testCase)
            table= biotracs.data.model.DataFile( [pwd, '/../testdata/DiagVenn2Ways.csv']);
            ds = biotracs.data.model.DataFileSet();
            ds.add(table);
            
            process = biotracs.atlas.model.VennDiagram();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/2Ways/']);
            c.updateParamValue('OutputFileName', 'OutDiagVenn2Ways');
            
            process.run();
            result = process.getOutputPortData('DataFileSet');
          
            expectedOutputFilePaths = fullfile([ testCase.workingDir, '/2Ways/OutDiagVenn2Ways.png']);
            expectedLogFilePath = fullfile([ testCase.workingDir, '/2Ways/OutDiagVenn2Ways.log']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );
            testCase.verifyEqual( exist(expectedLogFilePath, 'file'), 2 );
            testCase.verifyEqual( result.getLength(), 1 );
            testCase.verifyClass( result.getAt(1), 'biotracs.data.model.DataFile' );
            
            expectedCsvFilePath = fullfile([ testCase.workingDir, '/2Ways/OutDiagVenn2Ways.csv']);
            expectedTable = biotracs.data.model.DataTable.import(expectedCsvFilePath);
            [ n, m ] = getSize(expectedTable);
            testCase.verifyEqual(n, 41);
            testCase.verifyEqual(m, 3);

            
        end
        
        function testVennDiagThree(testCase)
            table= biotracs.data.model.DataFile( [pwd, '/../testdata/DiagVenn3Ways.csv']);
            ds = biotracs.data.model.DataFileSet();
            ds.add(table);
            
            process = biotracs.atlas.model.VennDiagram();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/3Ways/']);
            c.updateParamValue('OutputFileName', 'OutDiagVenn3Ways');
            
            process.run();
            result = process.getOutputPortData('DataFileSet');
        
            expectedOutputFilePaths = fullfile([ testCase.workingDir, '/3Ways/OutDiagVenn3Ways.png']);
            expectedLogFilePath = fullfile([ testCase.workingDir, '/3Ways/OutDiagVenn3Ways.log']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );
            testCase.verifyEqual( exist(expectedLogFilePath, 'file'), 2 );
            testCase.verifyEqual( result.getClassName, 'biotracs.data.model.DataFileSet' );
            
            expectedCsvFilePath = fullfile([ testCase.workingDir, '/3Ways/OutDiagVenn3Ways.csv']);
            expectedTable = biotracs.data.model.DataTable.import(expectedCsvFilePath);
            [ n, m ] = getSize(expectedTable);
            testCase.verifyEqual(n, 43);
            testCase.verifyEqual(m, 3);
        end
        
        function testVennDiagFour(testCase)
            table= biotracs.data.model.DataFile( [pwd, '/../testdata/DiagVenn4Ways.csv']);
            ds = biotracs.data.model.DataFileSet();
            ds.add(table);
            
            process = biotracs.atlas.model.VennDiagram();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/4Ways/']);
            c.updateParamValue('OutputFileName', 'OutDiagVenn4Ways');
            
            process.run();
            result = process.getOutputPortData('DataFileSet');
                expectedOutputFilePaths = fullfile([ testCase.workingDir, '/4Ways/OutDiagVenn4Ways.png']);
            expectedLogFilePath = fullfile([ testCase.workingDir, '/4Ways/OutDiagVenn4Ways.log']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );
            testCase.verifyEqual( exist(expectedLogFilePath, 'file'), 2 );
            testCase.verifyEqual( result.getLength(), 1 );
            testCase.verifyClass( result.getAt(1), 'biotracs.data.model.DataFile' );
            
            expectedCsvFilePath = fullfile([ testCase.workingDir, '/4Ways/OutDiagVenn4Ways.csv']);
            expectedTable = biotracs.data.model.DataTable.import(expectedCsvFilePath);
            [ n, m ] = getSize(expectedTable);
            testCase.verifyEqual(n, 57);
            testCase.verifyEqual(m, 15);
        end
    end
    
end
