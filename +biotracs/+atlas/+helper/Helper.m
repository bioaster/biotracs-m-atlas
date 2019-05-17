% BIOASTER
%> @file		Helper.m
%> @class		biotracs.atlas.helper.Helper
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Helper < handle
    
    properties(Constant)
    end
    
    properties( SetAccess = protected )
    end
    
    events
    end

    methods(Static)
        
        function [ E2 ] = computeClassificationStatsWithSeparators( Y0, Y0pred, expectedY0th, predictedY0th )
            if nargin <= 3
                predictedY0th = expectedY0th;
            end
            
            [m,~] = size(Y0pred);
            knownGroup =  zeros(1,m);
            predGroup = cell(1,m);
            for k=1:m
                knownGroup(k) = find( Y0(k,:) > expectedY0th );
                predGroup{k} =  find( Y0pred(k,:) > predictedY0th );
            end
            [ E2 ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroup, predGroup );
        end
        
%         function [ E2, info, C, Ce ] = computeOptimalClassificationStats( Y0, Y0pred, originalYte )
%             membership = logical(originalYte);
%             m = size(originalYte,1);
%             
%             if( ~isequal(size(Y0),size(originalYte)) || ~isequal(size(Y0pred),size(originalYte)) )
%                 error('Y0 and Y0Pred and Yte must have the same sizes');
%             end
%             
%             % positive groups confidence intervals
%             posY0pred = Y0pred;
%             posY0pred(~membership) = nan;
%             n = sum(posY0pred, 1, 'omitnan');
%             info.posMean = mean(posY0pred, 1, 'omitnan');
%             info.posStd = std(posY0pred, [], 1, 'omitnan');
%             info.pos95 = 1.96 .* info.posStd;
%             t2 = finv(0.95, 1 , n-1);   %finv(0.95, p , n-p) * (n-1)*p/(n-p) = finv(0.95, 1 , n-1) with p parameter per axis, n samples in the group
%             info.posT2 = t2 .* info.posStd;
%             info.posLim = min(posY0pred, [], 1);
% 
%             % negative groups confidence intervals
%             negY0pred = Y0pred;
%             negY0pred(membership) = nan;
%             n = sum(negY0pred, 1, 'omitnan');
%             info.negMean = mean(negY0pred, 1, 'omitnan');
%             info.negStd = std(negY0pred, [], 1, 'omitnan');
%             info.neg95 = 1.96 .* info.negStd;
%             t2 = finv(0.95, 1, n-1); 
%             info.negT2 = t2 .* info.negStd;
%             info.negLim = max(negY0pred, [], 1);
%             predGroup = cell(1,m);
%             knownGroup =  zeros(1,m);
%             
%             % class sep
%             Y0th = ( min(Y0,[],1) + max(Y0,[],1) )/2; %membership threshold
%             
%             %Strategy 1
%             info.classSep = Y0th;
%             
%             %Strategy 2 : Recompute the seperator
%             %info.classSep = info.posLim + info.negLim)/2; %membership threshold
%             
%             Y0(1,:)
%             Y0th
%             
%             for k=1:m
%                 knownGroup(k) = find( Y0(k,:) > Y0th );
%                 predGroup{k} =  find( Y0pred(k,:) > info.classSep );
%             end
%             
%             if nargout <= 2
%                 [ E2 ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroup, predGroup );
%             else
%                 [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroup, predGroup );
%             end
%         end
        
        function [ E2, C, Ce ] = computeClassificationStats( knownGroups, predGroups )
            nbGroup = length(unique(knownGroups));
            Ce = cell(1,nbGroup);
            E2 = zeros(1,nbGroup);
            
            % 1)
            list = 1:nbGroup;
            for g1 = list
                g1c = list( list ~= g1 );
                isKnownInG1 = (knownGroups == g1);
                isKnownInG1c = ~isKnownInG1;
                isPredInG1 = cellfun( @(x)(ismember(g1,x)), predGroups );
                isPredInG1c = cellfun( @(x)(isempty(x) || any(ismember(g1c,x))), predGroups );
                tp = sum( isPredInG1 & isKnownInG1 );
                fp = sum( isPredInG1 & isKnownInG1c );
                tn = sum( isPredInG1c & isKnownInG1c );
                fn = sum( isPredInG1c & isKnownInG1 );
                
                nbPos = tp+fn;
                nbNeg = fp+tn; 
                Ce{g1} = [tp, fp; fn, tn];
                se = tp/nbPos;
                sp = tn/nbNeg;
                e1 = 1-se;
                e2 = 1-sp;
                E2(g1) = (e1 + e2)/2;
                %E(g1) = e1 + e2;
                %BER(g1) = (e1 + e2)/2;
            end
            
            % 2)
            if nargout > 1
                C = zeros(nbGroup,nbGroup);
                for g1=1:nbGroup
                    isKnownInG1 = (knownGroups == g1);
                    for g2=1:nbGroup
                        isPredInG2 = cellfun( @(x)(ismember(g2,x)), predGroups );
                        C(g1,g2) = sum( isKnownInG1 & isPredInG2 );
                    end
                end
                
                %L = tril(C, -1);
                %U = triu(C, +1);
                %MCR = (sum(L(:)) + sum(U(:)))/sum(C(:));               %misclassification rate
            end
            %BER = (e1 + e2)/2;
        end
 
    end

    
end
