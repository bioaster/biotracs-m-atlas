% BIOASTER
%> @file		DiffProcessResult.m
%> @class		biotracs.data.view.DiffProcessResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef DiffProcessResult < biotracs.data.view.DataObject
    
    properties(SetAccess = protected)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewStatTableHtml( this, varargin )
            model = this.getModel();
            data = model.get('StatTable').data;
            combinedMatrix = horzcat( data{:} );
            combinedMatrix.getView().hydrateWith( this );
            h = combinedMatrix.view('Html', varargin{:});
        end
        
        function h = viewVolcanoPlot( this, varargin )
            p = inputParser();
            model = this.model;
            
            config = model.process.getConfig();
            p.addParameter('PValueThreshold', config.getParamValue('PValueThreshold'), @isnumeric);
            p.addParameter('FoldChangeThreshold', config.getParamValue('FoldChangeThreshold'), @isnumeric);
            p.addParameter('LabelFormat', 'long', @(x)(iscell(x) || ischar(x)));
            p.parse( varargin{:} );
            
            %retrieve all to show both significant and non-significant 
            diffTable = model.get('DiffTable');
            
            nbDiffMatrices = getLength(diffTable);
            h.handles = cell(1,nbDiffMatrices);
            h.names = cell(1,nbDiffMatrices);
            for i=1:nbDiffMatrices
                diffMatrix = diffTable.elements{i};
                pval = -log10(diffMatrix.getDataByColumnName('^P\-Value$'));
                fc = log2(diffMatrix.getDataByColumnName('^FoldChange$'));
                pvalThreshold = -log10(p.Results.PValueThreshold);
                fcThreshold = log2(p.Results.FoldChangeThreshold);

                h.handles{i} = figure;
                h.names{i} = diffTable.elementNames{i};
                
                if strcmp(p.Results.LabelFormat,'none')
                    labels = arrayfun( @num2str, 1:getSize(diffMatrix,1), 'UniformOutput',false );
                else
                    labels = biotracs.core.utils.formatLabelForPlot( diffMatrix.getRowNames, 'LabelFormat', p.Results.LabelFormat );
                end
                
                idx = abs(fc) >= abs(fcThreshold) & pval > pvalThreshold;
                
                %significantly regulated
                plot(fc(idx), pval(idx), 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue', 'MarkerSize', 4 );
                hold on
                numIdx = find(idx);
                for j=1:length(numIdx)
                    text( fc(numIdx(j)), pval(numIdx(j)), strcat(['  ', labels{numIdx(j)}]) );
                end
                
                %not significantly regulated
                nidx = ~idx;
                numIdx = find(nidx);
                plot(fc(nidx), pval(nidx), 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', [1,1,1]*0.5, 'MarkerEdgeColor', [1,1,1]*0.5, 'MarkerSize', 4);
                for j=1:length(numIdx)
                    text( fc(numIdx(j)), pval(numIdx(j)), strcat(['  ', labels{numIdx(j)}]) );
                end
                
                %threshold
                xLim = xlim();
                maxAbsXLim = max(abs(xLim));
                xlim([-maxAbsXLim, maxAbsXLim]);
                xLim = xlim();
                plot(xLim, [pvalThreshold, pvalThreshold], '--r');
                
                yLim = ylim();
                if fcThreshold ~= 0
                    plot([fcThreshold, fcThreshold], yLim, '--r')
                    plot([-fcThreshold, -fcThreshold], yLim, '--r')
                end
                
                xlabel('log2 Fold Change');
                ylabel('-log10 P-Value');
                title( [strrep(diffTable.elementNames{i}, '_', '-'), ...
                    ', p = ', num2str(p.Results.PValueThreshold), ...
                    ', fc = ', num2str(p.Results.FoldChangeThreshold) ...
                    ]);
            end
        end
        
        function h = viewDiffPlot( this, varargin )
            p = inputParser();
            p.addParameter('TopNCount', 10, @isnumeric);                %10 most significants
            p.addParameter('TopNList', {}, @iscell);                    %list of topN to show (override TopNCount)
            p.addParameter('PValueThreshold', 0.05, @isnumeric);
            p.addParameter('FoldChangeThreshold', 1, @isnumeric);
            p.addParameter('GroupsToCompare', {}, @iscell);
            p.addParameter('SortBy', 'zscore', @ischar);
            p.addParameter('LabelFormat', 'long', @(x)(iscell(x) || ischar(x)));
            p.parse( varargin{:} );
            
            
            model = this.getModel();
            diffTable = model.get('DiffTable');
            statTable = model.get('StatTable');
            nbDiffMatrices = diffTable.getLength();
            
            groupsToCompare = p.Results.GroupsToCompare;
            
            h.handles = cell(1,nbDiffMatrices);
            h.names = cell(1,nbDiffMatrices);
            for g=1:nbDiffMatrices
                %chech that these groups must be compared
                grpNames = strsplit(diffTable.elementNames{g},'_');
                grp1Name = grpNames{1};
                grp2Name = grpNames{2};

                if ~isempty(groupsToCompare)
                    Ok = false;
                    for i=1:length(groupsToCompare)
                        Ok = ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp1Name,grp2Name} )) || ...
                            ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp2Name,grp1Name} ));
                        if Ok, break; end
                    end
                else
                    Ok = true;
                end
                
                if ~Ok, continue; end
                
                %get diff matrix data
                diffMatrix = diffTable.getAt(g);
                foldChangeIdx = diffMatrix.getColumnIndexesByName('^FoldChange$');
                pValueIdx = diffMatrix.getColumnIndexesByName('^P-Value$');
                
                %select corresponding group's stats
                grp1Idx = statTable.getElementIndexesByNames(grp1Name);
                grp2Idx = statTable.getElementIndexesByNames(grp2Name);
                grp1StatMatrix = statTable.getAt(grp1Idx); %group 1 stats
                grp2StatMatrix = statTable.getAt(grp2Idx); %group 2 stats
                
                %plot top N
                h.handles{g} = figure; hold on;
                h.names{g} = strcat(grp1Name, '_', grp2Name);
                
                if ~isempty(p.Results.TopNList)
                    
                    sortedData = diffMatrix.data;
                    sortedIdx = 1:diffMatrix.getNbRows();
                    
                    %rank by tscore
                    %[sortedData, sortedIdx] = sortrows(diffMatrix.data, -2);
                    
                    str = strjoin(p.Results.TopNList, '|');
                    topNIndexes = grp1StatMatrix.getRowIndexesByName(str);
                    
                    if length(p.Results.TopNList) ~= length(topNIndexes)
                        error('Element not found in list');
                    end
                    
                    for i=1:length(topNIndexes)
                        j = topNIndexes(i);
                        grp1Mean = grp1StatMatrix.data(j,1);
                        grp1Std = grp1StatMatrix.data(j,2);
                        grp2Mean = grp2StatMatrix.data(j,1);
                        grp2Std = grp2StatMatrix.data(j,2);
                        %errorbar( i-0.15, grp1Mean, grp1Std/2, 'xb', 'MarkerSize', 8 );
                        %errorbar( i+0.15, grp2Mean, grp2Std/2, 'xr', 'MarkerSize', 8 );
                        foldChange = sortedData(j,foldChangeIdx);
                        pvalue = sortedData(j,pValueIdx);
                        if (foldChange > p.Results.FoldChangeThreshold || 1/foldChange > p.Results.FoldChangeThreshold) && pvalue < p.Results.PValueThreshold
                            % is significant
                            errorbar( i-0.15, grp1Mean, grp1Std, 'xb', 'MarkerSize', 8 );
                            errorbar( i+0.15, grp2Mean, grp2Std, 'xr', 'MarkerSize', 8 );
                        else
                            % is not significant
                            errorbar( i-0.15, grp1Mean, grp1Std, 'ob', 'MarkerSize', 8 );
                            errorbar( i+0.15, grp2Mean, grp2Std, 'or', 'MarkerSize', 8 );
                        end
                    end
                    
                else
                    %select most significant
                    [diffMatrix, selectedRowIndexes] = diffMatrix.select('WhereColumns', '^P-Value$', 'LessThan', p.Results.PValueThreshold);
                    grp1StatMatrix = grp1StatMatrix.selectByRowIndexes(selectedRowIndexes);
                    grp2StatMatrix = grp2StatMatrix.selectByRowIndexes(selectedRowIndexes);
                    
                    %rank by tscore
                    [sortedData, sortedIdx] = sortrows(diffMatrix.data, 1);
                    if strcmpi(p.Results.SortBy,'zscore')
                        %nothing ...
                    elseif strcmpi(p.Results.SortBy,'name')
                        [~, sortedNameIdx] = sort( diffMatrix.rowNames(sortedIdx) );
                        sortedData = sortedData(sortedNameIdx,:);
                        sortedIdx = sortedIdx(sortedNameIdx);
                    else
                        error('Invalid ''SortBy'' parameter');
                    end
                    
                    nbFeatures = size(sortedData,1);
                    TopNCount = min(nbFeatures,p.Results.TopNCount);
                    topNIndexes = 1:TopNCount;
                    lastIndex = TopNCount;
                    for i=topNIndexes
                        foldChange = sortedData(i,3);
                        %@TODO, the graph does not show all the features 
%                            once a foldchange is under the threshold, the
%                            loop stops (ask Josephine)
%                           
                        if foldChange <= p.Results.FoldChangeThreshold && 1/foldChange <= p.Results.FoldChangeThreshold
                            lastIndex = i-1; break;
                        end
                        j = sortedIdx(i);
                        grp1Mean = grp1StatMatrix.data(j,1);
                        grp1Std = grp1StatMatrix.data(j,2);
                        grp2Mean = grp2StatMatrix.data(j,1);
                        grp2Std = grp2StatMatrix.data(j,2);
                        %errorbar( i-0.15, grp1Mean, grp1Std/2, 'xb', 'MarkerSize', 8 );
                        %errorbar( i+0.15, grp2Mean, grp2Std/2, 'xr', 'MarkerSize', 8 );
                        errorbar( i-0.15, grp1Mean, grp1Std, 'xb', 'MarkerSize', 8 );
                        errorbar( i+0.15, grp2Mean, grp2Std, 'xr', 'MarkerSize', 8 );
                        %@ToDo
                        % write p-value, ...
                    end
                    
                    if lastIndex == 0
                        disp( ['No significant features found for ', diffTable.elementNames{g}] );
                        close(h.handles{g});
                        continue;
                    else
                        topNIndexes = topNIndexes(1:lastIndex);
                    end
                end

                xlim([0.5, length(topNIndexes)+0.5]);

                %others ...
                box on;
                grid on;
                ax = gca;
                xTickLabels = biotracs.core.utils.formatLabelForPlot( diffMatrix.getRowNames(sortedIdx), 'LabelFormat', p.Results.LabelFormat );
                set(ax, 'XTickLabel', xTickLabels(topNIndexes), 'XTickLabelRotation', 90, 'TickDir', 'out', 'FontSize', 10);
                ax.XTick = 1:length(topNIndexes);
                title( [strrep(diffTable.elementNames{g}, '_','-'), ', p = ',num2str(p.Results.PValueThreshold),', fc = ', num2str(p.Results.FoldChangeThreshold)] );
                ylabel('Level');
            end
            
            if ~Ok, h = {}; end
        end
        
        function h = viewVennDiagramm( this, varargin )
            p = inputParser();
            p.addParameter('GroupsToCompare', {}, @iscell);
            p.addParameter('PValueThreshold', 0.05, @isnumeric);
            p.parse( varargin{:} );
            
            n = length(p.Results.GroupsToCompare);
            if n == 0
                error('Please, given the name of list to compare');
            end
            if n == 1
                error('At least, 2 lists can be plotted on venn diagramms');
            end
            if n > 3
                error('No more than 3 lists can be plotted on venn diagramms');
            end
            
            %@ToDo : Use getSignificantList() method instead
            model = this.model;
            topNDiffTable = model.getSignificantDiffTable( 'GroupsToCompare', p.Results.GroupsToCompare, 'PValueThreshold',  p.Results.PValueThreshold );

            lists = cell(1,n);
            groupName = cell(1,n);
            for i=1:n
                diffMatrix = topNDiffTable.getDataAt(i);
                lists{i} = diffMatrix.getRowNames();
                groupName{i} = topNDiffTable.getColumnName(i);
            end
            
            this.doBuildVennDiagramm(...
                'Lists', lists(:), ...
                'GroupNames', groupName(:) ...
                );
            h = gcf();
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function [ intersectData ] = doBuildVennDiagramm( ~, varargin )
            p = inputParser();
            p.addParameter('Lists', {}, @iscell)
            p.addParameter('GroupNames', {}, @iscell)
            p.addParameter('Subplot', {1,1,1}, @iscell)
            p.addParameter('FaceColor', {}, @iscell)
            p.parse(varargin{:});
            
            A1 = length(p.Results.Lists{1});
            A2 = length(p.Results.Lists{2});
            
            idx12 = ismember( p.Results.Lists{1}, p.Results.Lists{2} );
            d12 = p.Results.Lists{1}( idx12 );
            
            I12 = sum(idx12);
            
            if length(p.Results.Lists) == 3
                A3 = length(p.Results.Lists{3});
                
                idx13 = ismember( p.Results.Lists{1}, p.Results.Lists{3} );
                idx23 = ismember( p.Results.Lists{2}, p.Results.Lists{3} );
                d13 = p.Results.Lists{1}( idx13 );
                d23 = p.Results.Lists{2}( idx23 );
                
                idx123 = ismember( d13, p.Results.Lists{2} );
                d123 = d13( idx123 );
                
                I13 = sum(idx13);
                I23 = sum(idx23);
                I123 = sum(idx123);
                
                A = [A1, A2, A3];
                I = [I12 I13 I23 I123];
                intersectData = { d12, d13, d23, d123 };
            else
                A = [A1, A2]; I = I12;
                intersectData = { d12 };
            end
            
            if isequal( p.Results.Subplot, {1,1,1} )
                figure;
            else
                subplot(p.Results.Subplot{:});
            end
            
            if ~isempty( p.Results.FaceColor )
                [~,S] = venn.venn(A,I,'ErrMinMode','None','FaceColor',p.Results.FaceColor);
            else
                [~,S] = venn.venn(A,I,'ErrMinMode','None');
            end
            
            axis image,  title ('Common features')
            [m,~] = size(S.ZoneCentroid);
            for i = 1:m
                text( S.ZoneCentroid(i,1), S.ZoneCentroid(i,2), num2str(round(S.ZonePop(i))) );
            end
            groupNames = strrep(p.Results.GroupNames,'_','-');
            legend( groupNames{:} );
        end
        
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
        
    end
end
