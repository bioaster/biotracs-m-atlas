% BIOASTER
%> @file		HCALearnerResult.m
%> @class		biotracs.atlas.view.HCALearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef HCALearnerResult < biotracs.atlas.view.BaseClustererResult
    
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
        
        function h = viewClusterPlot( this, varargin )
            model = this.getModel();
            config = model.getProcess().getConfig();
            if config.isParamValueEqual('Method', 'hca')
                h = this.viewClusterPlot@biotracs.atlas.view.BaseClustererResult( varargin{:} );
            else
                clustergramObject = model.get('Tree').getData();
                h = clustergramObject.plot();
            end
        end
        
        function h = viewDendrogram( this, varargin )
            model = this.getModel();
            p = inputParser();
            p.addParameter('Title','HCA tree',@ischar);
            p.addParameter('NbClasses', 0, @isnumeric);
            p.addParameter('ColumnLabelsRotation', 90, @isnumeric);
            p.addParameter('FontSize', 9, @isnumeric);
            p.addParameter('RowLabelFormat', '', @iscellstr);
            p.addParameter('ColumnLabelFormat', '', @iscellstr);
            p.addParameter('MaxLabelLength', Inf, @isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
             
            config = model.getProcess().getConfig();
            if config.isParamValueEqual('Method', 'hca')
                h = figure;
                instanceLabels = this.buildInstanceLabels( varargin{:} );
                tree = model.get('Tree').getData();
                
                if p.Results.NbClasses <= 0
                    nbClasses = model.getNumberOfInstanceClasses();
                else
                    nbClasses = p.Results.NbClasses;
                end
                colorThreshold = this.doComputeColorThreshold( tree, nbClasses  );
                dh = dendrogram(...
                    tree, ...
                    0, ...
                    'Orientation','left', ...
                    'ColorThreshold', colorThreshold, ...
                    'Labels', instanceLabels ...
                );
                set(dh,'LineWidth',1.5);
                set(gca, 'FontSize', p.Results.FontSize)
                %title( strrep(p.Results.Title, '_', '-') );
            elseif config.isParamValueEqual('Method', 'hcca')
                cgo = model.get('Tree').getData();
                instanceNames = this.buildInstanceLabels( 'LabelFormat', p.Results.RowLabelFormat, 'MaxLabelLength', p.Results.MaxLabelLength );
                variableNames = this.buildVariableLabels( 'LabelFormat', p.Results.ColumnLabelFormat, 'MaxLabelLength', p.Results.MaxLabelLength );
                set( cgo, ...
                    'RowLabels', instanceNames, ...
                    'ColumnLabels', variableNames, ...
                    'Colormap', redbluecmap, ...
                    'ColumnLabelsRotate', p.Results.ColumnLabelsRotation ...
                    );
                %cgo.addTitle(p.Results.Title);
                cgo.view();
                h = cgo;
            end
        end
        
    end
    
    methods( Access = protected )
        
        function threshold = doComputeColorThreshold( ~, tree, iNbClasses  )
            
            % tree = N by 3 matrix, each row is a singleton cluster
            % tree(:,1:2) ontains the indices of the two component clusters
            % tree(:,3) contains linkage distances (sorted)
            
            % Each linkage results in 2 classes, so we have to walk
            % along the linkages to have correct number of classes
            N = length( tree(:,3) );
            
            if iNbClasses <= 1
                threshold = max(tree(:,3)) + 1; % maximal threshold
                return;
            end
            
            if iNbClasses > N
                threshold = 0; % minimal threhold
                return;
            end
            
            offset = N - (iNbClasses - 2);
            threshold = (tree(offset,3) + tree(offset-1,3))/2;
        end
        
    end
end
