% BIOASTER
%> @file		BaseDecompPredictorResult.m
%> @class		biotracs.atlas.view.BaseDecompPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef BaseDecompPredictorResult < biotracs.atlas.view.BasePredictorResult
    
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
        
        %function h = viewProjectionOnScorePlot( this, varargin )
        %    h = this.doViewProjectionOnScorePlot( varargin{:} );
        %end
        
        function h = viewXProjectionOnScorePlot( this, varargin )
            h = this.doViewProjectionOnScorePlot( varargin{:}, 'PlotType', 'X' );
        end
        
        function h = viewYProjectionOnScorePlot( this, varargin )
            h = this.doViewProjectionOnScorePlot( varargin{:}, 'PlotType', 'Y' );
        end
        
    end
    
    
    methods( Access = protected )
        
        function h = doViewProjectionOnScorePlot( this, varargin )
            model = this.getModel();
            
            p = inputParser();
            p.addParameter('PlotType','X', @(x)(ischar(x) && (strcmp(x,'X') || strcmp(x,'Y'))) );
            p.addParameter('LabelFormat','none',@(x)(iscell(x) || ischar(x)));
            p.addParameter('NbComponents',2,@isnumeric);
            p.addParameter('ScorePlotAxes',[], @(x)(isa(x,'matlab.graphics.axis.Axes')) );
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if ~isempty(p.Results.ScorePlotAxes)
                ax = p.Results.ScorePlotAxes;
                h = ax.Parent;
                figure(h);
                set(h, 'currentaxes', ax);      %# for axes with handle axs on figure f
                hold(ax, 'on');
            else
                h = figure;
                ax = gca();
                %ax = newplot;
                %h = ax.Parent;
            end
            
            if strcmp(p.Results.PlotType, 'Y')
                proj = model.getYProjectionData();
            else
                proj = model.getXProjectionData();
            end

            nbcomp = min( [p.Results.NbComponents, size(proj, 2), 3] );
            if nbcomp < p.Results.NbComponents
                biotracs.core.env.Env.writeLog('Only %d components can be plotted\n', nbcomp);
            end
            
            markerColor = 'blue';
            markerEdgeColor = 'blue';
            instanceNames = this.buildInstanceLabels( varargin{:} );
            if nbcomp == 1
                Y = ones( length(proj(:,1)) ,1 );
                plot(ax, proj(:,1), Y, 'b*', 'MarkerEdgeColor', markerEdgeColor, 'MarkerFaceColor', markerColor);
                
                %show texts
                if ~strcmp( p.Results.LabelFormat, 'none' )
                    for i=1:length(instanceNames)
                        text( proj(i,1), 1, instanceNames{i}, 'Rotation', 45, 'FontSize', 9 );
                    end
                end
            elseif nbcomp == 2
                plot(ax, proj(:,1), proj(:,2), 'b*', 'MarkerEdgeColor', markerEdgeColor, 'MarkerFaceColor', markerColor);
                
                %show texts
                if ~strcmp( p.Results.LabelFormat, 'none' )
                    for i=1:length(instanceNames)
                        text( proj(i,1), proj(i,2), instanceNames{i}, 'FontSize', 9 );
                    end
                end
            elseif nbcomp >= 3
                plot3(ax, proj(:,1), proj(:,2), proj(:,3), 'b*', 'MarkerEdgeColor', markerEdgeColor, 'MarkerFaceColor', markerColor);
                
                %show texts
                if ~strcmp( p.Results.LabelFormat, 'none' )
                    for i=1:length(instanceNames)
                        text( proj(i,1), proj(i,2), proj(i,3), instanceNames{i}, 'FontSize', 9 );
                    end
                end
            else
                error('Number of components must be >= 1');
            end
            
            grid on
        end
        
    end
    
end
