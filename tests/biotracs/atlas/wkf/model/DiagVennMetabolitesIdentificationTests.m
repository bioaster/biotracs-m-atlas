classdef DiagVennMetabolitesIdentificationTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/atlas/DiagVennMetabolitesIdentificationTests');
    end
    
    methods (Test)
        
        
        function testDiagVennMetabolitesIdentification(testCase)
            a1 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis1.csv']);
            a2 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis2.csv']);
            a3 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis3.csv']);
            a4 = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/MetaboData/Analysis4.csv']);
            
            ds = biotracs.data.model.DataFileSet();
            ds.add(a1);
            ds.add(a2);
            ds.add(a3);
            ds.add(a4);

            diagVenn = biotracs.data.model.DataFile( [pwd, '/../../../../tests/testdata/OutDiagVenn4Ways.csv']);
            outDiagVenn= biotracs.data.model.DataFileSet();
            outDiagVenn.add(diagVenn);
            process = biotracs.atlas.model.DiagVennMetabolitesIdentification();
            c = process.getConfig();
            process.setInputPortData('DataFileSet', ds);
            process.setInputPortData('VennDiagDataFileSet', outDiagVenn);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);

            process.run();
            result = process.getOutputPortData('DataTable');
            result.export([testCase.workingDir, '/MetabolitesIDed.csv']);
            
            expectedOutputFilePaths = fullfile([ testCase.workingDir, '/MetabolitesIDed.csv']);
            testCase.verifyEqual( exist(expectedOutputFilePaths, 'file'), 2 );

            dt = biotracs.data.model.DataTable.import( diagVenn.getPath());
            [ nOriginal, mOriginal ] = getSize(dt);
            [ n, m ] = getSize(result);
            testCase.verifyEqual(nOriginal, n);
            testCase.verifyEqual(mOriginal, m);
        
        end
        
         
        
    end
end