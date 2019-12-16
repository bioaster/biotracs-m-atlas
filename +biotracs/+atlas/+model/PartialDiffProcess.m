% BIOASTER
%> @file		PartialDiffProcess.m
%> @class		biotracs.atlas.model.PartialDiffProcess
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef PartialDiffProcess < biotracs.core.mvc.model.Process
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PartialDiffProcess()
            %#function biotracs.atlas.model.PartialDiffProcessConfig biotracs.atlas.model.PCALearnerResult biotracs.atlas.model.PLSLearnerResult biotracs.atlas.model.PartialDiffProcessResult
            
            this@biotracs.core.mvc.model.Process();
            this.setDescription('Partial differential analysis based on principal-components analysis');
            
            this.addInputSpecs({...
                struct(...
                'name', 'LearningResult',...
                'class', {{'biotracs.atlas.model.PCALearnerResult','biotracs.atlas.model.PLSLearnerResult'}} ...
                )...
                });
            
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PartialDiffProcessResult' ...
                )...
                });
            
            this.bindEngine(biotracs.atlas.model.PCALearner(), 'PcaEngine');
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        function [ distValues ] = doComputeNullDistribution( ~, grp1Data, grp2Data, mcperm )
            data = [grp1Data; grp2Data];
            n1 = size(grp1Data,1);
            n2 = size(grp2Data,1);
            n = n1 + n2;
            distValues = zeros(1,mcperm);
            for i=1:mcperm
                permIdx = randperm(n);
                permData = data(permIdx,:);
                permData1 = permData(1:n1,:);
                permData2 = permData(n1+1:end,:);
                
                mean1 = mean(permData1);
                mean2 = mean(permData2);
                N = n1+n2-2;
                S1 = cov(permData1);
                S2 = cov(permData2);
                S = ((n1-1)*S1 + (n2-1)*S2 )/N;
                distValues(i) = (mean1 - mean2) * S^-1 * (mean1 - mean2)';
            end
            
        end
        
        function doRun( this, varargin )
            learningResult = this.getInputPortData('LearningResult');
            trSet = learningResult.getTrainingSet();
            scoreDataSet = learningResult.getXScores();
            
            grpPatterns = this.config.getParamValue('GroupPatterns');
            grpStrategy = biotracs.data.helper.GroupStrategy( trSet.rowNames, grpPatterns );
            [sliceIndexes, sliceNames] = grpStrategy.getSlicesIndexes();
            
            ncomp = this.config.getParamValue('NbComponents');
            mcperm = this.config.getParamValue('MonteCarloPermutation');
            pvalThreshlod = this.config.getParamValue('PValue');
            
            %orig_state = warning;
            %warning('off','all');
            
            nbGroups = length(sliceNames);
            p = min(ncomp, getSize(scoreDataSet,2));
            cpt = 1;
            
            if ~isempty(mcperm) && mcperm > 0
                resultData = zeros(5, nbGroups^2);
                rowNames = {'Distance', 'F', 'Fcritical', 'Fpvalue', 'Ppvalue'};
            else
                resultData = zeros(4, nbGroups^2);
                rowNames = {'Distance', 'F', 'Fcritical', 'Fpvalue'};
            end
            
            columnNames = cell(1, nbGroups^2);
            for i=1:nbGroups
                grp1Name = sliceNames{i};
                grp1Idx = sliceIndexes(:,i);
                grp1Data = scoreDataSet.data(grp1Idx,1:p);
                n1 = size(grp1Data,1);
                
                for j=(i+1):nbGroups
                    grp2Name = sliceNames{j};
                    grp2Idx = sliceIndexes(:,j);
                    grp2Data = scoreDataSet.data(grp2Idx,1:p);
                    n2 = size(grp2Data,1);
                    
                    mean1 = mean(grp1Data);
                    mean2 = mean(grp2Data);

                    %pooled variance
                    N = n1+n2-2;
                    S1 = cov(grp1Data);
                    S2 = cov(grp2Data);
                    S = ((n1-1)*S1 + (n2-1)*S2 )/N;
                    dist = (mean1 - mean2) * S^-1 * (mean1 - mean2)';
                    
                    
                    T2 = n1*n2/(n1+n2)*dist;
                    F = T2*(n1+n2-p-1)/(p*(n1+n2-2));
                    Fcrit = 1/finv(pvalThreshlod,n1,n2);
                    Fpval = 1-fcdf(F,n1,n2);
                    
                    if ~isempty(mcperm) && mcperm > 0
                        [ distValues ] = this.doComputeNullDistribution( grp1Data, grp2Data, mcperm );
                        [Ppval] = doNonParamTest( distValues, dist, 'right' );
                        resultData(:, cpt) = [dist, F, Fcrit, Fpval, Ppval]';
                    else
                        resultData(:, cpt) = [dist, F, Fcrit, Fpval]';
                    end
                    columnNames{cpt} = strcat(grp1Name,'_',grp2Name);
                    cpt = cpt + 1;
                end
            end
            
            %warning(orig_state);
            
            resultData(:,cpt:end) = [];
            columnNames(:,cpt:end) = [];
            result = biotracs.atlas.model.PartialDiffProcessResult(resultData, columnNames, rowNames);
            this.setOutputPortData('Result', result);
            
            function [ p ] = doNonParamTest(x,th,tail)
                n = length(x);
                if strcmpi(tail,'right')
                    p = sum( x >= th )/n;
                elseif strcmpi(tail,'left')
                    p = sum( x <= th )/n;
                else
                    error('Invalid tail');
                end
            end
        end
        
        function doLearnPerm(~)
            % no effect
        end
        
        function doLearnCv(~)
            % no effect
        end
    end
    
    
end
