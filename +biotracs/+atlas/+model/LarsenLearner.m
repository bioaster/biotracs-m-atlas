% BIOASTER
%> @file		LarsenLearner.m
%> @class		biotracs.atlas.model.LarsenLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef LarsenLearner < biotracs.atlas.model.VariableSelector
    
    properties(Constant)
    end
    
    properties(Access = protected)
        maxIter = 1000;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = LarsenLearner()
            %#function biotracs.atlas.model.LarsenLearnerConfig biotracs.atlas.model.LarsenLearnerResult
            
            this@biotracs.atlas.model.VariableSelector();
            
            % enhance outputs specs
            this.updateOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.LarsenLearnerResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doLearn( this, X0, Y0 )
            if nargin < 3
                error('Both X0 and Y0 are required');
            end
            
            if nargin < 2
                error('Y0 is required');
            end
            
            if isempty(X0)
                error('X0 is empty. Please check data.');
            end
            
            if isempty(Y0)
                error('Y0 is empty. Please check data');
            end
            
            
            nbvar = this.config.getParamValue('NbVariablesToSelect');
            p = size(X0,2);
            if isempty(nbvar) || nbvar <= 0
                nbvar = ceil(p/2);              % we select the half of the variables
            end
            delta = 1e-3;                       % L2-norm constraint
            stop = -nbvar;                      % request non-zero variables
            Q = size(Y0,2);
            
            if this.isDiscriminantAnalysis()
                tol = 1e-6;
                [~, ~, betaPath] = spasm.slda( X0, Y0, delta, stop, Q-1, this.maxIter, tol, false );
            else
                betaPath = cell(1,Q);
                %compute path for the q outputs
                for i=1:Q
                    %[betaPath{i}, ~] = spasm.elasticnet( X0, Y0(:,i), delta, stop, true, false );
                    [betaPath{i}, ~] = spasm.larsen( X0, Y0(:,i), delta, stop, [], true, false );
                end
            end
            probPath = cellfun( @(x)(x ~= 0), betaPath, 'UniformOutput', false );
            
            result = this.getOutputPortData('Result');
            result.setWeightData( betaPath{end}, this.getVariableNames() );
            result.setWeightPaths( betaPath, this.getVariableNames() );
            result.setProbPaths( probPath, this.getVariableNames() );
            
            %set output and propagate
            this.setOutputPortData('Result', result);
        end
        
        
        function doLearnCv( this, Xtr, Ytr, varargin)
            if this.config.getParamValue('Verbose')
                this.logger.writeLog('%s','Use ModelSelector to perform efficient variable selection with elastic net and data resampling');
            end
            
            p = inputParser();
            p.addParameter('kFoldCrossValidation',1,@(x)( isscalar(x) && x>1) );
            p.addParameter('ResponseNames',{},@iscell );
            p.addParameter('VariableNames',{},@iscell );
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            nbvar = this.config.getParamValue('NbVariablesToSelect');
            verbose = this.config.getParamValue('Verbose');
            if verbose
				w = biotracs.core.waitbar.Waitbar('Name', 'Cross-validation');
				w.show();
            end
            
            [m, n] = size(Xtr);
            q = size(Ytr,2);
%             oYtr = this.getInputPortData('TrainingSet')...
%                 .selectYSet()...
%                 .getData();
            
            kfold = p.Results.kFoldCrossValidation;
            mcrep = 1;
            
            if kfold <= 1
                error('Cross-validation kfold must be greater than 1');
            end
            
            if kfold == Inf
                kfold = m;
            end
            
            % Compute the fisrt (master) cv partition and the effective total number of partitions
            masterCVPartitions = cvpartition(m,'k', kfold);
            totalNumTestSets = masterCVPartitions.NumTestSets * mcrep;
            cvPartitions = masterCVPartitions.repartition();    %resample partitions
 
            crossValIter = 0;
            
            % larsen configuration
            Q = q;
            delta = 1e-3;                       % L2-norm constraint
            tol = 1e-6;
            
            for k = 1:cvPartitions.NumTestSets
                crossValIter = crossValIter+1;
                if verbose
                    w.show(crossValIter/totalNumTestSets)
                end

                trIdx = cvPartitions.training(k);
                %teIdx = cvPartitions.test(k);
                
                % Extract training and test subsets
                X0tr = Xtr(trIdx,:);
                Y0tr = Ytr(trIdx,:);
                %X0te = Xtr(teIdx,:);
                %Y0te = Ytr(teIdx,:);
                %oY0te = oYtr(teIdx,:);
                
                % Center/scale subsets
                %X0te = biotracs.math.centerscale( X0te, X0tr, 'Center' , true, 'Scale', 'none' );	%it not necessary to scale again
                %Y0te = biotracs.math.centerscale( Y0te, Y0tr, 'Center' , true, 'Scale', 'none' );
                X0tr = biotracs.math.centerscale( X0tr, [], 'Center' , true, 'Scale', 'none' );
                Y0tr = biotracs.math.centerscale( Y0tr, [], 'Center' , true, 'Scale', 'none' );
  
                p = size(X0tr,2);
                if isempty(nbvar) || nbvar <= 0 || nbvar > p
                    nbvar = ceil(p/2);              % we select the half of the variables
                end
                
                stop = -nbvar;                      % request non-zero variables
                if this.isDiscriminantAnalysis()
                    [~, ~, betaPath] = spasm.slda( X0tr, Y0tr, delta, stop, Q-1, this.maxIter, tol, false );
                else
                    betaPath = cell(1,Q);
                    %compute path for the q outputs
                    for i=1:Q
                        %[betaPath{i}, ~] = spasm.elasticnet( X0, Y0(:,i), delta, stop, true, false );
                        storepath = true;
                        [betaPath{i}, ~] = spasm.larsen( X0tr, Y0tr(:,i), delta, stop, [], storepath, false );
                        
                        %trim path and remove duplicates to select only
                        %steps corresponding to "1" to "nbvar" selected variables
                        nbVarSelectedAtEachStep = sum(betaPath{i} ~= 0);
                        indexesOfStepsToSelect = zeros(1,nbvar);
                        for nbVarIdx = 1:nbvar
                            idx = find(nbVarSelectedAtEachStep == nbVarIdx, 1, 'last');
                            indexesOfStepsToSelect(nbVarIdx) = idx;
                        end
                        betaPath{i} = betaPath{i}(:,indexesOfStepsToSelect);
                    end
                end
                probPath = cellfun( @(x)(x ~= 0), betaPath, 'UniformOutput', false );

                %aggregate paths
                if k == 1
                    betaStabilityPath = betaPath;
                    probStabilityPath = probPath;
                else
                    for j=1:length(betaStabilityPath)
%                         try
%                             m1= size(betaStabilityPath{i},2);
%                             m2= size(betaPath{i},2);
%                             if m1 > m2
%                                 betaStabilityPath{i} = betaStabilityPath{i}(:,m2:end);
%                                 probStabilityPath{i} = probStabilityPath{i}(:,m2:end);
%                             else
%                                 betaPath{i} = betaPath{i}(:,m1:end);
%                                 probPath{i} = probPath{i}(:,m1:end);
%                             end
                            
                            betaStabilityPath{j} = ((crossValIter-1)*betaStabilityPath{j} + betaPath{j})/crossValIter;
                            probStabilityPath{j} = ((crossValIter-1)*probStabilityPath{j} + probPath{j})/crossValIter;
%                         catch
%                             k
%                             crossValIter
%                             j
%                             betaPath
%                             betaStabilityPath
%                         end
                    end
                end

            end
            
            result = this.getOutputPortData('Result');
            result.setWeightData( betaStabilityPath{end}, this.getVariableNames() );
            result.setWeightPaths( betaStabilityPath, this.getVariableNames() );
            result.setProbPaths( probStabilityPath, this.getVariableNames() );
            
            %set output and propagate
            this.setOutputPortData('Result', result);
        end
        
        function doLearnPerm( this, varargin)
            if this.config.getParamValue('Verbose')
                this.logger.writeLog('Use ModelSelector to perform efficient variable selection with elastic net and data resampling');
            end
        end
        
    end
    
    
end
