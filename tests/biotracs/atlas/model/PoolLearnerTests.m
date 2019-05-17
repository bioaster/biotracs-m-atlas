classdef PoolLearnerTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/stats/PoolLearnerTests');
    end
    
    methods (Test)
            
        function testPooler(testCase)
            filePath = '../testdata/metabo1/metabolites.xlsx';           
            trSet = biotracs.data.model.DataSet.import( filePath );
            trSet.setRowNamePatterns({'Group'});
            trSet = trSet.createXYDataSet();

            %use deterministic random stream
            s1 = RandStream.create('mt19937ar','Seed', 0);
            s0 = RandStream.setGlobalStream(s1);

            poolingVariables = biotracs.atlas.model.SelectedVariableDataMatrix.import('../testdata/mpool/metabo1/SelectedModelMap.csv');

            %model pooler
            learner = biotracs.atlas.model.PoolLearner();
            learner.getConfig()...
                .updateParamValue('CorrelationThreshold', 0.85)...
                .updateParamValue('CorrelationPValue', 0.001 );
            learner.setInputPortData( 'TrainingSet', trSet );
            learner.setInputPortData( 'PoolingVariables', poolingVariables );
            learner.run();
            poolerResult = learner.getOutputPortData('Result');
            %poolingMap = poolerResult.get('PoolingMap');
            
            poolerResult.view('PoolingMapPlot');
            poolerResult.view('PoolingMapGraph');

            %Restore random stream
            RandStream.setGlobalStream(s0);
        end
     
        
    end
    
    methods
        
    end
    
end
