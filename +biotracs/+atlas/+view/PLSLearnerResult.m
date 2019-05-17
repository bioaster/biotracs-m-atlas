% BIOASTER
%> @file		PLSLearnerResult.m
%> @class		biotracs.atlas.pls.view.PLSLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PLSLearnerResult < biotracs.atlas.view.BaseDecompLearnerResult
    
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

        function h = viewVipPlot( this, varargin )
            h = this.doPrepareFigure(varargin{:});
            nCountMax = 50; %length(idx);
            
            p = inputParser();
            p.addParameter('TopNCount', nCountMax, @isnumeric);                %10 most significants
            p.parse( varargin{:} );
            
            model = this.getModel();

            varRanking = model.getCrossValidationVariableRanking();
            defaultColor = biotracs.core.color.Color.colormap(1);

            if ~varRanking.hasEmptyData()
                m = varRanking.selectByColumnName('MeanVip').data;
                lb = varRanking.selectByColumnName('MinVipLimitCI95').data;
                ub = varRanking.selectByColumnName('MaxVipLimitCI95').data;
                varNames = strrep(varRanking.getRowNames(),'_','-');
                ncount = length(m);
                % plot errorbar
                x = 1:ncount;
                errorbar( x, m, m-lb, ub-m,'xb', 'Color', defaultColor );
            else
                vip = model.getVip();
                ncount = min(getLength(vip), p.Results.TopNCount);
                plot( 1:ncount, vip.data(1:ncount), 'o-', 'Color', defaultColor );
                varNames = strrep(vip.getRowNames(),'_','-');
            end
            
            hold on
            
            ax = gca();
            set(ax, 'XTickLabel', varNames, 'XTickLabelRotation', 90, 'TickDir', 'out', 'FontSize', 10);
            ax.XTick = 1:ncount;
            title( ['VIP (', num2str(ncount), ' var.)' ]);
            grid on;
        end

    end
    
end
