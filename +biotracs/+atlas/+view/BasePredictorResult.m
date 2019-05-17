% BIOASTER
%> @file		BasePredictorResult.m
%> @class		biotracs.atlas.view.BasePredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BasePredictorResult < biotracs.atlas.view.BaseResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- B --
        
		function oInstanceLabels = buildInstanceLabels( this, varargin )
           p = inputParser();
           p.addParameter('LabelFormat','long',@(x)(iscell(x) || ischar(x)));
           p.KeepUnmatched = true;
           p.parse(varargin{:});
            
           model = this.getModel();
           testSet = model.getTestSet();
           oInstanceLabels = biotracs.core.utils.formatLabelForPlot( ...
               testSet.getInstanceNames(), ...
               'LabelFormat', p.Results.LabelFormat, ...
               'NameSeparator', testSet.meta.nameSeparator ...
               );
        end
        
        function oVariableLabels = buildVariableLabels( this, varargin )
		   p = inputParser();
           p.addParameter('LabelFormat','long',@(x)(iscell(x) || ischar(x)));
           p.KeepUnmatched = true;
           p.parse(varargin{:});
           
		   model = this.getModel();
		   testSet = model.getTestSet();
           oVariableLabels = biotracs.core.utils.formatLabelForPlot( ...
			  testSet.getVariableNames(), ...
               'LabelFormat', p.Results.LabelFormat, ...
               'NameSeparator', testSet.meta.nameSeparator ...
		      );
        end
		
        function oVariableLabels = buildResponseLabels( this, varargin )
		   p = inputParser();
           p.addParameter('LabelFormat','long',@(x)(iscell(x) || ischar(x)));
           p.KeepUnmatched = true;
           p.parse(varargin{:});
           
		   model = this.getModel();
		   testSet = model.getTestSet();
           pred = model.get('YPredictions');
           oVariableLabels = biotracs.core.utils.formatLabelForPlot( ...
			  pred.getColumnNames(), ...
               'LabelFormat', p.Results.LabelFormat, ...
               'NameSeparator', testSet.meta.nameSeparator ...
		      );
        end
        
        
        %-- V --
        
        function h = viewYPredictionPlot( this, varargin )
            p = inputParser();
            p.addParameter('LabelFormat','none',@(x)(ischar(x) || iscell(x)));
            p.addParameter('Title','Predictions',@ischar);
            p.addParameter('GroupList', {}, @iscell);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            predictionResult = this.getModel();
            
            % retrieve the test set
            predictionProcess = predictionResult.getProcess();
            XYteSet = predictionProcess.getInputPortData('TestSet');
            predictiveModel = predictionProcess.getInputPortData('PredictiveModel');
            
            learningStats = predictiveModel.getStats();
            R2X = learningStats.get('R2X').data;
            ncomp = predictionProcess.getConfig().getParamValue('NbComponents');
            if isempty(ncomp) && predictiveModel.hasCrossValidationData()
                ncomp = predictiveModel.getOptimalNbComponents();
            end
            
            if isempty(ncomp)
                ncomp = size(R2X,1);
            else
                ncomp = min(ncomp, size(R2X,1));
            end
            
            % retrieve the training set and details
            learningProcess = predictiveModel.getProcess();
            XYtrSet = learningProcess.getInputPortData('TrainingSet');

            instanceLabels = this.buildInstanceLabels( varargin{:} );
            responseLabels = this.buildResponseLabels( varargin{:} );
            
            % retrieve predictions
            Ypred = predictionResult.getYPredictionData();
            areErrorBarAvailable = predictionResult.hasElement('YPredictionLowerBounds');
            if areErrorBarAvailable
                YpredLb = predictionResult.getYPredictionDataLowerBounds();
                YpredUb = predictionResult.getYPredictionDataUpperBounds();
            end
            
            % retieve expected responses
            Yte = XYteSet.selectYSet().getData();

            %compute group colors
            grpStrat = biotracs.data.helper.GroupStrategy( XYteSet.rowNames, p.Results.GroupList );
            [ ~, ~, classes ] = grpStrat.getSlicesIndexes();
            hasToShowGroupColors = ~isempty(p.Results.GroupList) && sum(classes) ~= 0;
            if ~hasToShowGroupColors
                classes = ones(1,size(Yte,1));
            end
            rgbPanel    = biotracs.core.color.Color.colormap();
            classColors = rgbPanel( classes, : );

            stats = this.model.get('Stats');
            
            if stats.hasElement('E2Y')
                E2 = stats.get('E2Y').getData();
                R2 = stats.get('R2Y').getData();
                E2i = stats.get('E2Yi').getData();
                R2i = stats.get('R2Yi').getData();
            else
                E2 = nan;
            end
            %responseNames = predictiveModel.getResponseNames();

            % plot
            h = figure();
            nbResponses = length(responseLabels);
            
            if nbResponses > 2
                set(h, 'Unit', 'Normalized', 'Position', [0.1740 0.1806 0.6094 0.6481]);
            end

            g = biotracs.core.utils.optgrid(nbResponses);
            for k=1:nbResponses

                subplot(g(1), g(2), k);
                if isempty(Yte)
                    if areErrorBarAvailable
                        errorbar( ...
                            1:length(Ypred(:,k)), Ypred(:,k), Ypred(:,k)-YpredLb(:,k), YpredUb(:,k)-Ypred(:,k), '.', ...
                            'Color', [1,1,1]*0.65 );
                        hold on;
                    end
                    scatter( 1:length(Ypred(:,k)), Ypred(:,k), 38, classColors, 'filled' );
                    xlabel('Sample');
                    ylabel('Prediction');
                else
                    if areErrorBarAvailable
                        errorbar( ...
                            Yte(:,k), Ypred(:,k), Ypred(:,k)-YpredLb(:,k), YpredUb(:,k)-Ypred(:,k), '.', ...
                            'Color', [1,1,1]*0.65);
                        hold on;
                    end
                    scatter( Yte(:,k), Ypred(:,k), 38, classColors, 'filled' );
                    xlabel('Expectation');
                    ylabel('Prediction');
                end
                    
                % show instance names as texts
                if ~strcmp( p.Results.LabelFormat, 'none' )
                    for i=1:length(instanceLabels)
                        if isempty(Yte)
                            text( i, Ypred(i,k), ['  ', instanceLabels{i}], 'FontSize', 9 );
                        else
                            text( Yte(i,k), Ypred(i,k), ['  ', instanceLabels{i}], 'FontSize', 9 );
                        end
                    end
                end
                
                % plot references/threshold
                if predictiveModel.isDiscriminantAnalysis()
                    %classSepData = classSep.getDataFor('ClassSeparator', ['^',responseNames{k},'$']);
                    Ytr = XYtrSet.selectYSet().getData();
                    Yth = (min(Ytr) + max(Ytr))/2;
                    
                    lb = min( Ytr(:,k) );
                    ub = max( Ytr(:,k) );

                    n = length(Ypred(:,k));
                    x = linspace(0-1, n+1, n+1);
                    hold on
    
                    plot( x, Yth(k)*ones(1,n+1), '--r', 'LineWidth', 1.5 );
                    
                    if ~isempty(Yte)
                        delta = 0.1*(ub-lb);
                        xlim([lb - delta, ub + delta]);
                    else
                        xlim([0,n+1]);
                    end
                    
                    minPred = min(min(Ypred(:,k)), Yth(k));
                    maxPred = max(max(Ypred(:,k)), Yth(k));
                    delta = 0.1*(maxPred-minPred);
                    ylim([min(0,minPred)-delta, max(1,maxPred)+delta]);
                elseif ~isempty(Yte)
                    x = xlim();
                    y = ylim();
                    
                    lb = min([x(:); y(:)]); lb = lb(1);
                    ub = max([x(:); y(:)]); ub = ub(1);
                    delta = 0.1*(ub-lb);
                    lb = lb - delta;
                    ub = ub + delta;
                    
                    hold on
                    plot([lb,ub], [lb,ub], 'r-.');
                    xlim([lb,ub]);
                    ylim([lb,ub]);
                end
                titleStr{1} = [ '\fontsize{12} ', strrep(responseLabels{k}, '_', '-') ];
                titleStr{2} = sprintf('\\fontsize{10} A=%g', ncomp);
                if ~isempty(R2) && ~isnan(R2)
                    titleStr{2} = sprintf('%s, R2=%1.2f, R2i=%1.2f', titleStr{2}, R2, R2i(k));
                end
                
                if predictiveModel.isDiscriminantAnalysis() && ~isempty(E2) && ~isnan(E2)
                    titleStr{2} = sprintf('%s, E2=%1.2f, E2i=%1.2f', titleStr{2},  E2, E2i(k));
                end
                
                title(titleStr);    
                grid on;
            end
        end
        
        function h = viewYPredictionScoreHeatMap( this, varargin )
            p = inputParser();
            p.addParameter('ShowAverage', false, @islogical);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if p.Results.ShowAverage
                scoreMatrix = this.model.get('YPredictionScoreMeans');
            else
                scoreMatrix = this.model.get('YPredictionScores');
            end

            if ~hasEmptyData(scoreMatrix)
                h = scoreMatrix.view('HeatMap', varargin{:});
            else
                h = [];
            end
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
   
    end
    
    
end
