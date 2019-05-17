% BIOASTER
%> @file		PoolLearnerResult.m
%> @class		biotracs.atlas.view.PoolLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolLearnerResult < biotracs.atlas.view.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolLearnerResult()
            this@biotracs.atlas.view.BaseLearnerResult()
        end

        
        function h = viewPoolingMapPlot( this )
            h = figure();
            poolingMap = this.model.get('PoolingMap');
            spy( poolingMap.data );
            hold on
            poolingVariableIdx = this.model.getPoolingVariables().getDataByColumnName('VariableIndex');
            yLim = ylim();
            for i=1:length(poolingVariableIdx)
                plot( [poolingVariableIdx(i), poolingVariableIdx(i)], yLim, '-.r' );
            end
        end
        
        function h = viewPoolingMapGraph( this )
            poolingMap = this.model.get('PoolingMap');
            rho = poolingMap.data;
            names = poolingMap.columnNames;
            
            %remove unconnected
            unconnectedIdx = sum(rho,2) == 0;   %rho is upper triangular
            rho(unconnectedIdx,:) = [];
            rho(:,unconnectedIdx) = [];
            names(unconnectedIdx) = [];
            
            G = graph(rho,names, 'upper','OmitSelfLoops');
            colormap( biotracs.core.color.Color.colormap() );
            poolingVariableIdx = this.model.getPoolingVariables().getDataByColumnName('VariableIndex');
            poolingVariableNames = poolingMap.columnNames(poolingVariableIdx);
   
            c = zeros(numnodes(G),1);
            k = findnode(G, poolingVariableNames);
            c(k) = 2;
            G.Nodes.NodeColors = c;

            h = figure();
            p = plot(G,'layout', 'force', 'NodeCData', c, 'MarkerSize', 8);
   
            %G2 = subgraph(G,poolingVariableIdx);
            %h2 = plot(G2);
            %h2.NodeColor = 'red';
        end
        
    end
end
