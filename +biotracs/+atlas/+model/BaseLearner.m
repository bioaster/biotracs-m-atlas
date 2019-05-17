% BIOASTER
%> @file		BaseLearner.m
%> @class		biotracs.atlas.model.BaseLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		6 Mar. 2015

classdef (Abstract) BaseLearner < biotracs.core.mvc.model.Process
    
    properties(Constant)
    end
    
    properties(Access = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseLearner()
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'TrainingSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                });
        end
        
        %-- G --
        
        function trSet = getTrainingSet( this )
            trSet = this.getInputPortData('TrainingSet');
        end
        
        function teSet = getTestSet( this )
            teSet = this.getInputPortData('TestSet');
        end
        
        function n = getNbTrainingInstances( this )
            n = this.getTrainingSet().getNbInstances();
        end
        
        function n = getNbTestInstances( this )
            n = this.getTestSet().getNbInstances();
        end
        
        function n = getNbVariables( this )
            n = this.getTrainingSet().getNbVariables();
        end
        
        function names = getTrainingInstanceNames( this )
            names = this.getTrainingSet().getInstanceNames();
        end
        
        function names = getTestInstanceNames( this )
            names = this.getTestSet().getInstanceNames();
        end
        
        function names = getResponseNames( this )
            names = this.getTrainingSet().getResponseNames();
        end
        
        function names = getVariableNames( this )
            names = this.getTrainingSet().getVariableNames();
        end
        
        %-- I --
        
        function tf = isSupervisedAnalysis( this )
            tf = this.getTrainingSet().hasResponses();
        end
        
        function tf = isDiscriminantAnalysis( this )
            tf = this.getTrainingSet().hasCategoricalResponses();
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.core.mvc.model.Process();
            trSet = this.getInputPortData('TrainingSet');
            this.setIsDeactivated( trSet.hasEmptyData() );
        end
        
        function [stats] = doRun( this )
            verbose = this.config.getParamValue('Verbose');
            XYtrSet = this.getInputPortData('TrainingSet');
            
            colNames = XYtrSet.selectXSet().getColumnNames();
            uniqueColumnNames = unique(colNames);
            if length(colNames) ~= length(uniqueColumnNames)
                error('SPECTRA:Learner:ColumnNameDuplicates', 'The column names of the TrainingSet must be unique');
            end
            
            Xtr = XYtrSet.selectXSet().getData();
            Ytr = XYtrSet.selectYSet().getData();
            
            if verbose
                this.logger.writeLog('Data size:\n\t\t X: %d rows, %d columns\n\t\t Y: %d rows, %d columns', size(Xtr), size(Ytr));
            end
            
            if isempty(Xtr)
                error('SPECTRA:Learner:TrainingSetNotDefined','No input X found in the training set');
            end

            [ Xtr, Ytr ] = this.doNormalize();
            
            kfold = this.config.getParamValue('kFoldCrossValidation');
            if kfold == Inf
                kfold = getSize(XYtrSet,1); %leave-one-out
            end
            
            mcrep = this.config.getParamValue('MonteCarloRepetition');
            ncperm = this.config.getParamValue('MonteCarloPermutation');
            responseNames = XYtrSet.getResponseNames();
            variableNames = XYtrSet.getVariableNames();
            
            if this.isSupervisedAnalysis()
                this.doLearn(Xtr, Ytr);
                %cross-validation learning
                if kfold > 1
                    this.doLearnCv( Xtr, Ytr, 'kFoldCrossValidation', kfold, 'MonteCarloRepetition', mcrep, 'ResponseNames', responseNames, 'VariableNames', variableNames );
                end
                %permutation tests
                if ncperm > 0
                    this.doLearnPerm(Xtr, Ytr);
                end
            else
                this.doLearn( Xtr );
                %cross-validation learning
                if kfold > 1
                    this.doLearnCv( Xtr, 'kFoldCrossValidation', kfold, 'MonteCarloRepetition', mcrep, 'ResponseNames', responseNames, 'VariableNames', variableNames );
                end
                %permutation tests
                if ncperm > 0
                    this.doLearnPerm(Xtr);
                end
            end
        end
        
        function [Xtr, Ytr] = doNormalize( this )
            XYtrSet = this.getInputPortData('TrainingSet');
            Xtr = XYtrSet.selectXSet().getData();
            Ytr = XYtrSet.selectYSet().getData();
            
            %log tranformation
            if this.config.isParamValueEqual('LogTransform', true)
                idx = (Xtr == 0);
                if ~isempty(idx)
                    Xtmp =  Xtr;
                    Xtmp(idx) = Inf;
                    minVal = min(Xtmp(:));
                    Xtr(idx) = minVal * 0.01;
                end
                Xtr = log2(Xtr);
            end
            
            Xtr = biotracs.math.centerscale( ...
                Xtr, [], ...
                'Center' , this.config.getParamValue('Center'), ...
                'Scale', this.config.getParamValue('Scale'), ...
                'Direction', this.config.getParamValue('StandardizationDirection') ...
                );
            
            %centering and scaling
            if this.isSupervisedAnalysis()
                if isempty(Ytr)
                    error('SPECTRA:Learner:TrainingSetOutputNotDefined', 'No outputs Y found in the training set');
                end
                
                if this.isDiscriminantAnalysis()
                    indexesOfInstancesAssociatedWithNoOutputs = (sum(Ytr,2) == 0);
                    if any(indexesOfInstancesAssociatedWithNoOutputs)
                        error( 'No outputs Y is associated with instance %s\n', XYtrSet.rowNames{indexesOfInstancesAssociatedWithNoOutputs} );
                    end
                end
                
                if this.config.getParamValue('StandardizeOutputs')
                    Ytr = biotracs.math.centerscale( ...
                        Ytr, [], ...
                        'Center' , this.config.getParamValue('Center'), ...
                        'Scale', this.config.getParamValue('Scale'), ...
                        'Direction', this.config.getParamValue('StandardizationDirection') ...
                        );
                end
            end
        end
        
    end
    
    % -------------------------------------------------------
    % Abstract methods
    % -------------------------------------------------------
    methods(Abstract, Access = protected)
        % Perfoms learning without cross-validation/validation
        doLearn( this, X0train, Y0train, varargin );
        
        % Perfoms learning and cross-validation to assess model perfomance
        % If a ValidationSet is given, it should be further used to adjust
        % model perfomances
        doLearnCv( this, X0train, Y0train, varargin )
        
        % Performs permutation tests to assess model relevance
        doLearnPerm( this, X0train, Y0train, varargin )
    end
    
end
