% BIOASTER
%> @file		BaseResult.m
%> @class		biotracs.atlas.view.BaseResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseResult < biotracs.core.mvc.view.BaseObject
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- B --
        
        
        %-- G --
        
        %-- S --
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        function  doPlotEllipse2D( ~, X, varargin )
            p = inputParser;
            p.addParameter( 'Color', biotracs.core.color.Color.colormap(1), @isnumeric );
            p.KeepUnmatched = true;
            p.parse( varargin{:} );

            R = hotelling.HotellingT2(X, 'ExpectedMean', mean(X), 'Color', p.Results.Color(1,:));
            hold on
            plot(R.ellipseT2(:,1), R.ellipseT2(:,2))
        end
        
        function  doPlotEllipse3D( ~, X, varargin )
            p = inputParser;
            p.addParameter( 'FaceColor', [0, 122, 191]/255 );
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
  
            R = hotelling.HotellingT2(X, 'ExpectedMean', mean(X), 'FaceColor', p.Results.FaceColor);
            hold on
            h = surfl(R.ellipseT2{1}, R.ellipseT2{2}, R.ellipseT2{3});
            set(h, 'FaceColor', p.Results.FaceColor, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
        end
        
        function  doPlotConvexHull2D( ~, X, varargin )
            K = convhull(X);      
            hold on
            plot( X(K,1), X(K,2) );
        end
        
        function  doPlotConvexHull3D( ~, X, varargin )
            p = inputParser;
            p.addParameter( 'FaceColor', [0, 122, 191]/255, @isnumeric );
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            K = boundary(X, 0);      
            hold on
            h = trisurf(K, X(:,1), X(:,2), X(:,3));
            set(h, 'FaceColor', p.Results.FaceColor, 'EdgeColor', 'none', 'FaceAlpha', 0.1);
        end
        
    end
    
    
end
