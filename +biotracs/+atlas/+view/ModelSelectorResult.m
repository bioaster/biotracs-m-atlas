% BIOASTER
%> @file		ModelSelectorResult.m
%> @class		biotracs.atlas.view.ModelSelectorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef ModelSelectorResult < biotracs.atlas.view.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ModelSelectorResult()
            this@biotracs.atlas.view.BaseLearnerResult()
        end

        function h = viewSelectedModelMap( this, varargin )  
            selectedModels = this.model.get('SelectedModelMap');
            n = getLength(selectedModels);
            trSet = this.model.getTrainingSet();
            selectModelMap = false(n, getSize(trSet,2)); 
            for i=1:n
                varIndexes = selectedModels.getAt(i).getDataByColumnName('VariableIndex');
                selectModelMap(i,varIndexes) = true; 
            end
            
            columnToRemove = sum(selectModelMap) == 0;
            selectModelMap(:,columnToRemove) = [];
            h = figure();
            spy(selectModelMap);
        end

        function h = viewPerformancePlot( this, varargin )
            stats = this.model.get('Stats').get('ModelSelectPerf');
            p = inputParser();
            p.addParameter('Color','b',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('LineStyle','-',@ischar);
            p.addParameter('Marker','o',@ischar);
            p.addParameter('MarkerEdgeColor','auto',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerFaceColor','w',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerSize',6,@isnumeric);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            c = biotracs.core.color.Color.colormap();
            style{1} = { ...
                'Color', c(1,:), ...
                'LineStyle', '-', ...
                'Marker', p.Results.Marker, ...
                'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                'MarkerSize', p.Results.MarkerSize, ...
                };
            
            style{2} = { ...
                'Color', c(2,:), ...
                'LineStyle', '-', ...
                'Marker', p.Results.Marker, ...
                'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                'MarkerSize', p.Results.MarkerSize, ...
                };
            
            [r] = this.model.computeOptimalModelStatistics();            
            idx = stats.getColumnIndexesByName('^R2Y$');
            h = plotMe({3,1,1}, style{1}, true, false);
            idx = stats.getColumnIndexesByName('^Q2Y$');
            plotMe({3,1,1}, style{2}, false, true);
            xlabel(''); legend({'R2Y','Q2Y'});
            
            if r.H
                title(sprintf('H = 1, %s \\in [%1.2f, %1.2f] with p \\in [%0.3g, %0.3g]', strrep(r.name,'_','-'), r.TStatistics(1), r.TStatistics(2), r.PValue(1), r.PValue(2)));
            else
                title(sprintf('H = 0, %s = %1.2f, p = %0.3g', strrep(r.name,'_','-'), r.TStatistics(1), r.PValue(1)));
            end

            idx = stats.getColumnIndexesByName('^E2$');
            plotMe({3,1,2}, style{1}, false, false);
            idx = stats.getColumnIndexesByName('^CV_E2$');
            plotMe({3,1,2}, style{2}, false, true);
            xlabel(''); title(''); legend({'E2','CV-E2'});
            
            idx = stats.getColumnIndexesByName('^PValue$');
            plotMe({3,1,3}, style{1}, false, true);
            title('');
            
            set(gcf, 'Units', 'normalized');
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1), min([0.1,pos(2)]), pos(3), max([0.7,pos(4)])]);
            
            function h = plotMe( iSubplotPos, iStyle, isNewFigure, iPlotBars )
                h = stats.view('Plot', 'ColumnIndexes', [1,idx], 'SubPlot', iSubplotPos, 'NewFigure', isNewFigure, iStyle{:}); hold on;
                if iPlotBars
                    yLim = ylim();
                    if r.H
                        plot( r.NbVariables(1), stats.data(r.NbVariables(1),idx), 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
                        plot( [r.NbVariables(1), r.NbVariables(1)], yLim, '-r', 'LineWidth', 1.5);
                        plot( r.NbVariables(2), stats.data(r.NbVariables(2),idx), 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
                        plot( [r.NbVariables(2), r.NbVariables(2)], yLim, '-r', 'LineWidth', 1.5);
                    else
                        plot( r.NbVariables(1), stats.data(r.NbVariables(1),idx), 'Marker', 'o', 'MarkerFaceColor', [0.5,0.5,0.5], 'MarkerEdgeColor', [0.5,0.5,0.5]);
                        plot( [r.NbVariables(1), r.NbVariables(1)], yLim, '-', 'LineWidth', 1.5, 'Color', [0.5,0.5,0.5]);
                    end
                    ylim(yLim)
                end
            end
        end
        
    end
    
    methods

        
    end
    
end
