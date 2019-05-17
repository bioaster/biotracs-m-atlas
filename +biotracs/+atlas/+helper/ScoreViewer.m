% BIOASTER
%> @file		ScoreViewer.m
%> @class		biotracs.atlas.helper.ScoreViewer
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef ScoreViewer < handle
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
 
        % -----------------------------------------------------------------
        %
        % ToDo
        % Move this part in view
        %
        % -----------------------------------------------------------------
        
        function h = view( iScores, iVarXYExplained, iNames, varargin )
            p = inputParser();
            p.addParameter('NbComponents',2,@isnumeric);
            p.addParameter('LabelFormat','none',@(x)(ischar(x) || iscell(x)));
            p.addParameter('Title','Score plot',@ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            varXExp = []; varYExp = [];
            if length(iVarXYExplained) >= 1, varXExp = iVarXYExplained{1}; end
            if length(iVarXYExplained) >= 2, varYExp = iVarXYExplained{2}; end
            
            h = figure;
            markerColor = 'blue';
            if p.Results.NbComponents == 1
                Y = ones( length(iScores(:,1)) ,1 );
                plot( iScores(:,1), Y, 'bo', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp ) );
                
                %show texts
                for i=1:length(iNames)
                    text( iScores(i,1), 1, iNames{i}, 'Rotation', 45, 'FontSize', 10 );
                end
            elseif p.Results.NbComponents == 2
                plot(iScores(:,1), iScores(:,2), 'bo', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp ) );
                
                %show texts
                for i=1:length(iNames)
                    text( iScores(i,1), iScores(i,2), iNames{i}, 'FontSize', 10 );
                end
            elseif p.Results.NbComponents == 3
                plot3(iScores(:,1), iScores(:,2), iScores(:,3), 'bo', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);  
                xlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 1, varXExp, varYExp ) );
                ylabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 2, varXExp, varYExp ) );
                zlabel( biotracs.atlas.view.BaseDecompLearnerResult.buildScorePlotAxisLabel( 3, varXExp, varYExp ) );
                
                %show texts
                for i=1:length(iNames)
                    text( iScores(i,1), iScores(i,2), iScores(i,3), iNames{i}, 'FontSize', 10 );
                end
            else
                error('Number of components must be >= 1 and <= 3');
            end
           
            title( p.Results.Title );
            grid on
        end
        
        function str = buildScorePlotAxisLabel( iComp, iVarXExp, iVarYExp )
           str = sprintf('t[%d]', iComp);  
           if length(iVarXExp) >= iComp
               str = sprintf( '%s - Var[X] = %1.1f%%', str, iVarXExp(iComp) ); 
           end
           if nargin == 3 && length(iVarYExp) >= iComp
               str = sprintf( '%s - Var[Y] = %1.1f%%', str, iVarYExp(iComp) ); 
           end
        end

    end

end
