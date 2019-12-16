% BIOASTER
%> @file		KmeansLearner.m
%> @class		biotracs.atlas.model.KmeansLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef KmeansLearner < biotracs.atlas.model.BaseClusterer
    
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
        function this = KmeansLearner()
            %#function biotracs.atlas.model.KmeansLearnerConfig biotracs.atlas.model.KmeansLearnerResult
            
            this@biotracs.atlas.model.BaseClusterer();
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.KmeansLearnerResult' ...
                )...
                });
        end
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function [classes, classesList] = doLearn(this, Xtr, varargin)
            d = size(Xtr);
            ncols = d(1);
            maxNbClust = min( ncols, this.config.getParamValue('MaxNbClusters') );
            opts = statset('Display','off');
            
            %Compute the optimal number of clusters
            meanSilh = zeros(maxNbClust, 1);
            classesList = cell(1, maxNbClust);
            for k = 1:maxNbClust
                [classes, ~] = kmeans(Xtr, k, 'Replicates',10,'Options',opts);
                s = silhouette(Xtr,classes);
                meanSilh(k) = mean(s);
                classesList{k} = classes;
            end
            
            optimalNbClust = find( meanSilh == max(meanSilh), 1 );
            [classes, ~] = kmeans(Xtr, optimalNbClust, 'Replicates',10,'Options',opts);
            centroids = this.doComputeClassCentroids( classes );

            result = this.getOutputPortData('Result');
            result.setInstanceClassData( classes, this.getTrainingInstanceNames() );
            result.setInstanceClassCentroidData( centroids );
            result.setInstanceClassListData( classesList );
        end
        
        function doLearnCv( varargin )
            %error('The cross-validation algorithm is not yet implemented for kmeans')
        end
        
        function doLearnPerm( varargin )
            %error('The cross-validation algorithm is not yet implemented for kmeans')
        end
        
    end
    
    
end
