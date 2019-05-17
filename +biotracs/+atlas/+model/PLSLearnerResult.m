% BIOASTER
%> @file		PLSLearnerResult.m
%> @class		biotracs.atlas.model.PLSLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PLSLearnerResult < biotracs.atlas.model.BaseDecompLearnerResult
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PLSLearnerResult( varargin )
            this@biotracs.atlas.model.BaseDecompLearnerResult();
            this.set('RegCoef', biotracs.data.model.DataMatrix());
            this.set('Vip', biotracs.data.model.DataMatrix());
            this.set('CrossValidationRegCoef', biotracs.data.model.DataObject());
            this.set('CrossValidationVariableRanking', biotracs.data.model.DataMatrix());
            this.set('CrossValidationVip', biotracs.data.model.DataTable());
            this.set('YPrediction', biotracs.data.model.DataObject());
            this.set('YThreshold', biotracs.data.model.DataMatrix());
            this.set('OptimalNbComponents', biotracs.data.model.DataMatrix());
            this.bindView( biotracs.atlas.view.PLSLearnerResult );
        end
        
        %-- G --

        function [ optComp, optCriterion ] = getOptimalNbComponents( this, varargin )
            p = inputParser();
            p.addParameter('Criterion', '', @ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            stats = this.get('Stats');
            switch upper(p.Results.Criterion)
                case ''
                    if this.process.isDiscriminantAnalysis
                        criterion = stats.get('CV_E2').getData();
                        criterionToMinimize = criterion;
                    else
                        criterion = stats.get('Q2Y').getData();
                        criterionToMinimize = 1-criterion;
                    end
                case {'MSE', 'MSE_Y'}
                    criterion = stats.get('MSEP_Y').getData(); 
                    criterionToMinimize = criterion;
                case {'E2', 'CV_E2'}
                    criterion = stats.get('CV_E2').getData();
                    criterionToMinimize = criterion;
                case 'Q2'
                    criterion = stats.get('Q2Y').getData();   %maximization problem
                    criterionToMinimize = 1-criterion;
                otherwise
                    errror('PlsResults:InvalidCriterion','Invalid criterion');
            end

            if isempty(criterionToMinimize)
                error('PlsResults:NoCrossValdiationResultAvailable', 'No predictive statistics %s available. Run the process with cross-validation', upper(p.Results.Criterion));
            end

            alpha = 0.05;
            espilon = abs(max(criterionToMinimize) - min(criterionToMinimize)) * alpha;    %singificance magnitude
            cutoff = min(criterionToMinimize) + espilon;
            idx = criterionToMinimize <= cutoff;
            optComp = find(idx, 1);
            optCriterion = criterion(optComp);
        end
        
        function b = getCrossValidationRegCoef( this )
            b = this.get('CrossValidationRegCoef');
        end
        
        function [d, idx ]= getCrossValidationVip( this, iNbComp )
            cvVip = this.get('CrossValidationVip');
            if cvVip.hasEmptyData()
                d = biotracs.data.model.DataMatrix();
                return;
            end
            
            if nargin == 1
                iNbComp = size(cvVip.data, 2);
            else
                iNbComp = iNbComp(1); %Scalar
            end
            
            meanVip = cvVip.data{1}.data(:,iNbComp);
            stdVip = cvVip.data{2}.data(:,iNbComp);
            
            n = length(meanVip);
            d = biotracs.data.model.DataMatrix(...
                [ meanVip, stdVip, meanVip-1.96*stdVip, meanVip+1.96*stdVip, (1:n)', meanVip ], ...
                {'MeanVip', 'StdVip', 'MinVipLimitCI95', 'MaxVipLimitCI95', 'VariableIndex','Score'}, ...
                cvVip.data{1}.rowNames ...
                );
            [d, idx] = d.sortRows(-1);
        end
        
        function [d, idx] = getCrossValidationVariableRanking(this, iNbComp)
            cvVip = this.get('CrossValidationVip');
            if cvVip.hasEmptyData()
                d = biotracs.data.model.DataMatrix();
                return;
            end

            totalNbCompComputed = size(cvVip.data{1}.data, 2);
            if nargin == 1 || iNbComp > totalNbCompComputed
                iNbComp = totalNbCompComputed;
            end
            
            %Vip
            meanVip = cvVip.data{1}.data(:,iNbComp);
            stdVip = cvVip.data{2}.data(:,iNbComp);
            d1 = biotracs.data.model.DataMatrix(...
                [ meanVip, stdVip, meanVip-1.96*stdVip, meanVip+1.96*stdVip ], ...
                {'MeanVip', 'StdVip', 'MinVipLimitCI95', 'MaxVipLimitCI95'}, ...
                cvVip.data{1}.rowNames ...
                );
            
            %RegCoef
            regCoef = this.getCrossValidationRegCoef().getData();
            meanRegCoefColNames = cellfun(@(x)(strcat('MeanRegCoef',x)), regCoef.responses, 'UniformOutput', false);
            stdRegCoefColNames = cellfun(@(x)(strcat('StdRegCoef',x)), regCoef.responses, 'UniformOutput', false);

            d2 = biotracs.data.model.DataMatrix(...
                [ regCoef.mean{iNbComp}, regCoef.std{iNbComp} ], ...
                [ meanRegCoefColNames, stdRegCoefColNames ], ...
                regCoef.variables ...
                );
            
            %Correlations
            trainingSet = this.process.getInputPortData('TrainingSet');
            xIdx = trainingSet.getInputIndexes();
            yIdx = trainingSet.getOutputIndexes();
            [rho,pval] = corr( trainingSet );
            responseNames = trainingSet.getColumnNames(yIdx);
            variableNames = trainingSet.getColumnNames(xIdx);
            corrCoef = rho.selectByColumnIndexes(yIdx).selectByRowIndexes(xIdx);
            corrPval = pval.selectByColumnIndexes(yIdx).selectByRowIndexes(xIdx);
            corrColNames = cellfun(@(x)(strcat('Correlation',x)), responseNames, 'UniformOutput', false);
            pvalColNames = cellfun(@(x)(strcat('CorrelationPvalue',x)), responseNames, 'UniformOutput', false);
            d3 = biotracs.data.model.DataMatrix(...
                [ corrCoef.data, corrPval.data ], ...
                [ corrColNames, pvalColNames ], ...
                variableNames ...
                );
            [d, idx] = d1.horzmerge(d2,d3).sortRows(-1);
        end

        function oNbComp = getNbComponents( this )
            vipTable = this.get('Vip');
            oNbComp = getSize(vipTable,2);
        end
        
        function [ r ] = getPermutationTestSignificance( this, varargin )
            if this.isDiscriminantAnalysis()
                criterion = 'E2';
            else
                criterion = 'R2Y';
            end
            
            p = inputParser();
            p.addParameter('Criterion', criterion, @(x)(ischar(x) && any(strcmp(x,{'E2', 'R2Y'}))));
            p.addParameter('Test', 'NonParam', @(x)(ischar(x) && any(strcmpi(x,{'TTest', 'NonParam'}))));
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            permCriterion = ['Perm',p.Results.Criterion];
            
            learningStats = this.getStats();
            statDataTable = learningStats.get( permCriterion  );

            if strcmp(p.Results.Criterion, 'E2')
                cvCriterionName = 'CV_E2';
                ttestTail = 'right';
            elseif strcmp(p.Results.Criterion, 'R2Y')
                cvCriterionName = 'Q2Y';
                ttestTail = 'left';
            end
            
            hasPermutationTests = ~(isempty(statDataTable) || hasEmptyData(statDataTable));
            pValue = NaN;
            crossValPValue = NaN;
            
            if hasPermutationTests
                if learningStats.hasElement(p.Results.Criterion)
                    if this.hasCrossValidationData()
                        ncomp = this.getOptimalNbComponents();
                        distValues = learningStats.get( p.Results.Criterion  ).getData();
                        distCrossValValues = learningStats.get( cvCriterionName  ).getData();
                    else
                        ncomp = this.getNbComponents();
                        distValues = learningStats.get( p.Results.Criterion  ).getData();
                        distCrossValValues = [];
                    end

                    testStat = distValues(ncomp);
                    if strcmpi(p.Results.Test,'TTest')
                        [~,pValue] = ttest(statDataTable.data,testStat,'Tail',ttestTail);
                    else
                        [pValue] = doNonParamTest( statDataTable.data,testStat,ttestTail );
                    end

                    if ~isempty(distCrossValValues)
                        testStatCv = distCrossValValues(ncomp);
                        if strcmpi(p.Results.Test,'TTest')
                            [~,crossValPValue] = ttest(statDataTable.data,testStatCv,'Tail',ttestTail);
                        else
                            [crossValPValue] = doNonParamTest( statDataTable.data,testStatCv,ttestTail );
                        end
                    end   
                else
                    biotracs.core.env.Env.writeLog('No data found in %s for criterion for %s', class(this), p.Results.Criterion); 
                end
            else
                biotracs.core.env.Env.writeLog('No permutation test data found in the learning result %s. You did probably not perform permutation testing', class(this));
            end
            
            data  = [   testStat, pValue
                        testStatCv, crossValPValue ];
            r = biotracs.data.model.DataMatrix( data, {'TStatistic','PValue'}, {p.Results.Criterion, cvCriterionName} );
            
            function [ p ] = doNonParamTest(x,th,tail)
                n = length(x);
                if strcmpi(tail,'right')
                    p = sum( th >= x )/n;
                elseif strcmpi(tail,'left')
                    p = sum( th <= x )/n;
                else
                    p = sum( th <= x | th >= x )/n;
                end
            end
        end
        
        function coef = getRegCoef( this )
            coef = this.get('RegCoef');
        end

        function [ vipTable ] = getSelectedVariables( this, iNbVar, iNbComp )
            if isempty(iNbVar)
                error('SPECTRA:Pls:InvalidNbVarsiableToSelect','The number of variable to select is required');
            end
            if nargin <= 2
                if this.hasCrossValidationData()
                    iNbComp = this.getOptimalNbComponents();
                    biotracs.core.env.Env.writeLog('Cross-validation was performed. The optimal number of components to use is %g', iNbComp);
                else
                    iNbComp = this.getNbComponents();
                    biotracs.core.env.Env.writeLog('No cross-valdiation performed. Use all the %g components', iNbComp);
                end
            else
                iNbComp = iNbComp(1);
            end
            [ vipTable ] = this.getCrossValidationVip( iNbComp );
            if vipTable.hasEmptyData()
                [ vipTable ] = getVip( this, iNbComp );
            end
            vipTable = vipTable.selectByRowIndexes(1:iNbVar);
            
            %rank = biotracs.data.model.DataMatrix( (1:getSize(vipTable,1))', {'Rank'}, vipTable.getRowNames() );
            %vipTable = horzcat(rank, vipTable);
        end
        
        function YL = getYLoadingData( this )
            YL = this.get('YLoadings').getData();
        end
        
        function dm = getYLoadings( this )
            dm = this.get('YLoadings');
        end

        function YS = getYScoreData( this )
            YS = this.get('YScores').getData();
        end
        
        function ds = getYScores( this )
            ds = this.get('YScores');
        end
		
        function [vip, idx] = getVip( this, iNbComp )
            vip = this.get('Vip');
            if nargin == 1
                iNbComp = getSize(vip, 2);
            else
                iNbComp = iNbComp(1);
            end
            n = getSize(vip,1);
            data = [ vip.data(:,iNbComp), (1:n)' ];
            vip = biotracs.data.model.DataMatrix(  data, {'Vip','VariableIndex'}, vip.rowNames );
            [vip, idx] = vip.sortRows(-1); %sort using the highest principal component
        end
        
        function W = getWeightData( this )
            W = this.get('Weights').getData();
        end

        function YR = getYResidualData( this )
            YR = this.get('YResiduals').getData();
        end
        
        function Yvar = getYVarExplainedData( this )
            Yvar = this.get('YVarExplained').getData();
        end
        
        function d = getYPredictions( this, ncomp )
            if nargin == 1
                if this.hasCrossValidationData()
                    ncomp = this.getOptimalNbComponents();
                    biotracs.core.env.Env.writeLog('Cross-validation was performed. The optimal number of components to use is %g', ncomp);
                else
                    ncomp = this.getNbComponents();
                    biotracs.core.env.Env.writeLog('No cross-valdiation performed. Use all the %g components', ncomp);
                end
            end
            dataObject = this.get('YPrediction');            

            d = biotracs.data.model.DataMatrix( dataObject.data.Ypred{ncomp}, this.getResponseNames(), this.getInstanceNames() );
            
            %this.getTrainingSet().getRowNamePatterns()
            
            d.setRowNamePatterns( this.getTrainingSet().getRowNamePatterns() );
        end
        
        %-- H --
        
        function [tf] = hasCrossValidationData( this )
            cvVip = this.get('CrossValidationVip');
            tf = ~cvVip.hasEmptyData();
        end
        
        function [tf] = hasPermutationTestData( this, varargin )
            p = inputParser();
            p.addParameter('Criterion', 'R2Y', @(x)(ischar(x) && any(strcmp(x,{'E2', 'R2Y'}))));
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            criterion = ['Perm',p.Results.Criterion];
            statDataTable = this.getStats().get( criterion  );
            tf = ~(isempty(statDataTable) || hasEmptyData(statDataTable));
        end
        
        %-- M --
        
        %-- S --
        
        function this = setCrossValidationRegCoefData( this, iMeanRegCoef, iStdRegCoef, iResponseNames, iVariableNames )
            %meanRegCoef = biotracs.data.model.DataMatrix(iMeanRegCoef, iVariableNames, iResponseNames);
            %stdRegCoef = biotracs.data.model.DataMatrix(iStdRegCoef, iVariableNames, iResponseNames);
            %s = biotracs.core.mvc.model.ResourceSet();
            %s.add(meanRegCoef, 'MeanRegCoef');
            %s.add(stdRegCoef, 'MeanRegCoef');

            d.mean = iMeanRegCoef;
            d.std = iStdRegCoef;
            d.responses = iResponseNames;
            d.variables = iVariableNames;
            
            pcIndexes = 1:length(d.mean);
            pcIndexes = arrayfun(@num2str, pcIndexes, 'UniformOutput', false);
            d.slots = strcat('PC', pcIndexes);
            do = biotracs.data.model.DataObject( d );
            do.setDescription( 'Cross-validation regression coefficients. Matrices are A-n-p tensors where A = numnber of components, n = number of coefficients, p = number of responses' );
            this.set('CrossValidationRegCoef', do);
        end

        function this = setCrossValidationVipData( this, iMeanVip, iStdVip, iVariableNames )
            m = biotracs.data.model.DataMatrix( iMeanVip, 'PC', iVariableNames );
            s = biotracs.data.model.DataMatrix( iStdVip, 'PC', iVariableNames );
            d = biotracs.data.model.DataTable( { m, s }, {'MeanVip', 'StdVip'} );
            d.setDescription( 'Cross-validation VIP' );
            this.set('CrossValidationVip', d);
        end

        function setRegCoefData( this, iRegCoef, iResponseNames, iVariableNames )
            d = biotracs.data.model.DataMatrix( iRegCoef, iResponseNames, iVariableNames );
            this.set('RegCoef', d);
        end


        function this = setVipData( this, vip, iVariableNames )
            d = biotracs.data.model.DataMatrix( vip, 'VipPC', iVariableNames );
            %d = d.sortRows(-1); %sort by vip for the more the less important
            this.set('Vip', d);
        end
        
        function setWeightData( this, W )
            d = biotracs.data.model.DataMatrix( W );
            this.set('Weights', d);
        end
        
        function setYLoadingData( this, YL, iResponseNames )
            d = biotracs.data.model.DataMatrix(YL);
            d.setRowNames( iResponseNames );
            d.setColumnNames( 'PC' );
            this.set('YLoadings', d);
        end

        function setYScoreData( this, YS, iInstanceNames )
            d = biotracs.data.model.DataSet( YS );
            d.setRowNames( iInstanceNames );
            d.setColumnNames( 'PC' );
            this.set('YScores', d);
        end
        
        function setYResidualData( this, YR, iResponseNames, iInstanceNames )
            d = biotracs.data.model.DataSet( YR, iResponseNames, iInstanceNames );
            this.set('YResiduals', d);
        end

        function setYVarExplainedData( this, Var )
            d = biotracs.data.model.DataMatrix( Var, 'PC', {'YVarExplained'} );
            this.set('YVarExplained', d);
        end
        
        function setYPredictions( this, Ypred, Yth )
            data.Ypred = Ypred;
            if nargin >= 3
                data.Yth = Yth;
            end
            d = biotracs.data.model.DataObject(data);
            this.set('YPrediction', d);
        end
        
    end
    
    % -------------------------------------------------------
    % Public inherited interfaces
    % -------------------------------------------------------
    methods

    end
end
