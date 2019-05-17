classdef EffectRemoverTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/atlas/dataproc/EffectFilterTests');
    end
    
    methods (Test)
 
        function testRemoveEffectsWithoutRefTests(testCase)
%             return;
            disp(' ')
            disp('* *')
            disp('* Effect fitering without ref')
            disp('* *')
            disp(' ')
            
            rng(1); %fix random number seed
            err = 1+rand(20,50)/1e2;

            %create random 40-by-100 data matrix
            data11 = rand(20,50)+10;   data12 = rand(20,50)+10;
            data21 = data11.*err;      data22 = data12.*err;

            %data21 = rand(20,50)+10;   data22 = rand(20,50)+10;
            data11RowNames = strcat('City:Paris_Rep:', arrayfun(@num2str, 1:20,'UniformOutput',false));
            data21RowNames = strcat('City:Beijin_Rep:', arrayfun(@num2str, 1:20,'UniformOutput',false));
            data11ColNames = strcat('M', arrayfun(@num2str, 1:50,'UniformOutput',false));
            data12ColNames = strcat('F', arrayfun(@num2str, 1:50,'UniformOutput',false));
            
            data11RowNames(1:10) = strcat(data11RowNames(1:10),'_Type:R');
            data21RowNames(1:10) = strcat(data21RowNames(1:10),'_Type:R');
            data11RowNames(11:20) = strcat(data11RowNames(11:20),'_Type:E');
            data21RowNames(11:20) = strcat(data21RowNames(11:20),'_Type:E');

            data = [data11, data12; data21, data22];
            rownames = [data11RowNames, data21RowNames];
            colnames = [data11ColNames, data12ColNames];
            dataSet = biotracs.data.model.DataSet(data, colnames, rownames);

            %additive effect on City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,:) = data(1:20,:) + 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.90 );

            %partial additive effect on last 50 features of City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,50:100) = data(1:20,50:100) + 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.90 );
            
            %--------------------------------------------------------------
            
            %multiplicative effect on City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,:) = data(1:20,:) * 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.90 );
            
            %partial multiplicative effect on last 50 features of City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,50:100) = data(1:20,50:100) * 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.90 );
            
            %--------------------------------------------------------------
            
            %additive + multiplicative effect on City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,:) = (data(1:20,:) + 10) * 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
            
            %partial additive + multiplicative effect on last 50 features of City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,50:100) = (data(1:20,50:100) + 10)*10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
        end

        function testRemoveEffectsWithRefTests(testCase)
            disp(' ')
            disp('* *')
            disp('* Effect fitering with ref')
            disp('* *')
            disp(' ')
            
            err = 1+rand(20,50)/1e2;

            %create random data
            data11 = rand(20,50)+10;    data12 = rand(20,50)+10;
            data21 = data11.*err;        data22 = data12.*err;
            data11RowNames = strcat('City:Paris_Rep:', arrayfun(@num2str, 1:20,'UniformOutput',false));
            data21RowNames = strcat('City:Beijin_Rep:', arrayfun(@num2str, 1:20,'UniformOutput',false));
            data11ColNames = strcat('M', arrayfun(@num2str, 1:50,'UniformOutput',false));
            data12ColNames = strcat('F', arrayfun(@num2str, 1:50,'UniformOutput',false));
            
            data11RowNames(1:10) = strcat(data11RowNames(1:10),'_Type:R');
            data21RowNames(1:10) = strcat(data21RowNames(1:10),'_Type:R');
            data11RowNames(11:20) = strcat(data11RowNames(11:20),'_Type:E');
            data21RowNames(11:20) = strcat(data21RowNames(11:20),'_Type:E');
    
            data = [data11, data12; data21, data22];
            rownames = [data11RowNames, data21RowNames];
            colnames = [data11ColNames, data12ColNames];     
            dataSet = biotracs.data.model.DataSet(data, colnames, rownames);

            %additive effect on City:Paris
            data(1:20,:) = data(1:20,:) + 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
            
            ref = {'Type:R'};
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet, ref);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
            
            %additive + multiplicative effect on City:Paris
            data = [data11, data12; data21, data22];
            data(1:20,:) = (data(1:20,:) + 10) * 10;
            corruptedDataSet = biotracs.data.model.DataSet(data, colnames, rownames);
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
            
            ref = {'Type:R'};
            [ correctedData ] = testCase.removeEffects(dataSet, corruptedDataSet, ref);
            c = corr(correctedData, dataSet);
            testCase.verifyGreaterThan( diag(c.data), 0.95 );
        end

    end
    
    methods(Access = protected)
        
       
        function [filteredDataSet] = removeEffects(testCase, dataSet, corruptedDataSet, ref)
            pca = biotracs.atlas.model.PCALearner();
            c = pca.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pca.setInputPortData('TrainingSet',dataSet);
            pca.run();
            result = pca.getOutputPortData('Result');
            result.view(...
                'ScorePlot', ...
                'GroupList', {'City'}, ...
                'LabelFormat', {'pattern',{'City:([^_]*)','Rep:([^_]*)'}}, ...
                'Title', 'PCA original data', ...
                'Subplot', {2,3,1} ...
                );
            
            %pca on corrupted data
            pca = biotracs.atlas.model.PCALearner();
            c = pca.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pca.setInputPortData('TrainingSet',corruptedDataSet);
            pca.run();
            result = pca.getOutputPortData('Result');
            result.view(...
                'ScorePlot', ...
                'GroupList', {'City'}, ...
                'LabelFormat', {'pattern',{'City:([^_]*)','Rep:([^_]*)'}}, ...
                'Subplot', {2,3,2}, ...
                'Title', 'PCA corrupted data', ...
                'NewFigure', false ...
                );
            
            %pls on corrupted data
            corruptedDataSet.setRowNamePatterns({'City'});
            pls = biotracs.atlas.model.PLSLearner();
            c = pls.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pls.setInputPortData('TrainingSet',corruptedDataSet.createXYDataSet());
            pls.run();
            result = pls.getOutputPortData('Result');
            result.view(...
                'ScorePlot', ...
                'GroupList', {'City'}, ...
                'LabelFormat', {'pattern',{'City:([^_]*)','Rep:([^_]*)'}}, ...
                'Subplot', {2,3,3}, ...
                'Title', 'PLS corrupted data', ...
                'NewFigure', false ...
                );
            
            beta = result.get('RegCoef');
            subplot(2,3,4)
            plot(beta.data);
            title('Effects')
            
            %data filtering (remove 'City' effet)
            filter = biotracs.atlas.model.EffectRemover();
            c = filter.getConfig();
            filter.setInputPortData('DataSet', corruptedDataSet);
            c.updateParamValue('EffectsToRemove',{'City'});
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            if nargin == 4
                c.updateParamValue('ReferenceGroups',ref);
                titleText = ['PCA corrected data (ref)'];
            else
                titleText = ['PCA corrected data (no-ref)'];
            end
            c.updateParamValue('Method','linear');
            filter.run();
            filteredDataSet = filter.getOutputPortData('DataSet');
            
            %> pca on filtered data
            pca = biotracs.atlas.model.PCALearner();
            c = pca.getConfig();
            c.updateParamValue('NbComponents',2);
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            pca.setInputPortData('TrainingSet',filteredDataSet);
            pca.run();
            result = pca.getOutputPortData('Result');
            result.view(...
                'ScorePlot', ...
                'GroupList', {'City'}, ...
                'LabelFormat', {'pattern',{'City:([^_]*)','Rep:([^_]*)'}}, ...
                'Subplot', {2,3,5}, ...
                'Title', titleText, ...
                'NewFigure', false ...
                );
            
            stats = filter.getOutputPortData('Statistics');
            stats.view(...
                'BarPlot', ...
                'NewFigure', false, ...
                'Title', 'Variances', ...
                'Subplot', {2,3,6} ...
                );
        end
        
        
    end
    
end
