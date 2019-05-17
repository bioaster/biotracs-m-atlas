classdef HCALearnerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/HCATest');
        trainingSet;
        options;
    end
    
    methods (Test)

        function testAll(testCase)
            testCase.doReadData();
            testCase.doTestHca();
            testCase.doTestHcca();
            testCase.doTestCovaWithHca();
            testCase.doTestCovaWithKmeans();
        end
        
    end
    
    methods( Access = protected )
        
        function doReadData(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';
            testCase.trainingSet = biotracs.data.model.DataSet.import(...
                filePath, ...
                'WorkingDirectory', testCase.workingDir ...
            );
            
            %configuration
            testCase.options = struct(...
                'MaxNbClusters', 5,...
                'NbDimensions', 3,...
                'LabelFormat', 'long'...
            );
        end
        
        function doTestHca(testCase)
            clustProcess = biotracs.atlas.model.HCALearner();
            c = clustProcess.getConfig();
            c.updateParamValue('MaxNbClusters', testCase.options.MaxNbClusters);
            c.updateParamValue('Method', 'hca');
            clustProcess.setInputPortData( 'TrainingSet', testCase.trainingSet );
            clustProcess.run();
            clustResult = clustProcess.getOutputPortData('Result');
                       
            %Plot clusters
            clustResult.view( ...
                'ClusterPlot', ...
                'NbDimensions', testCase.options.NbDimensions, ...
				'LabelFormat', testCase.options.LabelFormat ...
			);
            
            %Plot hierarchical tree
            clustResult.view( ...
                'Dendrogram', ...
                'Title', 'Hierachical tree', ...
                'LabelFormat', testCase.options.LabelFormat ...
			);   
        end
        
        function doTestHcca(testCase)
%             return;
            clustProcess = biotracs.atlas.model.HCALearner();
            c = clustProcess.getConfig();
            c.updateParamValue('MaxNbClusters', testCase.options.MaxNbClusters);
            c.updateParamValue('Method', 'hcca');
            clustProcess.setInputPortData( 'TrainingSet', testCase.trainingSet );
            clustProcess.run();
        end
        
        function doTestCovaWithHca(testCase)
%             return;
            Xtr = testCase.trainingSet.getData();
            covXtr = corr(Xtr);
            
            covTraingingSet = biotracs.data.model.DataSet(...
                covXtr, ...
                testCase.trainingSet.getColumnNames(), ...
                testCase.trainingSet.getColumnNames() ...
            );
            
            clustProcess = biotracs.atlas.model.HCALearner();
            c = clustProcess.getConfig();
            c.updateParamValue('MaxNbClusters', testCase.options.MaxNbClusters);
            c.updateParamValue('Method', 'hcca');
            clustProcess.setInputPortData( 'TrainingSet', covTraingingSet );
            clustProcess.run();
        end
        
        function doTestCovaWithKmeans(testCase)
%             return;
            Xtr = testCase.trainingSet.getData();
            covXtr = corr(Xtr);
            
            covTraingingSet = biotracs.data.model.DataSet(...
                covXtr, ...
                testCase.trainingSet.getColumnNames(), ...
                testCase.trainingSet.getColumnNames() ...
            );
            
            clustProcess = biotracs.atlas.model.HCALearner();
            c = clustProcess.getConfig();
            c.updateParamValue('MaxNbClusters', testCase.options.MaxNbClusters);
            clustProcess.setInputPortData( 'TrainingSet', covTraingingSet );
            clustProcess.run();
        end
        
    end
 

end
