% BIOASTER
%> @file		BasePredictor.m
%> @class		biotracs.atlas.model.BasePredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BasePredictor < biotracs.core.mvc.model.Process
    
    properties(Constant)
    end
    
    properties( SetAccess = protected )
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BasePredictor()
            this@biotracs.core.mvc.model.Process();
            
            % enhance outputs specs
            this.addInputSpecs({...
                struct(...
                'name', 'PredictiveModel',...
                'class', 'biotracs.atlas.model.BaseLearnerResult' ...
                ), ...
                struct(...
                'name', 'TestSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                });
        end
        
        function teSet = getTestSet( this )
            teSet = this.getInputPortData('TestSet');
        end
        
        function trSet = getTrainingSet( this )
            predictiveModel = this.getInputPortData('PredictiveModel');
            trainingProcess = predictiveModel.getProcess();
            trSet = trainingProcess.getInputPortData('TrainingSet');
        end
        %function tf = isSupervisedAnalysis( this )
        %    tf = this.getTestSet().hasResponses();
        %end
        %
        %function tf = isDiscriminantAnalysis( this )
        %    tf = this.getTestSet().hasCategoricalResponses();
        %end
        
        function n = getNbTestInstances( this )
            n = this.getTestSet().getNbTrainingInstances();
        end
        
        function n = getNbVariables( this )
            n = this.getTestSet().getNbVariables();
        end
        
        function names = getTestInstanceNames( this )
            names = this.getTestSet().getInstanceNames();
        end
        
        function names = getResponseNames( this )
            names = this.getTestSet().getResponseNames();
        end
        
        function names = getVariableNames( this )
            names = this.getTestSet().getVariableNames();
        end
        
        function names = getInstanceNames( this )
            names = this.getTestSet().getInstanceNames();
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            XYteSet = this.getInputPortData('TestSet');
            if hasEmptyData(XYteSet)
                error('No test set found')
            end

            % Predict
            params = this.config.getParamsAsCell();
            
            % Retrieve Y Predictions and compute statistics
            [ X0te, colNames ] = doFilterAndNormalize( this );
            [ predStructNormalized ] = this.doPredict( X0te, 'FilteredTestSetColumnNames', colNames, params{:} );
            [ predStruct ] = doReverseNormalize( this, predStructNormalized );

            this.doSetPredictorResult( predStruct );
            result = this.getOutputPortData('Result');
            
            % Set prediction stats when the expected outputs are known
            teYSet =  XYteSet.selectYSet();
            predictiveModel = this.getInputPortData('PredictiveModel');
            trainingProcess = predictiveModel.getProcess();
            trYSet = trainingProcess.getInputPortData('TrainingSet').selectYSet();
            if ~hasEmptyData(teYSet) && isfield(predStruct, 'predY0test')
                Y0pred = predStruct.predY0test.mean;
                Y0te = teYSet.data;
                Y0tr = trYSet.data;
                
                YSStot = sum(sum(abs(Y0te).^2, 1));
                YSSreg = sum(sum(abs(Y0te - Y0pred).^2, 1));
                R2 = 1 - YSSreg ./ YSStot;
                
                YSStoti = sum(abs(Y0te).^2, 1);
                YSSregi = sum(abs(Y0te - Y0pred).^2, 1);
                R2i = 1 - YSSregi ./ YSStoti;
                
                if trainingProcess.isDiscriminantAnalysis()
                    Y0th = (min(Y0tr) + max(Y0tr))/2;
                    [ E2i ] = biotracs.atlas.helper.Helper.computeClassificationStatsWithSeparators( Y0te, Y0pred, Y0th );
                    E2 = mean(E2i);
                else
                    E2i = nan(1,size(Y0te,2));
                    E2 = nan(1,1);
                end
            else
                Y0tr = trYSet.data;
                E2i = nan(1,size(Y0tr,2));
                R2i = nan(1,size(Y0tr,2));
                R2 = nan(1,1);
                E2 = nan(1,1);
            end
            
            responseNames = this.getResponseNames();
            stats = biotracs.core.mvc.model.ResourceSet();
            stats.add(biotracs.data.model.DataMatrix(E2i, strcat('E2i_',responseNames)), 'E2Yi');
            stats.add(biotracs.data.model.DataMatrix(R2i, strcat('R2i_',responseNames)), 'R2Yi');
            stats.add(biotracs.data.model.DataMatrix(R2, {'R2'}), 'R2Y');
            stats.add(biotracs.data.model.DataMatrix(E2, {'E2'}), 'E2Y');
            result.set('Stats', stats);
            
            %compuate average scores
            this.doComputeAveragePredictionScores();
            
            % trigger output
            this.setOutputPortData('Result', result);
        end
        
        function [ X0te, colNames ] = doFilterAndNormalize( this )
            predictiveModel = this.getInputPortData('PredictiveModel');
            trainingProcess = predictiveModel.getProcess();
            trSet = trainingProcess.getInputPortData('TrainingSet').selectXSet();
            teSet = this.getInputPortData('TestSet').selectXSet();
            
            uniqueColumnNames = unique(teSet.columnNames);
            if length(teSet.columnNames) ~= length(uniqueColumnNames)
                error('SPECTRA:Learner:ColumnNameDuplicates', 'The column names of the TestSet must be unique');
            end
            
            %filter teSet & sort column names of the trSet to match the teSet
            trSetColNames = regexptranslate('escape',trSet.columnNames);
            teSet = teSet.selectByColumnName( strcat('^',trSetColNames,'$') );
            
            if getSize(trSet,2) ~= getSize(teSet,2)
                error('SPECTRA:PlsPredictor:InvalidTestSet', 'Some features in the TrainingSet does not exist in the TestSet');
            end
            
            X0te = biotracs.math.centerscale( ...
                teSet.getData(), ...
                trSet.getData(), ...
                'Center', trainingProcess.getConfig().getParamValue('Center'), ...
                'Scale', trainingProcess.getConfig().getParamValue('Scale'), ...
                'Direction', trainingProcess.getConfig().getParamValue('StandardizationDirection') ...
                );
            
            colNames = teSet.columnNames;
        end
        
        function predStruct = doReverseNormalize( this, predStruct )
            predictiveModel = this.getInputPortData('PredictiveModel');
            trainingProcess = predictiveModel.getProcess();
            trSet = trainingProcess.getInputPortData('TrainingSet');

            if isfield(predStruct, 'predY0test') && trainingProcess.config.getParamValue('StandardizeOutputs')
                Ytr = trSet.selectYSet().getData();
                predStruct.predY0test.mean = biotracs.math.reversecenterscale( ...
                    predStruct.predY0test.mean, ...
                    Ytr, ...
                    'Center', trainingProcess.getConfig().getParamValue('Center'), ...
                    'Scale', trainingProcess.getConfig().getParamValue('Scale') ...
                    );
                
                predStruct.predY0test.lb = biotracs.math.reversecenterscale( ...
                    predStruct.predY0test.lb, ...
                    Ytr, ...
                    'Center', trainingProcess.getConfig().getParamValue('Center'), ...
                    'Scale', trainingProcess.getConfig().getParamValue('Scale') ...
                    );
                
                predStruct.predY0test.ub = biotracs.math.reversecenterscale( ...
                    predStruct.predY0test.ub, ...
                    Ytr, ...
                    'Center', trainingProcess.getConfig().getParamValue('Center'), ...
                    'Scale', trainingProcess.getConfig().getParamValue('Scale') ...
                    );
            end
            
            if isfield(predStruct, 'predX0test')
                Xtr = trSet.selectXSet().getData();
                predStruct.predX0test = biotracs.math.reversecenterscale( ...
                    predStruct.predX0test, ...
                    Xtr, ...
                    'Center', trainingProcess.getConfig().getParamValue('Center'), ...
                    'Scale', trainingProcess.getConfig().getParamValue('Scale') ...
                    );
            end
        end
        
        % Set prediction results
        % Must be overloaded if required
        function doSetPredictorResult( this, predStruct )
            result = this.getOutputPortData('Result');
            if isfield(predStruct, 'predX0test')
                result.setXPredictionData(predStruct.predX0test);
            end
            
            if isfield(predStruct, 'predY0test')
                result.setYPredictionData(predStruct.predY0test.mean);
                result.setYPredictionDataLowerBounds(predStruct.predY0test.lb);
                result.setYPredictionDataUpperBounds(predStruct.predY0test.ub);
            end
        end
        
        function doComputeAveragePredictionScores(this)
            result = this.getOutputPortData('Result');
            predY = result.get('YPredictions');
            if hasEmptyData(predY), return; end
            [~,q] = size(predY.data);
            
            %compute average
            replicateNamePattern = this.config.getParamValue('ReplicatePatterns');
            if ~isempty(replicateNamePattern)
                strat = biotracs.data.helper.GroupStrategy(this.getInstanceNames(), replicateNamePattern);
                [ oLogicalIndexes, oSliceNames ] = strat.getSlicesIndexes();
                if isempty(oLogicalIndexes)
                    return;
                end
                
                nbRepGroups = size(oLogicalIndexes,2);
                avgData = zeros(nbRepGroups,q);
                stdData = zeros(nbRepGroups,q);
                for i=1:size(oLogicalIndexes,2)
                    idx = oLogicalIndexes(:,i);
                    avgData(i,:) = mean(predY.data(idx,:));
                    stdData(i,:) = std(predY.data(idx,:));
                end
                
                predictiveModel = this.getInputPortData('PredictiveModel');
                trainingProcess = predictiveModel.getProcess();
                colNames = trainingProcess.getInputPortData('TrainingSet').getResponseNames();
                
                avgDataSet = biotracs.data.model.DataSet(avgData, colNames, oSliceNames);
                stdDataSet = biotracs.data.model.DataSet(stdData, colNames, oSliceNames);
                
                result.set('YPredictionMeans', avgDataSet);
                result.set('YPredictionStds', stdDataSet);
            end
        end
        
    end
    
    % -------------------------------------------------------
    % Abstract methods
    % -------------------------------------------------------
    methods(Abstract, Access = protected)
        outputs = doPredict( this, X0te );
    end
    
end
