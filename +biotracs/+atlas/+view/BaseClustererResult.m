% BIOASTER
%> @file		BaseLearnerResult.m
%> @class		biotracs.atlas.view.BaseClustererResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseClustererResult < biotracs.atlas.view.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewClusterPlot( this, varargin )
            %retrieve model
            model = this.getModel();

            %retrieve results
            classes = model.get('InstanceClasses').getData();
            if isempty( classes )
                error('No class found');
            end
            centroids = model.get('InstanceClassCentroids').getData();
            
            p = inputParser();
            p.addParameter('NbDimensions',2,@isnumeric);
            p.addParameter('Title','Cluster plot',@ischar);
            p.addParameter('XLabel','',@ischar);
            p.addParameter('YLabel','',@ischar);
            p.addParameter('ZLabel','',@ischar);
            p.addParameter('NewFigure', true, @islogical);
            p.addParameter('Subplot', {1,1,1}, @iscell);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            config = model.getProcess().getConfig();
            Xtr = model.getTrainingSet().getData();
            Xtr = biotracs.math.centerscale( ...
                Xtr, [], ...
                'Center' , config.getParamValue('Center'), ...
                'Scale', config.getParamValue('Scale'), ...
				'Direction', config.getParamValue('StandardizationDirection') ...
                );
            
            if p.Results.NewFigure
                h = figure;
            else
                h = gca;
            end
            subplot( p.Results.Subplot{:} );
            
            ndim = min( p.Results.NbDimensions, length(centroids.mu{1} == 2) );
            
            %colormap lines;
            rgbPanel = biotracs.core.color.Color.colormap(); %colormap();
            classColors = rgbPanel( classes, : );

            if ndim == 1
                scatter( 1:length(Xtr(:,1)), Xtr(:,1), 38, classColors, 'filled' );
                hold on
                for i=1:length(centroids.mu)
                    plot( ...
                        i, ...
                        centroids.mu{i}(:,1), ...
                        'kx', 'MarkerSize', 10, 'LineWidth', 2 ...
                        );
                    %@ToDo : plot ellipse 1D
                end
            elseif ndim == 2
                scatter( Xtr(:,1), Xtr(:,2), 38, classColors, 'filled' );
                hold on
                this.doPlotEllipse2D( Xtr(:,1:2), 'LineStyle', '--', 'Color', [0.5,0.5,0.5] );
                for i=1:length(centroids.mu)
                    plot( ...
                        centroids.mu{i}(:,1), ...
                        centroids.mu{i}(:,2), ...
                        'kx', 'MarkerSize', 10, 'LineWidth', 2 ...
                        );
                    cXtr = Xtr(classes==i,1:2);
                    [m,n] = size(cXtr);
                    if m > n
                        this.doPlotEllipse2D( cXtr, 'LineStyle', '--', 'Color', rgbPanel(i,:) );
                    end
                end
            elseif ndim >= 3
                if ndim > 3
                    disp('Warning: At most 3 dimensions can be plotted');
                end
                
                scatter3( Xtr(:,1), Xtr(:,2), Xtr(:,3), 38, classColors, 'filled' );
                hold on
                this.doPlotEllipse3D( Xtr(:,1:3) ); %default color
  
                for i=1:length(centroids.mu)
                    plot3( ...
                        centroids.mu{i}(:,1), ...
                        centroids.mu{i}(:,2), ...
                        centroids.mu{i}(:,3), ...
                        'kx', 'MarkerSize', 10, 'LineWidth', 2 ...
                        );
                end
                if ~isempty( p.Results.ZLabel )
                    zlabel( p.Results.ZLabel );
                end
            else
                error('Wrong number of dimension to plot. Number of dimensions must be >= 1.');
            end
            
            if ~isempty( p.Results.XLabel )
                xlabel( strrep(p.Results.XLabel, '_', '-') );
            end
            
            if ~isempty( p.Results.YLabel )
                ylabel( strrep(p.Results.YLabel, '_', '-') );
            end
            
            hold on
            if isempty( p.Results.Title )
                t = sprintf(...
                    'Clustering - %s, %d clusters', ...
                    config.getParamValue('Method'), ...
                    config.getParamValue('MaxNbClusters') ...
                    );
                title( strrep(t, '_', '-') );
            else
                title( strrep(p.Results.Title, '_', '-') );
            end
            box on;
            grid on;
            
            %show texts
            instanceLabels = this.buildInstanceLabels( varargin{:} );
            for i=1:size(Xtr,1)
                x = double(Xtr(i,1));
                if ndim == 1
                    text( i, x, instanceLabels{i}, 'FontSize', 10 );
                elseif ndim == 2
                    y = double(Xtr(i,2));
                    text( x, y, instanceLabels{i}, 'FontSize', 10 );
                else
                    y = double(Xtr(i,2));
                    z = double(Xtr(i,3));
                    text( x, y, z, instanceLabels{i}, 'FontSize', 10 );
                end
            end
        end
        
        function h = viewSimilarityPlot( this, varargin )
            model = this.getModel();
            trSet = model.get('TrainingSet');            
            Xtr = biotracs.math.centerscale( ...
                trSet.getData(), [], ...
                'Center' , model.process.getParamValue('Center'), ...
                'Scale', model.process.getParamValue('Scale'), ...
				'Direction', model.process.getParamValue('StandardizationDirection') ...
                );
            
            covData = corr(Xtr);
            nodeNames = trSet.getRowNames();
            h =[];
           clustergram(covData, 'RowLabels', nodeNames, 'ColumnLabels', nodeNames);
        end
        
        function h = viewCovarianceGraph( this, varargin )
            model = this.getModel();
            trSet = model.get('TrainingSet');            
            Xtr = biotracs.math.centerscale( ...
                trSet.getData(), [], ...
                'Center' , model.process.getParamValue('Center'), ...
                'Scale', model.process.getParamValue('Scale'), ...
				'Direction', model.process.getParamValue('StandardizationDirection') ...
                );
            
            covData = corr(Xtr); %abs(Xtr);
            nodeNames = trSet.getRowNames();
            
            %render the matrix symmetric
            n = size(covData,1);
            for i=1:n
                covData(i,i) = 0;
                for j=1:i-1
                    if covData(i,j) < 0.7
                       covData(i,j) = 0;
                       covData(j,i) = 0;
                    end
                    covData(j,i) = covData(i,j);
                end
            end

            G = graph(covData,nodeNames);
            
            %color nodes
            %G.Nodes.NodeColors;
            
            figure;
            h = plot(G,'Layout','force');
            h.NodeColor = 'red';
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        
        
    end
end
