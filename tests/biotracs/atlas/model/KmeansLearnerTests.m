classdef KmeansLearnerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/KMeansTests');
        trainingSet;
    end
    
    methods (Test)

        function testAll(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';
            trSet = biotracs.data.model.DataSet.import(filePath, 'WorkingDirectory', testCase.workingDir);
            
            %run process
            kmeans = biotracs.atlas.model.KmeansLearner();
            kmeans.getConfig()...
                .updateParamValue('MaxNbClusters', 2)...
                .updateParamValue('Method', 'kmeans');
            kmeans.setInputPortData( 'TrainingSet', trSet );
            kmeans.run();
            result = kmeans.getOutputPortData('Result');
            
            %plot
            result.view( ...
                'ClusterPlot', ...
                'NbDimensions', 2, ...
				'LabelFormat', 'lonh' ...
			);
        end
    end
    
    
    methods( Static )

    end

end
