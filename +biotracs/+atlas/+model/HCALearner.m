% BIOASTER
%> @file		HCALearner.m
%> @class		biotracs.atlas.model.HCALearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef HCALearner < biotracs.atlas.model.BaseClusterer
    
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
        function this = HCALearner( )
            %#function biotracs.atlas.model.HCALearnerConfig biotracs.atlas.model.HCALearnerResult
            
            this@biotracs.atlas.model.BaseClusterer();
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.HCALearnerResult' ...
                )...
            });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function [classes, tree] = doLearn(this, Xtr, varargin)
            if this.config.isParamValueEqual('Method', 'hca')
                [classes, tree, ~, classesList] = this.doComputeClusters( Xtr );
                centroids = this.doComputeClassCentroids( classes );
                
                result = this.getOutputPortData('Result');
                result.setTreeData( tree, this.getVariableNames(), this.getTrainingInstanceNames() );
                result.setInstanceClassData( classes, this.getTrainingInstanceNames() );
                result.setInstanceClassCentroidData( centroids );
                result.setInstanceClassListData( classesList );
            elseif this.config.isParamValueEqual('Method', 'hcca')
%                 majorDir = this.config.getParamValue('MajorDirection');
%                 if strcmp(majorDir, 'column')
%                     Xtr = Xtr';
%                 end
%                 
%                 %clustering along rows (instances)
%                 [instanceClasses, tree, optimalNbClust, classesList] = this.doComputeClusters( Xtr );
%                 instanceClassCentroids = this.doComputeClassCentroids( instanceClasses );
% 
%                 %clustering along columns (variables)
%                 rowPerm = this.doComputePermutations( tree, optimalNbClust );
%                 if ~issymmetric( Xtr )
%                     tXtr = Xtr(rowPerm,:)';
%                     [variableClasses, ~] = this.doComputeClusters( tXtr );
%                 else
%                     variableClasses = instanceClasses;
%                 end

                %compute co-clustering
                cgo = clustergram(Xtr, ...
                    'OptimalLeafOrder', true, ...
                    'Colormap',redbluecmap ...
                );

                %tree = cgo;
                %trSet = this.getInputPortData('TrainingSet');
                result = this.getOutputPortData('Result');
                result.setTreeData( cgo, this.getVariableNames(), this.getTrainingInstanceNames() );
                
%                 result.setInstanceClassData( instanceClasses, this.getTrainingInstanceNames() );
%                 result.setInstanceClassListData( classesList );
%                 result.setInstanceClassCentroidData( instanceClassCentroids );   
%                 result.setVariableClassData( variableClasses, this.getVariableNames() );
            else
                error('Wrong method; ''hca'' or ''hcca'' expected')
            end
        end
        
        function doLearnCv( varargin)
            %error('The cross-validation algorithm is not yet implemented for hca')
        end
        
        function doLearnPerm( varargin)
            %error('The cross-validation algorithm is not yet implemented for hca')
        end
        
        function [classes, tree, optimalNbClust, clusterAssignment] = doComputeClusters( this, Xtr, varargin )
            d = size(Xtr);
            ncols = d(1);
            maxNbClust = min( ncols, this.config.getParamValue('MaxNbClusters') );
            tree = linkage(Xtr, 'ward'); %'ward'
            clusterAssignment = cluster(tree,'maxclust', 1:maxNbClust);

            if isempty(clusterAssignment)
                %no cluster found => return one cluster for all the data
                optimalNbClust = 1;
                clusterAssignment = ones(size(Xtr,1),1);
                classes = ones(size(Xtr,1),1);
                return;
            end
            
            %Compute the optimal number of clusters
            meanSilh = zeros(maxNbClust, 1);
            for i=1:maxNbClust
                s = silhouette( Xtr,clusterAssignment(:,i) );
                meanSilh(i) = mean(s);
            end
            
            optimalNbClust = find(meanSilh == max(meanSilh), 1);
            if isempty(optimalNbClust), optimalNbClust = 1; end
            classes = clusterAssignment(:,optimalNbClust);
        end
        
%         function [ perm ] = doComputePermutations( ~, tree, optimalNbClust )
%             try
%                 cfig = figure('Visible','off', 'Name', 'DendrogramFigure');
%                 [~, ~, perm] = dendrogram( tree, 0, 'ColorThreshold', optimalNbClust );
%             catch err
%                 error('%s\n%s','Cannot compute dendrogram and get permutations', err.message);
%             end
%             delete(cfig);
%         end
        
    end
    
    
end
