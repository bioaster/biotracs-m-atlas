% BIOASTER
%> @file		PLSLearner.m
%> @class		biotracs.atlas.pls.model.PLSLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PLSLearner < biotracs.atlas.model.BaseDecompLearner
    
    properties(Constant)
    end
    
    properties(Access = private)
        W;XL;YL;XS;YS;varExp;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PLSLearner()
            %#function biotracs.atlas.pls.model.PLSLearnerConfig biotracs.atlas.model.PLSLearnerResult
            
            this@biotracs.atlas.model.BaseDecompLearner();
            this.setDescription('Partial least square (PLS) process');
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PLSLearnerResult' ...
                )...
                });
        end
 
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doLearn( this, X0, Y0 )
            verbose = this.config.getParamValue('Verbose');
            oYtr = this.getInputPortData('TrainingSet')...
                .selectYSet()...
                .getData();
            
            if nargin < 3
                error('SPECTRA:Learner:BothInputAndResponseVariableAreRequired', 'Both X0 and Y0 are required');
            end
            
            if nargin < 2
                error('SPECTRA:Learner:ResponsesVariableAreRequired', 'Y0 is required');
            end
            
            if isempty(X0)
                error('SPECTRA:Learner:EmptyInputVariables', 'X0 is empty. Please check data.');
            end
            
            if isempty(Y0)
                error('SPECTRA:Learner:EmptyResponseVariables', 'Y0 is empty. Please check data');
            end
            
            [m, n] = size(X0);
            q = size(Y0,2);
            
            ncomp = this.config.getParamValue('NbComponents');
            %update ncomp if necessary
            ncompMax = min([ m-1, n, ncomp]);
            if ncomp > ncompMax
                if verbose
					this.logger.writeLog('Warning: only %d components computed', ncompMax); 
				end
                ncomp = ncompMax;
            end
            
            %Simpls
            this.simpls(X0,Y0,ncomp);
            
            %compute beta
            beta = this.W*this.YL';

            % MSE
            stats.MSEE_X = zeros(ncomp,1);
            stats.MSEE_Y = zeros(ncomp,1);
            stats.MSEE_Yi = zeros(ncomp,q);
            
            % R2X
            stats.R2X = zeros(ncomp,1);
            stats.adjR2X = zeros(ncomp,1);
            
            % R2Y
            stats.R2Y = zeros(ncomp,1);
            stats.adjR2Y = zeros(ncomp,1);
            stats.R2Yi = zeros(ncomp,q);
            stats.adjR2Yi = zeros(ncomp,q);
            
            % E2
            stats.E2i = nan(ncomp,q);
            stats.E2 = nan(ncomp,1);
            %stats.MCR = zeros(ncomp,1);
            
            % Probs
%             probs = cell(1,ncomp);
%             % Class info
%             if this.isDiscriminantAnalysis
%                 stats.classInfo = cell(ncomp,1);
%             end
            
            % Class info
            if this.isDiscriminantAnalysis
                Y0th = (min(Y0) + max(Y0))/2;
                unormalizedY0th = biotracs.math.reversecenterscale( ...
                    Y0th, ...
                    oYtr, ...
                    'Center', this.getConfig().getParamValue('Center'), ...
                    'Scale', this.getConfig().getParamValue('Scale') ...
                    );
                stats.ClassSep = [Y0th; unormalizedY0th];
            end
            
            XSStot = sum(sum(abs(X0).^2, 1));
            YSStot = sum(sum(abs(Y0).^2, 1));
            YiSStot = sum(abs(Y0).^2, 1);       %sum of square of each output
            
            % VIP
            vip = zeros(n,ncomp);
            
            instanceNames = this.getTrainingInstanceNames();
            variableNames = this.getVariableNames();
            responseNames = this.getResponseNames();

            for i = 1:ncomp
                % XS = X0*W, YS = Y0*W
                X0pred = this.XS(:,1:i) * this.XL(:,1:i)'; % X0pred = XS*XL' = (X0*W)*XL'
                Y0pred = this.XS(:,1:i) * this.YL(:,1:i)'; % Y0pred = XS*YL' = (X0*W)*YL'  <=>  X0*beta
                
                % R2X, RMSEE X, R2X ...
                XSSres = sum(sum(abs(X0 - X0pred).^2, 1));
                stats.MSEE_X(i) = XSSres / (m*n);
                stats.R2X(i) = 1 - XSSres ./ XSStot;
                stats.adjR2X(i) = 1 - (1-stats.R2X(i))*(m-1)/(m-ncomp-1);
                
                % R2Y, RMSEE Y, R2Y ...
                YSSres = sum(sum(abs(Y0 - Y0pred).^2, 1));
                stats.MSEE_Y(i) = YSSres / (m*q);
                stats.R2Y(i) = 1 - YSSres ./ YSStot;
                stats.adjR2Y(i) = 1 - (1-stats.R2Y(i))*(m-1) ./ (m-ncomp-1);
                
                % R2Y, RMSEE Y, R2Y ...
                YiSSres = sum(abs(Y0 - Y0pred).^2, 1);
                stats.MSEE_Yi(i,:) = YiSSres ./ (m*q);
                stats.R2Yi(i,:) = 1 - YiSSres ./ YiSStot;
                stats.adjR2Yi(i,:) = 1 - (1-stats.R2Yi(i,:))*(m-1) ./ (m-ncomp-1);
                
                % Confusion matrix
                if this.isDiscriminantAnalysis
                    [ E2 ] = biotracs.atlas.helper.Helper.computeClassificationStatsWithSeparators( Y0, Y0pred, Y0th );
                    stats.E2i(i,:) = E2;
%                     [ E2, info ] = biotracs.atlas.helper.Helper.computeOptimalClassificationStats( Y0, Y0pred, oYtr );
%                     stats.E2i(i,:) = E2;
%                     stats.classInfo{i} = info;                    
                end

                vip(:,i) = this.doComputeVip(i);
            end

            stats.E2 = mean(stats.E2i,2);    %total E2            
            result = this.getOutputPortData('Result');
            result.setXLoadingData(this.XL, variableNames);
            result.setYLoadingData(this.YL, responseNames);
            result.setXScoreData(this.XS, instanceNames);
            result.setYScoreData(this.YS, instanceNames);
            result.setWeightData(this.W);
            result.setRegCoefData(beta, responseNames, variableNames);
            result.setVipData( vip, variableNames );
            result.setStatData( stats, responseNames, 'PC' );
            result.setXResidualData(X0 - X0pred, variableNames, instanceNames);
            result.setYResidualData(Y0 - Y0pred, responseNames, instanceNames);
            result.setXVarExplainedData(this.varExp(1,:));
            result.setYVarExplainedData(this.varExp(2,:));

            % Set and propagate data
            this.setOutputPortData('Result', result);
        end
        
        function doLearnCv( this, Xtr, Ytr, varargin )
            p = inputParser();
            p.addParameter('kFoldCrossValidation',1,@(x)( isscalar(x) && x>1) );
            p.addParameter('MonteCarloRepetition',1,@(x)( isscalar(x) && x>=1) );
            p.addParameter('ResponseNames',{},@iscell );
            p.addParameter('VariableNames',{},@iscell );
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            verbose = this.config.getParamValue('Verbose');
            [m, n] = size(Xtr);
            q = size(Ytr,2);
%             oYtr = this.getInputPortData('TrainingSet')...
%                 .selectYSet()...
%                 .getData();
            
			kfold = p.Results.kFoldCrossValidation;
			
            if kfold <= 1
                error('Cross-validation kfold must be greater than 1');
            end
            
			if kfold == Inf
				kfold = m;
			end
			
            if kfold == m
                if verbose
                    this.logger.writeLog('%s','Warning: leave-one-out is used, the Monte Carlo repetition number is forced to 1'); 
                end
                mcrep = 1;
            else
                mcrep = p.Results.MonteCarloRepetition;
            end
            
            % Compute the fisrt (master) cv partition and the effective total number of partitions
            masterCVPartitions = cvpartition(m,'k', kfold);
            totalNumTestSets = masterCVPartitions.NumTestSets * mcrep;
            
            % nb components
            ncomp = this.config.getParamValue('NbComponents');
            
            minTrainSize = min(masterCVPartitions.TrainSize);
            ncompMax = min([ minTrainSize-1, n, ncomp]);
            if ncomp > ncompMax
                 if verbose
                     this.logger.writeLog('Warning: only %d components computed',ncompMax); 
                 end
                ncomp = ncompMax;
            end
            
            % Regesssion coefficients
            meanB = cell(1,ncomp);
            stdB  = cell(1,ncomp);
            for i=1:ncomp
                meanB{i} = zeros(n,q);
                stdB{i}  = zeros(n,q);
            end
            
            % VIP
            meanVip = zeros(n,ncomp);
            stdVip  = zeros(n,ncomp);
            
            % Stats
            stats.MSEP_X = zeros(ncomp,1);
            stats.MSEP_Y = zeros(ncomp,1);
            stats.MSEP_Yi = zeros(ncomp,q);
            stats.Q2X = zeros(ncomp,1);
            stats.Q2Y = zeros(ncomp,1);
            stats.Q2Yi = zeros(ncomp,q);
            stats.CV_E2 = nan(ncomp,1);
            stats.CV_E2i = nan(ncomp,q);
            
%             if this.isDiscriminantAnalysis
%                 stats.CVClassInfo = cell(ncomp,1);
%             end
            
            % Yte, Ypred, Xte, Xpred
            totalTestedInstances = m * mcrep;
            knownGroup = cell(1,ncomp);
            predGroup = cell(1,ncomp);
            for i=1:ncomp
                knownGroup{i} = zeros(totalTestedInstances,q);
                predGroup{i} = cell(totalTestedInstances,1);
            end
            
            stackedYte = zeros(totalTestedInstances,q);
            stackedXte = zeros(totalTestedInstances,n);
%             stackedOriginalY0te = zeros(totalTestedInstances,q);
            stackedYpred = cell(1,ncomp);
            stackedXpred = cell(1,ncomp);
            for i=1:ncomp
                stackedYpred{i} = zeros(totalTestedInstances,q);
                stackedXpred{i} = zeros(totalTestedInstances,n);
            end
            
            CVYpred = cell(1,ncomp);
            
%             if this.isDiscriminantAnalysis
%                 stackedYth = zeros(totalTestedInstances,q);
%             end
            
            if verbose
                biotracs.core.env.Env.writeLog('Cross-validation learning with\n\t\t kfold:\t%d\n\t\t mcrep:\t%d\n\t\t totalNumTestSets:\t%d\n\t\t ncomp:\t%d', kfold, mcrep, totalNumTestSets, ncomp);
            end

            % Reset component params
            crossValIter = 0;
            stackStartIdx = 1;
            
            if verbose
                w = biotracs.core.waitbar.Waitbar('Name', 'Cross-validation');
                w.show();
            end
            
            for h = 1:mcrep
                cvPartitions = masterCVPartitions.repartition();    %resample partitions
                for k = 1:cvPartitions.NumTestSets
                    crossValIter = crossValIter+1;
                    if verbose
						w.show(crossValIter/totalNumTestSets)
                    end
                    
                    trIdx = cvPartitions.training(k);
                    teIdx = cvPartitions.test(k);
                    
                    % Extract training and test subsets
                    X0tr = Xtr(trIdx,:);
                    Y0tr = Ytr(trIdx,:);
                    X0te = Xtr(teIdx,:);
                    Y0te = Ytr(teIdx,:);
%                     oY0te = oYtr(teIdx,:);
                    
                    % Center/scale subsets
                    X0te = biotracs.math.centerscale( X0te, X0tr, 'Center' , true, 'Scale', 'none' );	%it not necessary to scale again
                    Y0te = biotracs.math.centerscale( Y0te, Y0tr, 'Center' , true, 'Scale', 'none' );
                    X0tr = biotracs.math.centerscale( X0tr, [], 'Center' , true, 'Scale', 'none' );
                    Y0tr = biotracs.math.centerscale( Y0tr, [], 'Center' , true, 'Scale', 'none' );

                    % Stack predictions
                    nbTestedInstances = size(Y0te,1);
                    stackEndIdx = (stackStartIdx + nbTestedInstances - 1);
                    stackIdx = stackStartIdx : stackEndIdx;
                    stackedXte(stackIdx,:) = X0te;
                    stackedYte(stackIdx,:) = Y0te;
                    %stackedOriginalY0te(stackIdx,:) = oY0te;
                    stackStartIdx = stackEndIdx + 1;
                    
                    % Fit the full model, models with 1:(ncomp-1) components are nested within
                    this.simpls(X0tr,Y0tr,ncomp);
                    XSte = X0te * this.W;	 %proj of Xte in scores space = Xte score
                        
                    % Class separator
                    if this.isDiscriminantAnalysis
                        Y0th = (min(Y0tr) + max(Y0tr))/2;
%                         stackedYth(stackIdx,:) = Y0th;
                    end
                    
                    for i = 1:ncomp
                        XPred = XSte(:,1:i) * this.XL(:,1:i)';
                        Ypred = XSte(:,1:i) * this.YL(:,1:i)';
                        
                        stackedXpred{i}(stackIdx,:) = XPred;
                        stackedYpred{i}(stackIdx,:) = Ypred;

                        % Regression coeficients
                        B0 = this.W(:,1:i)*this.YL(:,1:i)';

                        if crossValIter == 1
                            meanB{i} = B0;
                        else
                            stdB{i} = (crossValIter-2)/(crossValIter-1) .* stdB{i}.^2 + (1/crossValIter) .* (B0 - meanB{i}).^2;
                            meanB{i} = ((crossValIter-1)*meanB{i} + B0) ./ crossValIter;
                        end

                        % Vip
                        vip = this.doComputeVip(i);
                        if crossValIter == 1
                            meanVip(:,i) = vip;
                        else
                            stdVip(:,i) = (crossValIter-2)/(crossValIter-1) .* stdVip(:,i).^2 + (1/crossValIter) .* (vip - meanVip(:,i)).^2;
                            meanVip(:,i) = ((crossValIter-1)*meanVip(:,i) + vip)./crossValIter;
                        end

                        if this.isDiscriminantAnalysis
                            for sIdx = 1:nbTestedInstances
                                knownGroup{i}(stackIdx(sIdx),:) = find( Y0te(sIdx,:) > Y0th );
                                predGroup{i}{stackIdx(sIdx)} =  find( Ypred(sIdx,:) > Y0th );
                            end
                        end
                    end
                end
            end
            
            
            stdVip = sqrt(stdVip);
            stdB = cellfun( @sqrt, stdB, 'UniformOutput', false );
      
            XSStot = sum(sum(abs(stackedXte).^2, 1));
            YSStot = sum(sum(abs(stackedYte).^2, 1));
            YSStoti = sum(abs(stackedYte).^2, 1);
            oYtr = this.getInputPortData('TrainingSet').selectYSet();    %original training set
            for i=1:ncomp
                %Predictions
                CVYpred{i} = Xtr * meanB{i};   %prediction of all data
                CVYpred{i} = biotracs.math.reversecenterscale( ...
                    CVYpred{i}, ...
                    oYtr.data, ...
                    'Center', this.getConfig().getParamValue('Center'), ...
                    'Scale', this.getConfig().getParamValue('Scale') ...
                    );
                
                % Statistics
                XSSreg = sum(sum(abs(stackedXte - stackedXpred{i}).^2, 1));
                stats.MSEP_X(i) = XSSreg/(totalTestedInstances*n);
                stats.Q2X(i) = 1 - XSSreg ./ XSStot;
                
                YSSreg = sum(sum(abs(stackedYte - stackedYpred{i}).^2, 1));
                stats.MSEP_Y(i) = YSSreg/(totalTestedInstances*q);
                stats.Q2Y(i) = 1 - YSSreg ./ YSStot;
                
                YSSreg = sum(abs(stackedYte - stackedYpred{i}).^2, 1);
                stats.MSEP_Yi(i,:) = YSSreg/(totalTestedInstances);
                stats.Q2Yi(i,:) = 1 - YSSreg ./ YSStoti;
                
                if this.isDiscriminantAnalysis
                    [ E2 ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroup{i}, predGroup{i} );
                    stats.CV_E2(i) = mean(E2);
                    stats.CV_E2i(i,:) = E2;
                end
            end

            % Set result
            result = this.getOutputPortData('Result');
            result.setStatData( stats, p.Results.ResponseNames, 'PC' );
            result.setCrossValidationVipData( meanVip, stdVip, p.Results.VariableNames );
            result.setCrossValidationRegCoefData( meanB, stdB, p.Results.ResponseNames, p.Results.VariableNames );
            result.set('CrossValidationVariableRanking', result.getCrossValidationVariableRanking());
            
            optNbComps = biotracs.data.model.DataMatrix(result.getOptimalNbComponents(), {'OptimalNbComponents'});
            result.set('OptimalNbComponents', optNbComps);

            if this.isDiscriminantAnalysis()
                Yth = (min(Ytr) + max(Ytr))/2;
                result.setYPredictions( CVYpred, Yth );
            else
                result.setYPredictions( CVYpred );
            end 
            
        end

        function doLearnPerm( this, X0, Y0, varargin )
            [m, n] = size(X0);
            verbose = this.config.getParamValue('Verbose');
            mcperm = this.config.getParamValue('MonteCarloPermutation');
            ncomp = this.config.getParamValue('NbComponents');          

            %update ncomp if necessary
            ncompMax = min([ m-1, n, ncomp]);
            if ncomp > ncompMax
                if verbose
                    this.logger.writeLog('Warning: at most %d components could be computed', ncompMax); 
                end
                ncomp = ncompMax;
            end
            
            % Allocate memory
            % R2Y
            stats.permR2Y = zeros(mcperm,1);
            stats.permAdjR2Y = zeros(mcperm,1);

            % E2
            stats.permE2 = zeros(mcperm,1);
            
            % vip
            stats.permVip = zeros(mcperm,1);
            
            if verbose
                fprintf( 'Permutation tests with\n\t\t mcperm:\t%d\n\t\t ncomp:\t%d\n', mcperm, ncomp );
            end
            
            Y0s = Y0;
            expectedY0th = (min(Y0) + max(Y0))/2;
            estimatedY0th = expectedY0th;

			if verbose
				w = biotracs.core.waitbar.Waitbar('Name', 'Permutations');
				w.show();
			end
			
            for i = 1:mcperm
                if verbose
					w.show(i/mcperm);
                end
                
                %Permute data labels
                permIdx = randperm(m);
                Y0 = Y0s(permIdx,:);
                
                % Simpls
                this.simpls(X0,Y0,ncomp);
                
                % XS = X0*W, YS = Y0*W
                Y0pred = this.XS(:,1:ncomp) * this.YL(:,1:ncomp)'; % Y0pred = XS*YL' = (X0*W)*YL'  <=>  X0*beta

                % R2Y, RMSEE Y, R2Y ...
                YSStot = sum(sum(abs(Y0).^2, 1));
                YSSres = sum(sum(abs(Y0 - Y0pred).^2, 1));
                stats.permR2Y(i) = 1 - YSSres ./ YSStot;
                stats.permAdjR2Y(i) = 1 - (1-stats.permR2Y(i))*(m-1) ./ (m-ncomp-1);

                % Confusion matrix
                if this.isDiscriminantAnalysis
                    predGroup = cell(1,m);
                    knownGroup =  zeros(1,m);

                    for k=1:m
                        knownGroup(k) = find( Y0(k,:) > expectedY0th );
                        predGroup{k} =  find( Y0pred(k,:) > estimatedY0th );
                    end
                    [ E2 ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroup, predGroup );
                    stats.permE2(i) = mean(E2); %mean E
                end
                
                vip = this.doComputeVip();
                stats.permVip(i) = max(vip);
            end
            
            result = this.getOutputPortData('Result');
            result.setStatData( stats, [], 'PC' );
        end
        
        %SIMPLS Basic SIMPLS.  Performs no error checking.
        %function [Weights,Xloadings,Yloadings,Xscores,Yscores,varExp] = simpls(~, X0, Y0, ncomp)
        function simpls(this, X0, Y0, ncomp)
            [n,dx] = size(X0);
            dy = size(Y0,2);
            ncomp = min([ncomp, n-1,dx ]);
            
            % Preallocate outputs
            this.XL = zeros(dx,ncomp);
            this.YL = zeros(dy,ncomp);
            this.XS = zeros(n,ncomp);
            this.YS = zeros(n,ncomp);
            this.W = zeros(dx,ncomp);
            
            % An orthonormal basis for the span of the X loadings, to make the successive
            % deflation X0'*Y0 simple - each new basis vector can be removed from Cov
            % separately.
            V = zeros(dx,ncomp);
            
            Cov = X0'*Y0;
            
            for i = 1:ncomp
                % Find unit length ti=X0*ri and ui=Y0*ci whose covariance, ri'*X0'*Y0*ci, is
                % jointly maximized, subject to ti'*tj=0 for j=1:(i-1).
                [ri,si,ci] = svd(Cov,'econ'); ri = ri(:,1); ci = ci(:,1); si = si(1);
                
                %sparse PLS
                %find sparse ri such as ti = X0*ri
                %[sd, sl] = spasm.spca( Cov );
                
                %compute score ti
                ti = X0*ri;
                normti = norm(ti); ti = ti ./ normti; % ti'*ti == 1
                this.XL(:,i) = X0'*ti;
                
                qi = si*ci/normti; % = Y0'*ti
                %qi = Y0'*ti;
                this.YL(:,i) = qi;
                
                this.XS(:,i) = ti;
                this.YS(:,i) = Y0*qi; % = Y0*(Y0'*ti), and proportional to Y0*ci
                this.W(:,i) = ri ./ normti; % rescaled to make ri'*X0'*X0*ri == ti'*ti == 1
                
                % Update the orthonormal basis with modified Gram Schmidt (more stable),
                % repeated twice (ditto).
                vi = this.XL(:,i);
                for repeat = 1:2
                    for j = 1:i-1
                        vj = V(:,j);
                        vi = vi - (vj'*vi)*vj;
                    end
                end
                vi = vi ./ norm(vi);
                V(:,i) = vi;
                
                % Deflate Cov, i.e. project onto the ortho-complement of the X loadings.
                % First remove projections along the current basis vector, then remove any
                % component along previous basis vectors that's crept in as noise from
                % previous deflations.
                Cov = Cov - vi*(vi'*Cov);
                Vi = V(:,1:i);
                Cov = Cov - Vi*(Vi'*Cov);
            end
            
            % By convention, orthogonalize the Y scores w.r.t. the preceding this.XS,
            % i.e. XSCORES'*YSCORES will be lower triangular.  This gives, in effect, only
            % the "new" contribution to the Y scores for each PLS component.  It is also
            % consistent with the PLS-1/PLS-2 algorithms, where the Y scores are computed
            % as linear combinations of a successively-deflated Y0.  Use modified
            % Gram-Schmidt, repeated twice.
            for i = 1:ncomp
                ui = this.YS(:,i);
                for repeat = 1:2
                    for j = 1:i-1
                        tj = this.XS(:,j);
                        ui = ui - (tj'*ui)*tj;
                    end
                end
                this.YS(:,i) = ui;
            end
            
            this.varExp = [  sum(abs(this.XL).^2,1) ./ sum(sum(abs(X0).^2,1));
                sum(abs(this.YL).^2,1) ./ sum(sum(abs(Y0).^2,1)) ];
            this.varExp = 100*this.varExp;
        end
        
        %> @param outputIdx is the index(es) of the response for which the VIP
        % scores must be computed
        function vip = doComputeVip(this, A)
            if nargin == 1
                [n,A] = size(this.W);
            else
                n = size(this.W,1);
            end
            %this.W(:,1:i),this.XS(:,1:i),this.YL(:,1:i)
            s = diag((this.XS(:,1:A)'*this.XS(:,1:A))*(this.YL(:,1:A)'*this.YL(:,1:A)));
            vip = zeros(n,1);
            w = zeros(A,1);
            for i=1:n
                for j=1:A
                    w(j)= (this.W(i,j)/norm(this.W(:,j)))^2;      %weight of each component
                end
                sw=s'*w;						  % explained variance by variable i
                vip(i)=sqrt(n*sw/sum(s));
            end
        end

        function [B, C] = doReverseRegCoef( ~, B0, Xtr, Ytr )
            meanXtr = mean(Xtr);
            stdXtr = std(Xtr);
            meanYtr = mean(Ytr);
            stdYtr = std(Ytr);
            
            B = bsxfun(@times,bsxfun(@times, B0', 1./stdXtr),stdYtr)';
            C = meanXtr * B0 - meanYtr;
        end

    end
    
    
end
