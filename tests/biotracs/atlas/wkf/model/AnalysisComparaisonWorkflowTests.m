classdef AnalysisComparaisonWorkflowTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/atlas/AnalysisComparaisonWorkflowTests');
    end
    
    methods (Test)
        
        
        function testAnalysisComparaisonWorkflow(testCase)
            a1 = ( [pwd, '/../../testdata/MetaboData/Analysis1.csv']);
            a2 = ( [pwd, '/../../testdata/MetaboData/Analysis2.csv']);
            a3 = ( [pwd, '/../../testdata/MetaboData/Analysis3.csv']);
            a4 = ( [pwd, '/../../testdata/MetaboData/Analysis4.csv']);
            
            process = biotracs.atlas.model.AnalysisComparaisonWorkflow();
            process.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir );
            
            dataSetImporter = process.getNode('DataSetImporter');
            
            dataSetImporter.addInputFilePath( a1 );
            dataSetImporter.addInputFilePath( a2 );
            dataSetImporter.addInputFilePath( a3 );
            dataSetImporter.addInputFilePath( a4 );
           
            vennDiagram = process.getNode('VennDiagram');
            vennDiagram.getConfig() ...
                .updateParamValue('OutputFileName', 'OutDiagVenn');

            process.run(); 
        end
        
         
        
    end
end