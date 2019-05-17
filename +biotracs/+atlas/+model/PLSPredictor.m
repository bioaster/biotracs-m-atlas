% BIOASTER
%> @file		PLSPredictor.m
%> @class		biotracs.atlas.pls.model.PLSPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PLSPredictor < biotracs.atlas.model.BaseDecompPredictor
    
    properties(Constant)
    end
    
    properties(SetAccess = private)
        scoringMultiplier = 1.5;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PLSPredictor()
            this@biotracs.atlas.model.BaseDecompPredictor();
            
            % enhance existing input specs
            this.updateInputSpecs({...
                struct(...
                'name', 'PredictiveModel',...
                'class', 'biotracs.atlas.model.PLSLearnerResult' ...
                )...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PLSPredictorResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        
        function [ predStruct ] = doPredict( this, X0te, varargin )
            predictiveModel = this.getInputPortData('PredictiveModel');
            YL = predictiveModel.getYLoadingData();
            W = predictiveModel.getWeightData();
            verbose = this.config.getParamValue('Verbose');
            ncomp = this.config.getParamValue('NbComponents');
            if isempty(ncomp)
                this.logger.writeLog('%s','Nunber of compoenents not provided. Try to determine the optimal number of components to use');
                ncomp = predictiveModel.getOptimalNbComponents();
                if isempty(ncomp)
                    ncomp = size(W,2);
                end
            end
            
            cvB = predictiveModel.get('CrossValidationRegCoef').getData();
            
            if ~isempty(cvB)
                if verbose
                    this.logger.writeLog('%s','Use the cross-validated model');
                end
                %[A,n,p] = size( cvB.mean );
                A = length(cvB.mean);
                if ncomp > A
                    ncomp = A;
                    if verbose
                        this.logger.writeLog('Warning: only %d components are available', A);
                    end
                end
                
                %meanB = reshape( cvB.mean(ncomp,:,:),n,p );
                %stdB = reshape( cvB.std(ncomp,:,:),n,p );
                meanB = cvB.mean{ncomp};
                stdB = cvB.std{ncomp};
            else
                if verbose
                    this.logger.writeLog('%s', 'No cross-validation model found');
                end
                A = size(W,2);
                if ncomp > A
                    ncomp = A;
                    if verbose
                        this.logger.writeLog('%s', 'Warning: only %d components are available', A);
                    end
                end
                
                if ncomp == A
                    meanB = predictiveModel.getRegCoef().getData();
                else
                    %recompute B for the ncomp first components
                    meanB = W(:,1:ncomp)*YL(:,1:ncomp)';
                end
                stdB = zeros( size(meanB) );
            end
            
            predY0te.mean       = X0te * meanB;                         % Y0pred = XS*YL' = (X0*W)*YL'  <=>  X0*beta
            predY0te.lb         = X0te * (meanB - 1.96 * stdB);			% Ypred CI95 lower bound (jackknife)
            predY0te.ub         = X0te * (meanB + 1.96 * stdB);			% Ypred CI95 lower bound (jackknife)
            %projY0teOnScores    = predY0te.mean * YL(:,1:ncomp);       % YS = Y0*YL
            projX0teOnScores    = X0te * W(:,1:ncomp);                  % XS = X0*W
            %predX0te            = projX0teOnScores * XL(:,1:ncomp)';   % X0pred = XS*XL' = (X0*W)*XL'
            
            predStruct = struct(...
                'predY0test', predY0te, ...
                'projX0test', projX0teOnScores ...
                );
        end
        
        function doSetPredictorResult( this, predStruct )
            this.doSetPredictorResult@biotracs.atlas.model.BasePredictor(predStruct);
        end
        
        function doComputeAveragePredictionScores(this)
            this.doComputeAveragePredictionScores@biotracs.atlas.model.BasePredictor();
            predictiveModel = this.getInputPortData('PredictiveModel');
            trYSet          = predictiveModel.getTrainingSet().selectYSet();
            trYSetPred      = predictiveModel.getYPredictions();
            
            
            if predictiveModel.isDiscriminantAnalysis()
                teYPred = this.getOutputPortData('Result').get('YPredictions');
                [n,q] = size(teYPred.data);
                logicalYSet = logical(trYSet.data);
                scoreData = zeros(n,q);
                for i=1:q
                    idx = logicalYSet(:,i); 
                    trData = trYSetPred.data(idx,i);        %data of the ith moa
                    teData = teYPred.data(:,i);           %prediction of the ith moa
                    
                    mu = mean(trData);
                    sigma= std(trData)*this.scoringMultiplier;
                    scoreData(:,i) = exp(-(teData-mu).^2./(2*sigma.^2));    %project all the predictions on the ith moa
                end
                scoreDataSet = biotracs.data.model.DataSet(scoreData, teYPred.columnNames, teYPred.rowNames);
                
                %compute average scores
                replicateNamePattern = this.config.getParamValue('ReplicatePatterns');
                if ~isempty(replicateNamePattern)
                    replicateNamePattern = this.config.getParamValue('ReplicatePatterns');
                    strat = biotracs.data.helper.GroupStrategy(teYPred.rowNames, replicateNamePattern);
                    [ oLogicalIndexes, oSliceNames ] = strat.getSlicesIndexes();

                    nbRepGroups = size(oLogicalIndexes,2);
                    avgScoreData = zeros(nbRepGroups,q);
                    stdScoreData = zeros(nbRepGroups,q);
                    for i=1:nbRepGroups
                        idx = oLogicalIndexes(:,i);
                        avgScoreData(i,:) = mean(scoreData(idx,:));
                        stdScoreData(i,:) = std(scoreData(idx,:));
                    end
                    avgScoreDataSet = biotracs.data.model.DataSet(avgScoreData, teYPred.columnNames, oSliceNames);
                    stdScoreDataSet = biotracs.data.model.DataSet(stdScoreData, teYPred.columnNames, oSliceNames);

                    %set result
                    result = this.getOutputPortData('Result');
                    result.set('YPredictionScores', scoreDataSet);
                    result.set('YPredictionScoreMeans', avgScoreDataSet);
                    result.set('YPredictionScoreStds', stdScoreDataSet);
                end
            end
        end
        
    end
    
    
end
