% BIOASTER
%> @file		BaseLearnerResult.m
%> @class		biotracs.atlas.view.BaseLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseLearnerResult < biotracs.atlas.view.BaseResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewMsePlot( this, varargin )
            model = this.getModel();
            learningStats = model.getStats();
            XMsee = learningStats.get('MSEE_X').getData();
            XMsep = learningStats.get('MSEP_X').getData();
            YMsee = learningStats.get('MSEE_Y').getData();
            YMsep = learningStats.get('MSEP_Y').getData();

            if isempty(XMsee) && isempty(XMsep) 
                biotracs.core.env.Env.writeLog('No MSEE and MSEP data available in the learning result %s', class(model));
                h = -1; return;
            else
                h = figure;
            end
            
            if isempty(XMsee) || isempty(XMsep)
                g = [2,1];
            else
                g = [2,2];
            end
                
            % plot msee
            if ~isempty(XMsee)
                n = length(XMsee);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                subplot(g(1),g(2),1)
                plot(x,XMsee,'-b*');
                xlim(xLim);
                xlabel('PC');
                ylabel('MSEE [X]');
                grid on;
                title('Estimation');
                
                if isempty(YMsee)
                    subplot(g(1),g(2),2)
                else
                    subplot(g(1),g(2),3)
                end
                plot(x,YMsee,'-b*'); hold on;
                xlim(xLim);
                xlabel('PC');
                ylabel('MSEE [Y]');
                grid on;
            else
                biotracs.core.env.Env.writeLog('No MSEE statistics available in the learning result %s', class(model));
            end
            
            %plot msep
            if ~isempty(XMsep)
                n = length(XMsep);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                subplot(g(1),g(2),2)
                plot( x, XMsep,'-b*' ); hold on;
                xlim(xLim);
                xlabel('PC');
                ylabel('MSEP [X]');
                grid on;
                title('Prediction');
                
                k = model.getOptimalNbComponents( 'Criterion', 'MSE' );
                subplot(g(1),g(2),4)
                plot( x,YMsep,'-b*' ); hold on
                yLim = ylim();
                plot( [k, k], yLim, '--r' );
                xlim(xLim);
                ylim(yLim);
                xlabel('PC');
                ylabel('MSEP [Y]');
                grid on;
            else
                h = [];
                biotracs.core.env.Env.writeLog('No MSEP statistics available in the learning result %s', class(model));
            end
        end
        
        function h = viewQ2Plot( this, varargin )
            model = this.getModel();
            learningStats = model.getStats();
            Q2X = learningStats.get('Q2X').getData();
            Q2Y = learningStats.get('Q2Y').getData();

            if isempty(Q2X) && isempty(Q2X) 
                biotracs.core.env.Env.writeLog('No Q2 statistics available in the learning result %s', class(model));
                h = -1; return;
            else
                h = figure();
            end
            
            if isempty(Q2X) || isempty(Q2Y)
                g = [1,1];
            else
                g = [2,1];
            end
            
            axIdx = 1;
            if ~isempty(Q2X)
                subplot(g(1),g(2),axIdx)
                n = length(Q2X);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                plot(x,Q2X,'-b*');
                xlim(xLim);
                ylabel('Q2[X]');
                grid on;  
                axIdx = axIdx + 1;
                
                title('Q2');
                if isempty(Q2Y)
                    xlabel('PC');
                end
            end
            
            if ~isempty(Q2Y)
                k = model.getOptimalNbComponents( 'Criterion', 'Q2' );
                subplot(g(1),g(2),axIdx)
                n = length(Q2Y);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                plot(x,mean(Q2Y,2),'-b*'); hold on;
                yLim = ylim();
                plot( [k, k], yLim, '--r' );
                xlim(xLim);
                ylim(yLim);
                xlabel('PC');
                ylabel('Q2[Y]');
                grid on;
                
                if isempty(Q2X)
                    title('Q2');
                end
            end
        end
        
        function h = viewE2Plot( this, varargin )
            model = this.getModel();
            learningStats = model.getStats();
            E2 = learningStats.get('E2').getData();
            cvE2 = learningStats.get('CV_E2').getData();

            if isempty(E2) && isempty(cvE2)
                h = [];
                biotracs.core.env.Env.writeLog('No data available in the learning result %s', class(model));
                return;
            end
            
            h = figure();
            subplotIdx = 1;
            if isempty(E2) || isempty(cvE2)
                g = [1,1];
            else
                g = [2,1];
            end
            
            if ~isempty(E2)
                subplot(g(1),g(2),subplotIdx);
                n = length(E2);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                plot(x,E2,'-b*');
                xlim(xLim);
                hold on;
                xlabel('PC');
                ylabel('E2');
                grid on;
                title('Balanced error rate E2');
                subplotIdx = subplotIdx+1;
            end
            
            if ~isempty(cvE2)
                k = model.getOptimalNbComponents( 'Criterion', 'E2' );
                subplot(g(1),g(2),subplotIdx);
                n = length(cvE2);
                x = 1:n;
                xLim = [x(1), x(end)];
                
                plot(x,cvE2,'-b*'); hold on;
                yLim = ylim();
                plot( [k, k], yLim, '--r' );
                xlim(xLim);
                ylim(yLim);
                hold on;
                xlabel('PC');
                ylabel('CV E2');
                grid on;
                
                if ~isempty(E2)
                    title('Balanced error rate E2');
                end
            end
        end
        
        function h = viewPermutationPlot( this, varargin )
            model = this.getModel();
            if model.isDiscriminantAnalysis()
                criterion = 'E2';
            else
                criterion = 'R2Y';
            end
            
            p = inputParser();
            p.addParameter('Criterion', criterion, @(x)(ischar(x) && any(strcmp(x,{'E2', 'R2Y'}))));
            p.addParameter('Title', 'Permutation plot', @ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            permCriterion = ['Perm',p.Results.Criterion];
            learningStats = model.getStats();
            statDataTable = learningStats.get( permCriterion  );

            hasPermutationTests = ~(isempty(statDataTable) || hasEmptyData(statDataTable));
            if ~hasPermutationTests
                h = [];
                biotracs.core.env.Env.writeLog('No permutation test data found in the learning result %s. You did probably not perform permutation testing', class(model));
                return;
            end
 
            h = statDataTable.view('Histogram', 'LineStyle', 'line', varargin{:});
            grid on;
            
            titleStr = [ p.Results.Title,' ', p.Results.Criterion ];
            if strcmp(p.Results.Criterion, 'E2')
                cvCriterionName = 'CV_E2';
            elseif strcmp(p.Results.Criterion, 'R2Y')
                cvCriterionName = 'Q2Y';
            end

            hold on;
            if learningStats.hasElement(p.Results.Criterion)
                %normal statistics
                [ r ] = model.getPermutationTestSignificance( varargin{:} );
                statValue = r.getDataFor(['^',p.Results.Criterion,'$'], '^TStatistic$');
                pValue = r.getDataFor(['^',p.Results.Criterion,'$'], '^PValue$');
                subTitleStr = sprintf( '%s = %1.2f (p = %0.2g)', p.Results.Criterion, statValue, pValue );
                yLim = ylim();
                plot( [statValue, statValue], yLim, '-.', 'LineWidth', 1.5, 'Color', [1,1,1]*0.5 );
                
                %cv statistics
                cvStatValue = r.getDataFor(['^',cvCriterionName,'$'], '^TStatistic$');
                if ~isnan(cvStatValue)
                    cvPValue = r.getDataFor(['^',cvCriterionName,'$'], '^PValue$');
                    plot( [cvStatValue, cvStatValue], yLim, '-.', 'LineWidth', 1.5, 'Color', 'red' );
                    subTitleStr = sprintf( '%s, %s = %1.2f (p = %0.2g)', subTitleStr, cvCriterionName, cvStatValue, cvPValue );
                end
                ylim(yLim);
            end
            
            xLim = xlim();
            xlim( [xLim(1)*0.9 xLim(2)*1.1] );
            title( strrep({titleStr,subTitleStr}, '_', '\_') );
        end
        
        %-- B --
        
        function oInstanceLabels = buildInstanceLabels( this, varargin )
           model = this.getModel();
           trSet = model.getTrainingSet();
           oInstanceLabels = biotracs.core.utils.formatLabelForPlot( ...
               trSet.getInstanceNames(), ...
               varargin{:} ...
               );
        end
        
        function oVariableLabels = buildVariableLabels( this, varargin )
		   model = this.getModel();
		   trSet = model.getTrainingSet();
           oVariableLabels = biotracs.core.utils.formatLabelForPlot( ...
			  trSet.getVariableNames(), ...
               varargin{:} ...
		      );
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
  
    end
    
    
end
