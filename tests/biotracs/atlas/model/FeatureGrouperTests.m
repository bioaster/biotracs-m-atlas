classdef FeatureGrouperTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/dataproc/FeatureGrouperTests');
    end

    methods (Test)
        
        function testFeatureGrouper1(testCase)
            dataSet = biotracs.data.model.DataSet.import('../testdata/nmrdata_bin0.01.csv');
            process = biotracs.atlas.model.FeatureGrouper();
            process.getConfig()...
                .updateParamValue('MaxIsofeatureShift', 0.05)....
                .updateParamValue('RedundancyCorrelation', 0.85)...
                .updateParamValue('RedundancyPValue', 0.05)...
                .updateParamValue('LinkingOrders', 1:6)...
                .updateParamValue('MinNbOfAdjacentFeatures', 1)...
                .updateParamValue('MinNbOfFeaturesPerGroup', 3) ...
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Test1'));
            process.setInputPortData('DataSet', dataSet);
            process.run();
            reducedDataSet = process.getOutputPortData('DataSet');
            redundancyMatrix = process.getOutputPortData('RedundancyMatrix');
            reducedDataSet.export([ fullfile(testCase.workingDir,'Test1'), '/reducedDataSet.mat' ]);
            redundancyMatrix.view(...
                'SparsityPlot', ...
                'SparsityLevels', [1,2] ...
                );
            reducedDataSet.view('FeatureGroupingPlot');
            title('NMR Feature grouping with all for consensus');
            
            isofeatureMap = process.getOutputPortData('IsoFeatureMap');
            isofeatureMapTable = isofeatureMap.toDataTable();
            %isofeatureMap.export('../testdata/isofeaturemap.csv');
            expectedIsoFeatureMapTable = biotracs.data.model.DataTable.import('../testdata/isofeaturemap.csv');
            testCase.verifyEqual(isofeatureMapTable.data, expectedIsoFeatureMapTable.data);
            testCase.verifyEqual(isofeatureMapTable.rowNames, expectedIsoFeatureMapTable.rowNames);
            testCase.verifyEqual(isofeatureMapTable.columnNames, expectedIsoFeatureMapTable.columnNames);
            
            % -------------------------------------------------------------
            % Group using previous results
            % Check that the same result is obtained
            process = biotracs.atlas.model.FeatureGrouper();
            process.getConfig()...
                .updateParamValue('ConsensusFunction', 'mean')....
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Test1-GroupUsingPreviousResults'));
            process.setInputPortData('DataSet', dataSet);
            process.setInputPortData('IsoFeatureMap', isofeatureMap);
            process.run();
            reducedDataSet2 = process.getOutputPortData('DataSet');
            
            testCase.verifyEqual(reducedDataSet2.data, reducedDataSet.data);
            testCase.verifyEqual(reducedDataSet2.rowNames, reducedDataSet.rowNames);
            testCase.verifyEqual(reducedDataSet2.columnNames, reducedDataSet.columnNames);
        end
        
        function testFeatureGrouper2(testCase)
            dataSet = biotracs.data.model.DataSet.import('../testdata/nmrdata_bin0.01.csv');
            process = biotracs.atlas.model.FeatureGrouper();
            process.getConfig()...
                .updateParamValue('MaxIsofeatureShift', 0.05)....
                .updateParamValue('RedundancyCorrelation', 0.85)...
                .updateParamValue('RedundancyPValue', 0.05)...
                .updateParamValue('LinkingOrders', 1:6)...
                .updateParamValue('MinNbOfAdjacentFeatures', 1)...
                .updateParamValue('MinNbOfFeaturesPerGroup', 3)...
                .updateParamValue('MaxNbOfFeaturesToUseForConsensus', 3) ...
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Test2'));
            process.setInputPortData('DataSet', dataSet);
            process.run();
            reducedDataSet = process.getOutputPortData('DataSet');
            reducedDataSet.export([ fullfile(testCase.workingDir,'Test1'), '/reducedDataSet.mat' ]);
            reducedDataSet.view('FeatureGroupingPlot');
            title('NMR Feature grouping with top 3 for consensus');
        end
        
        function testFeatureGrouper3(testCase)
            dataSet = biotracs.data.model.DataSet.import('../testdata/msdata_light2.csv');
            process = biotracs.atlas.model.FeatureGrouper();            
            process.getConfig()...
                .updateParamValue('MaxIsofeatureShift', 0.05)...
                .updateParamValue('RedundancyCorrelation', 0.75)...
                .updateParamValue('RedundancyPValue', 0.05)...
                .updateParamValue('LinkingOrders', 1:6)...
                .updateParamValue('MinNbOfAdjacentFeatures', 1)...
                .updateParamValue('MinNbOfFeaturesPerGroup', 3)....
                .updateParamValue('WorkingDirectory', fullfile(testCase.workingDir,'Test3'));
            process.setInputPortData('DataSet', dataSet);
            process.run();
            reducedDataSet = process.getOutputPortData('DataSet');            
            reducedDataSet.view('FeatureGroupingPlot');
            title('MS Feature grouping with all for consensus');
        end
    end
    
end

