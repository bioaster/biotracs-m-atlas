% BIOASTER
%> @file		BaseClusterer.m
%> @class		biotracs.atlas.model.BaseClusterer
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseClusterer < biotracs.atlas.model.BaseLearner
    
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
        
        % Constructor
        function this = BaseClusterer( )
            this@biotracs.atlas.model.BaseLearner();
        end
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function centroids = doComputeClassCentroids( this, classes )
            Xtr = this.getInputPortData('TrainingSet').getData();
            Xtr = biotracs.math.centerscale( ...
                Xtr, [], ...
                'Center' , this.config.getParamValue('Center'), ...
                'Scale', this.config.getParamValue('Scale'), ...
				'Direction', this.config.getParamValue('StandardizationDirection') ...
            );

            nbclust =  this.doComputedNumberOfInstanceClasses( classes );
            centroids.mu = cell( 1, nbclust );
            centroids.sigma = cell( 1, nbclust );
            for i = 1:nbclust
                c = (classes == i);
                centroids.mu{i} = mean( Xtr(c,:), 1 );
                centroids.sigma{i} = cov( Xtr(c,:) );
            end
        end
        
        function nbclust = doComputedNumberOfInstanceClasses( ~, classes )
            nbclust = 0;
            for i=1:length(classes)
                if isempty(find(classes==i, 1)), break; end
                nbclust = i;
            end
        end
        
    end

end
