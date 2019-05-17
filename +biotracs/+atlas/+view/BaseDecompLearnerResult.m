% BIOASTER
%> @file		BaseDecompLearnerResult.m
%> @class		biotracs.atlas.view.BaseDecompLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef BaseDecompLearnerResult < biotracs.atlas.view.BaseLearnerResult
    
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
        
        function h = viewScorePlot( this, varargin )
            p = inputParser();
            p.addParameter('NbComponents',[],@isnumeric);
            p.addParameter('PlotType','X', @(x)(ischar(x) && (strcmp(x,'X') || strcmp(x,'Y'))) );
            p.addParameter('Title','',@ischar);
            p.addParameter('ShowSubtitle',true,@islogical);
            p.addParameter('ClusteringResult',[],@(x)isa(x,'biotracs.atlas.model.BaseClustererResult'));
            p.addParameter('NewFigure', true,@islogical);
            p.addParameter('Subplot', {1,1,1}, @iscell);
            p.addParameter('PointSize', 38, @isnumeric);
            p.addParameter('ColorPanel', biotracs.core.color.Color.colormap(), @isnumeric);
            p.addParameter('ComponentName', 't', @ischar);
            
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            %If a clustering result is provided, identified clusters are
            %showed in colors
            model = this.getModel();
            varXExp = model.getXVarExplainedData();
            ncomps = length(varXExp);
            
            if ~isempty(p.Results.NbComponents)
                ncomps = min(p.Results.NbComponents,ncomps);
            end
            
            if model.hasCrossValidationData()
                ncomps = model.getOptimalNbComponents();
            end
            
            varXExp = varXExp(1:ncomps);
            if model.hasElement('YVarExplained')
                varYExp = model.getYVarExplainedData();
                varYExp = varYExp(1:ncomps);
            else
                varYExp = [];
            end
            
            if ~isempty( p.Results.ClusteringResult )
                h = p.Results.ClusteringResult.view( ...
                    'ClusterPlot', ...
                    varargin{:}, ...
                    'XLabel', biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ), ...
                    'YLabel', biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp, p.Results.ComponentName ), ...
                    'ZLabel', biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 3, varXExp, varYExp, p.Results.ComponentName ) ...
                    );
            else
                h = this.doViewScorePlot( varargin{:} );
            end
            
            %create title and subtitle
            if isempty(p.Results.Title)
                titleStr = '';
            else
                titleStr = strrep(p.Results.Title, '_', '-');
            end
            subtitleStr = sprintf('A=%d', ncomps);
            
            learningStats = model.getStats();
            R2X = learningStats.get('R2X').data;
            R2Y = learningStats.get('R2Y').data;
            if ~isempty(R2X) && isempty(R2Y)
                subtitleStr = sprintf( '%s, R2X=%1.2f', subtitleStr, R2X(ncomps) );
            end
            if ~isempty(R2Y)
                subtitleStr = sprintf( '%s, R2Y=%1.2f', subtitleStr, R2Y(ncomps) );
            end
            
            Q2X = learningStats.get('Q2X').data;
            Q2Y = learningStats.get('Q2Y').data;
            
            if ~isempty(Q2X) && isempty(Q2Y)
                subtitleStr = sprintf( '%s, Q2X=%1.2f', subtitleStr, Q2X(ncomps) );
            end
            if ~isempty(Q2Y)
                subtitleStr = sprintf( '%s, Q2Y=%1.2f', subtitleStr, Q2Y(ncomps) );
            end
            
            E2 = learningStats.get('E2').data;
            cvE2 = learningStats.get('CV_E2').data;
            if ~isempty(E2) && ~any(isnan(E2))
                subtitleStr = sprintf( '%s, E2=%1.2f', subtitleStr, E2(ncomps) );
            end
            if ~isempty(cvE2) && ~any(isnan(E2))
                subtitleStr = sprintf( '%s, CV-E2=%1.2f', subtitleStr, cvE2(ncomps) );
            end
            
            if isempty(titleStr)
                if p.Results.ShowSubtitle
                    title(['\fontsize{10}', subtitleStr]);
                end
            else
                if p.Results.ShowSubtitle
                    title( {['\fontsize{12}',titleStr], ['\fontsize{10}', subtitleStr]});
                else
                    title(['\fontsize{12}',titleStr]);
                end
            end
            grid on;
            box on;
        end
        
        function h = viewLoadingPlot( this, varargin )
            model = this.getModel();
            
            p = inputParser();
            p.addParameter('NbComponents',[],@isnumeric);
            p.addParameter('NbDimensions',2,@isnumeric);
            p.addParameter('LabelFormat','long',@(x)(ischar(x) || iscell(x)));
            p.addParameter('Title','',@ischar);
            p.addParameter('PlotType','X', @(x)(ischar(x) && (strcmp(x,'X') || strcmp(x,'Y'))) );
            p.addParameter('NewFigure', true,@islogical);
            p.addParameter('Subplot', {1,1,1}, @iscell);
            p.addParameter('PointSize', 38, @isnumeric);
            p.addParameter('ColorPanel', 38, @isnumeric);
            p.addParameter('ComponentName', 't', @ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if p.Results.NewFigure
                h = figure;
            else
                h = gca;
            end
            subplot( p.Results.Subplot{:} );
            
            varXExp = model.getXVarExplainedData();
            ncomps = length(varXExp);
            if ~isempty(p.Results.NbComponents)
                ncomps = min(p.Results.NbComponents,ncomps);
                varXExp = varXExp(1:ncomps);
            end
            
            if model.hasElement('YVarExplained')
                varYExp = model.getYVarExplainedData();
                varYExp = varYExp(1:ncomps);
            else
                varYExp = [];
            end
            
            if strcmp(p.Results.PlotType, 'Y')
                loadings = model.getYLoadingData();
            else
                loadings = model.getXLoadingData();
            end
            
            nbDim = min( [p.Results.NbDimensions, ncomps, 3] );
            if nbDim < p.Results.NbDimensions
                biotracs.core.env.Env.writeLog('Only %d components can be plotted', nbDim);
            end
            
            varNames = this.buildVariableLabels( varargin{:} );
            n = length(varNames);
            colorPanel = p.Results.ColorPanel;
            if isempty(colorPanel)
                colorPanel = biotracs.core.color.Color.colormap();
            end
            classColors = repmat(colorPanel(1,:),n,1);
            if nbDim == 1
                Y = ones( n,1 );
                scatter(loadings(:,1), Y, p.Results.PointSize, classColors, 'filled');
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                %show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:n
                        text( loadings(i,1), 1, varNames{i}, 'Rotation', 45, 'FontSize', 9 );
                    end
                end
            elseif nbDim == 2
                scatter(loadings(:,1), loadings(:,2), p.Results.PointSize, classColors, 'filled');
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp, p.Results.ComponentName ) );
                
                %show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:n
                        text( loadings(i,1), loadings(i,2), ['  ', varNames{i}], 'FontSize', 9 );
                    end
                end
            elseif nbDim == 3
                scatter(loadings(:,1), loadings(:,2), loadings(:,3), p.Results.PointSize, classColors, 'filled');
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp, p.Results.ComponentName ) );
                zlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 3, varXExp, varYExp, p.Results.ComponentName ) );
                
                %show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:n
                        text( loadings(i,1), loadings(i,2), loadings(i,3), ['  ', varNames{i}], 'FontSize', 9 );
                    end
                end
            else
                error('Number of components must be >= 1');
            end
            
            if strcmp(p.Results.Title, '')
                title( [ p.Results.PlotType, ' Loading Plot'] );
            else
                title( strrep(p.Results.Title, '_', '-') );
            end
            grid on
        end
        
        function h = viewVariancePlot( this, varargin )
            model = this.getModel();
            
            p = inputParser();
            p.addParameter('PlotType','X', @(x)(ischar(x) && (strcmp(x,'X') || strcmp(x,'Y'))) );
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if strcmp( p.Results.PlotType, 'Y' )
                varExp = model.getYVarExplainedData();
            else
                varExp = model.getXVarExplainedData();
            end
            
            h = figure;
            plot(1:length(varExp),cumsum(varExp),'-bo');
            xlabel('PC');
            ylabel('Var. exp.');
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function h = doViewScorePlot( this, varargin )
            p = inputParser();
            p.addParameter('NbComponents',[],@isnumeric);
            p.addParameter('NbDimensions',2,@isnumeric);
            p.addParameter('LabelFormat','long',@(x)(ischar(x) || iscell(x)));
            p.addParameter('GroupList', {}, @iscell);
            p.addParameter('GroupColors', {}, @iscell);
            p.addParameter('ColorPanel', biotracs.core.color.Color.colormap(), @isnumeric);
            p.addParameter('ShowLegend', false, @islogical);
            p.addParameter('Title','',@ischar);
            p.addParameter('PlotType','X', @(x)(ischar(x) && (strcmp(x,'X') || strcmp(x,'Y'))) );
            p.addParameter('NewFigure', true, @islogical);
            p.addParameter('Subplot', {1,1,1}, @iscell);
            p.addParameter('PointSize', 38, @isnumeric);
            p.addParameter('GroupEllipses', {}, @iscellstr);
            p.addParameter('EllipseConfidence', 0.95, @isnumeric);
            p.addParameter('ComponentName', 't', @ischar);
            p.addParameter('BiplotVariables', {}, @iscellstr);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            model = this.getModel();
            
            colorPanel = p.Results.ColorPanel;
            if isempty(colorPanel)
                colorPanel = biotracs.core.color.Color.colormap();
            end
                
            varXExp = model.getXVarExplainedData();
            ncomps = length(varXExp);
            if ~isempty(p.Results.NbComponents)
                ncomps = min(p.Results.NbComponents,ncomps);
                varXExp = varXExp(1:ncomps);
            end
            
            if model.hasElement('YVarExplained')
                varYExp = model.getYVarExplainedData();
                varYExp = varYExp(1:ncomps);
            else
                varYExp = [];
            end
            
            if strcmp(p.Results.PlotType, 'Y')
                iScores = model.getYScoreData();
            else
                iScores = model.getXScoreData();
            end
            
            % compute instance groups if possible
            trSet = model.getTrainingSet();

            grpStrat = biotracs.data.helper.GroupStrategy( trSet.rowNames, p.Results.GroupList );
            [ logicalClassIdx, classNames, numClassIndexes ] = grpStrat.getSlicesIndexes();
            if sum(numClassIndexes) == 0    %no numClassIndexes found
                numClassIndexes = ones(size(numClassIndexes));
            end
            
            % create figure
            if p.Results.NewFigure
                h = figure;
            else
                h = gca;
            end
            subplot( p.Results.Subplot{:} );
            
            % create class color            
            nbColors = size(colorPanel,1);
            nbPoints = size(numClassIndexes,1);
            colorPanel = repmat(colorPanel,fix(nbPoints/nbColors)+1,1);
            classColors = colorPanel( numClassIndexes, : );

            % assign specific colors to groups
            if ~isempty(p.Results.GroupColors)
                greyColorAssigned = false;
                for i=1:2:length(p.Results.GroupColors)
                    currentGrp = p.Results.GroupColors{i};
                    if ~ischar(currentGrp)
                        error('SPECTRA:Pcomp:LearnerResultView', 'GroupColor must be {key,val} cell and key must be string and val must be a rgb numeric array');
                    end
                    currentColor = p.Results.GroupColors{i+1};
                    idx = ~cellfun( @isempty, regexp(classNames, currentGrp, 'once') );
                    if any(idx)
                        allIdx = any(logicalClassIdx(:,idx),2);
                        classColors(allIdx,:) = repmat(currentColor, sum(allIdx), 1);
                        %set all the other colors black (by default)
                        if ~greyColorAssigned
                            classColors(~allIdx,:) = repmat([1,1,1]*0.5, sum(~allIdx), 1);
                            greyColorAssigned = true;
                        end
                    end
                end
            end

            iNames      = this.buildInstanceLabels( varargin{:} );
            ndim        = min(p.Results.NbDimensions, ncomps);
            if ndim == 1
                Y = ones( length(iScores(:,1)) ,1 );
                if isempty(logicalClassIdx)
                    scatter( iScores(:,1), Y, p.Results.PointSize, colorPanel(1,:), 'filled' );
                else
                    for i=1:size(logicalClassIdx,2)
                        idx = logicalClassIdx(:,i);
                        scatter( iScores(idx,1), Y(idx), p.Results.PointSize, classColors(idx,:), 'filled' );
                        hold on
                    end
                end
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                
                %Show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:length(iNames)
                        text( iScores(i,1), 1, iNames{i}, 'Rotation', 45, 'FontSize', 9 );
                    end
                end
            elseif ndim == 2
                if isempty(logicalClassIdx)
                    scatter( iScores(:,1), iScores(:,2), p.Results.PointSize, colorPanel(1,:), 'filled' );
                else
                    for i=1:size(logicalClassIdx,2)
                        idx = logicalClassIdx(:,i);
                        scatter( iScores(idx,1), iScores(idx,2), p.Results.PointSize, classColors(idx,:), 'filled' );
                        hold on
                    end
                end
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp, p.Results.ComponentName ) );
                
                %Show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:length(iNames)
                        text( iScores(i,1), iScores(i,2), ['  ', iNames{i}], 'FontSize', 9 );
                    end
                end

                if ~isempty(p.Results.GroupEllipses)
                    if any(strcmpi(p.Results.GroupEllipses, {'.*'}))
                        this.doPlotEllipse2D( iScores(:,1:2), 'Color', colorPanel(1,:), 'EllipseConfidence', p.Results.EllipseConfidence );
                    else
                        [~,lb] = ismember(p.Results.GroupEllipses, classNames);
                        for i=1:length(lb)
                            this.doPlotEllipse2D( iScores(logicalClassIdx(:,lb(i)),1:3), 'FaceColor', colorPanel(lb(i),:),  'EllipseConfidence', p.Results.EllipseConfidence );
                        end
                    end
                end
                
                %Biplo0t
                if ~isempty(p.Results.BiplotVariables)
                    loadings = model.getXLoadings();
                    maxW = max(abs(loadings.data(:,1:2)));
                    xweight = 0.75*max(abs(xlim()))/maxW(1);
                    yweight = 0.75*max(abs(ylim()))/maxW(2);
                    plot(0,0,'b+');
                    for i=1:length(p.Results.BiplotVariables)
                        varName = p.Results.BiplotVariables{i};
                        %varDataSet = trSet.selectByColumnName(varName);
                        loadData = loadings.getDataByRowName(varName);
                        if isempty(loadData), continue; end
                        x = [0, loadData(1)]*xweight;
                        y = [0, loadData(2)]*yweight;
                        plot( x,y, 'b' );
                        plot( loadData(1)*xweight, loadData(2)*yweight, 'b+' );
                        text( loadData(1)*xweight, loadData(2)*yweight, ['  ', varName], 'FontSize', 9 );
                    end
                end
            elseif ndim >= 3
                if ndim > 3
                    disp('Warning: At most 3 components can be plotted');
                end
                
                if isempty(logicalClassIdx)
                    scatter3( iScores(:,1), iScores(:,2), iScores(:,3), p.Results.PointSize, colorPanel(1,:), 'filled' );
                else
                    for i=1:size(logicalClassIdx,2)
                        idx = logicalClassIdx(:,i);
                        scatter3( iScores(idx,1), iScores(idx,2), iScores(idx,3), p.Results.PointSize, classColors(idx,:), 'filled' );
                        hold on
                    end
                end
                
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp, p.Results.ComponentName ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp, p.Results.ComponentName ) );
                zlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 3, varXExp, varYExp, p.Results.ComponentName ) );
                
                %Show texts
                if ~strcmp(p.Results.LabelFormat, 'none')
                    for i=1:length(iNames)
                        text( iScores(i,1), iScores(i,2), iScores(i,3), ['  ', iNames{i}], 'FontSize', 9 );
                    end
                end

                if ~isempty(p.Results.GroupEllipses)
                    if any(strcmpi(p.Results.GroupEllipses, {'.*'}))
                        this.doPlotEllipse3D( iScores(:,1:3), 'FaceColor', colorPanel(1,:),  'EllipseConfidence', p.Results.EllipseConfidence );
                    else
                        [~,lb] = ismember(p.Results.GroupEllipses, classNames);
                        for i=1:length(lb)
                            this.doPlotEllipse3D( iScores(logicalClassIdx(:,lb(i)),1:3), 'FaceColor', colorPanel(lb(i),:),  'EllipseConfidence', p.Results.EllipseConfidence );
                        end
                    end
                end
            else
                error('Number of components must be >= 1');
            end
            
            if p.Results.ShowLegend
                legend(regexprep(classNames,'.+:([^_]+)', '$1'));
                %legend('boxoff')
            end
        end
        
        
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
        
        function str = buildScorePlotAxisLabel( iComp, iVarXExp, iVarYExp, iComponentName )
            if nargin <= 3 || isempty(iComponentName)
                iComponentName = 't';
            end

            str = sprintf('%s[%d]', iComponentName, iComp);
            if length(iVarXExp) >= iComp
                str = sprintf( '%s - Var[X] = %1.1f%%', str, iVarXExp(iComp) );
            end
            if nargin == 3 && length(iVarYExp) >= iComp
                str = sprintf( '%s - Var[Y] = %1.1f%%', str, iVarYExp(iComp) );
            end
        end
        
    end
    
end
