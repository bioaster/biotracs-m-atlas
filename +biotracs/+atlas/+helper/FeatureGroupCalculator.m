% BIOASTER
%> @file 		FeatureGroupCalculator.m
%> @class 		biotracs.metprofiler.helper.FeatureGroupCalculator
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef FeatureGroupCalculator < handle
    
    properties(Constant)
        REDUNDANCY_FLAG_VALUE = biotracs.atlas.model.FeatureGrouperConfig.REDUNDANCY_FLAG_VALUE;
        ISOFEATURE_FLAG_VALUE = biotracs.atlas.model.FeatureGrouperConfig.ISOFEATURE_FLAG_VALUE;
        BLOCK_SIZE = 10000;
    end
    
    properties(SetAccess = protected, Transient = true)
        dataSet;
        redundancyMatrix;
    end
    
    properties(SetAccess = protected)
        maxIsofeatureShift         = 1; 
        redundancyCorrelation      = 0.85;
        redundancyPValue           = 0.05;
        minNbOfAdjacentFeatures    = 0;
        linkingOrders              = 0;
        minNbOfFeaturesPerGroup           = 0;
        maxNbOfFeaturesToUseForConsensus  = Inf;
        isofeatureMap;
        consensusFunction = 'mean';
    end
    
    methods(Access = public)
        
        function this = FeatureGroupCalculator( iDataSet, varargin )
            p = inputParser();
            p.addParameter('MaxIsofeatureShift', 10, @(x)(isnumeric(x) && x >= 0));
            p.addParameter('RedundancyCorrelation', 0.85, @(x)(isnumeric(x) && x >= 0 && x <= 1));
            p.addParameter('RedundancyPValue', 0.05, @(x)(isnumeric(x) && x >= 0 && x <= 1));
            p.addParameter('MinNbOfAdjacentFeatures', 0, @(x)(isnumeric(x) && x >= 0));
            p.addParameter('LinkingOrders', 0, @isnumeric);
            p.addParameter('MinNbOfFeaturesPerGroup', 0, @isnumeric);
            p.addParameter('MaxNbOfFeaturesToUseForConsensus', Inf, @isnumeric);
            p.addParameter('ConsensusFunction', 'mean', @(x)(any(strcmp(x,{'mean','max'}))));
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            this.maxIsofeatureShift = p.Results.MaxIsofeatureShift;
            this.redundancyCorrelation = p.Results.RedundancyCorrelation;
            this.redundancyPValue = p.Results.RedundancyPValue;
            this.minNbOfAdjacentFeatures = p.Results.MinNbOfAdjacentFeatures;
            this.linkingOrders = p.Results.LinkingOrders;
            this.minNbOfFeaturesPerGroup = p.Results.MinNbOfFeaturesPerGroup;
            this.maxNbOfFeaturesToUseForConsensus = p.Results.MaxNbOfFeaturesToUseForConsensus;
            this.consensusFunction = p.Results.ConsensusFunction;
            
            this.dataSet = iDataSet;
            
            if ~hasEmptyData(this.dataSet)
                this.calculateRedundancyMatrix( varargin{:} );
                this.createIsofeatureMap();
            end
        end
        
        %-- C --
        
        %> @brief Compute the redundancy matrix R, i.e. the covariance matrix of
        %> the @a iTrainingSet. The redundancy flag is given by attribute
        %> @a REDUNDANCY_FLAG_VALUE, i.e. when features i and j are redundant
        %> then R(i,j) = @a REDUNDANCY_FLAG_VALUE
        %> @param[in, optional] varargin
        %> @return biotracs.data.model.DataMatrix the redundancy matrix
        function calculateRedundancyMatrix( this, varargin )
            biotracs.core.env.Env.writeLog('%s', 'Calculate redundancy matrix');
            nbFeatures = getSize(this.dataSet,2);
            if nbFeatures > this.BLOCK_SIZE
                biotracs.core.env.Env.writeLog('Use blocked sparse matrices for memory optimization (block sizes %d-by-%d)', this.BLOCK_SIZE, this.BLOCK_SIZE);
                nbBlocks = fix(nbFeatures/this.BLOCK_SIZE) + 1;
                startIndex = 1; endIndex = min(startIndex+this.BLOCK_SIZE, nbFeatures);
                redundancyData = cell(1,nbBlocks);
                i = 1;
				w = biotracs.core.waitbar.Waitbar('Name', sprintf('Process %d blocks', nbBlocks));
				w.show();
                while true
					w.show(i/nbBlocks);
                    %fprintf('\t Process block %d/%d...\n', i, nbBlocks);
                    X = this.dataSet.data(:,startIndex : endIndex);
                    [rho, pval] = corr(X, X);
                    rho = double(rho >= this.redundancyCorrelation & pval <= this.redundancyPValue );
                    redundancyData{i} = sparse(triu(rho));
                    i = i+1;
                    startIndex = endIndex+1;
                    endIndex = startIndex+this.BLOCK_SIZE;
                    if endIndex > nbFeatures-(this.BLOCK_SIZE/10)
                        endIndex = nbFeatures;
                    end
                    if startIndex >= nbFeatures
						w.show(1);
                        break;
                    end
                end
                biotracs.core.env.Env.writeLog('%s', 'Merge blocks');
                redundancyData = blkdiag(redundancyData{:});
            else
                [rho, pval] = corr(this.dataSet.data, this.dataSet.data);
                rho = triu(rho);
                redundancyData = double(rho >= this.redundancyCorrelation & pval <= this.redundancyPValue ); 
            end

            this.redundancyMatrix = biotracs.data.model.DataMatrix(...
                redundancyData, ...
                this.dataSet.getColumnNames(), ...
                this.dataSet.getColumnNames()...
                );
            this.doCalculateIsofeatures( varargin{:} );
        end
        
        function [ count ] = countUnique( ~, corrMatrix )
            count = sum( sum(corrMatrix.data) >= 1 );
        end

        function createIsofeatureMap( this  )
            w = biotracs.core.waitbar.Waitbar('Name', 'Calculate the isofeature map');
			w.show();
            n = getSize(this.redundancyMatrix,1);
            isofeatureMapData = cell(n,1);                 %to ensure data shape is preseved with json encode <-> decode
            X = this.redundancyMatrix.data >= this.ISOFEATURE_FLAG_VALUE;
            for i=1:n
				w.show(i/n);
                idx = find( X(i,:) );
                isofeatureMapData{i} = idx;
            end
            this.isofeatureMap = biotracs.spectra.data.model.IsoFeatureMap( isofeatureMapData, this.dataSet.columnNames );
        end
        
         
        function exportIsofeaturePairsInfo( this, iFilePath, writeNone )
            fid = fopen(iFilePath, 'w+');
            n = getSize(this.dataSet,2);
            if nargin < 7
                writeNone = true;
            end
            for featureIndex=1:n
                isofeatureIndexes = this.isofeatureMap{featureIndex};
                isofeatureNames = this.dataSet.getColumnNames( isofeatureIndexes );
                
                isNotIsofeature = isempty(isofeatureIndexes);
                if isNotIsofeature
                    if writeNone
                        fprintf(fid, '%s \t None\n', this.dataSet.getColumnName(featureIndex) );
                    end
                else
                    for i=1:length(isofeatureNames)
                        fprintf(fid, ...
                            '%s, X \t %s, X\n', ...
                            this.dataSet.getColumnName(featureIndex), isofeatureNames{i} );
                    end
                    fprintf(fid, ' \t \n');
                end
            end
            fclose(fid);
        end
        
        %-- G --
            
        function nb = getNbRedundants( this )
            nb = sum(sum(this.redundancyMatrix.data >= this.REDUNDANCY_FLAG_VALUE) >= 1);
        end
        
        function nb = getNbIsofeatures( this )
            nb = sum(sum(this.redundancyMatrix.data >= this.ISOFEATURE_FLAG_VALUE) >= 1);
        end
        
        function m = getIsoFeatureMap( this )
            m = this.isofeatureMap;
        end
        
        %-- D --

        %-- R --

        function [ reducedDataSet, selectedFeatureIdx ] = reduceDataSet( this )
            [ reducedDataSet, selectedFeatureIdx ] = this.reduceDataSetUsingIsofeatureMap( ...
                this.dataSet, this.isofeatureMap, ...
                'MaxNbOfFeaturesToUseForConsensus', this.maxNbOfFeaturesToUseForConsensus, ...
                'ConsensusFunction', this.consensusFunction ...
                );
        end

        %-- S --
    end
    
    methods(Static)
        
        function [ reducedDataSet, selectedFeatureIdx ] = reduceDataSetUsingIsofeatureMap( iDataSet, iIsoFeatureMap, varargin )
            p = inputParser();
            p.addParameter('MaxNbOfFeaturesToUseForConsensus', Inf, @isnumeric);
            p.addParameter('ConsensusFunction', 'mean', @(x)(any(strcmp(x,{'mean','max'}))));
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            [m,n] = getSize( iDataSet );
            selectedFeatureIdx = true(1,n);
            reducedDataSet =  iDataSet.copy();
            
            if hasEmptyData(iDataSet)
                return;
            end

			w = biotracs.core.waitbar.Waitbar('Name', 'Reduce the data using the issofeature map');
			w.show();
            nbIsofeatureGroups = 0;
            for i=1:n
				w.show(i/n);
                isofeatureIndexes = iIsoFeatureMap.data{i};
                isFeatureAlreadyDiscarded = ~selectedFeatureIdx(i);
                isNotIsofeature = isempty(isofeatureIndexes);
                if isNotIsofeature
                    % Do not discard this feature
                    selectedFeatureIdx(i) = false;
                elseif ~isFeatureAlreadyDiscarded
                    % Discard all the features excepted this feature
                    selectedFeatureIdx( isofeatureIndexes ) = false;
                    selectedFeatureIdx(i) = true;
                    isofeatureNames = iDataSet.getColumnNames( isofeatureIndexes );
                    reducedDataSet.setColumnTag( i, 'IsofeatureIndexes', isofeatureIndexes(:) );    %to ensure data shape is preseved with json encode <-> decode
                    reducedDataSet.setColumnTag( i, 'IsofeatureNames', isofeatureNames(:) );        %to ensure data shape is preseved with json encode <-> decode

                    [intensities, idx] = sort( iDataSet.getDataAt(1:m,isofeatureIndexes), 2, 'descend' );
                    N = min( p.Results.MaxNbOfFeaturesToUseForConsensus, size(intensities,2) );
                    
                    if strcmp(p.Results.ConsensusFunction,'mean')
                        consensusIntensity = mean( intensities(1:m,1:N), 2 );
                    elseif strcmp(p.Results.ConsensusFunction,'max')
                        consensusIntensity = max( intensities(1:m,1:N), [], 2 );
                    else
                        error('SPECTRA:FeatureGroupCalculator:InvalidConsensusFunctions', 'The consensus function is not valid');
                    end
                    reducedDataSet.setDataAt( 1:m, i, consensusIntensity );
                    nbIsofeatureGroups = nbIsofeatureGroups + 1;
                    reducedDataSet.setColumnTag( i, 'IsofeatureGroupIndex', nbIsofeatureGroups );
                    
                    meanTopIdx = fix(mean(idx(:,1)));
                    reducedDataSet.setColumnName( i, isofeatureNames{meanTopIdx} );
                    %reducedDataSet.setColumnName( i, strjoin(isofeatureNames,'|') );
                end
            end
            [reducedDataSet] = reducedDataSet.selectByColumnIndexes(selectedFeatureIdx);
            
            nbIsofeatures = getSize(reducedDataSet,2);
            biotracs.core.env.Env.writeLog('\t > the initial number of features = %d', n);
            biotracs.core.env.Env.writeLog('\t > the final number of features = %d', nbIsofeatures);
            biotracs.core.env.Env.writeLog('\t > the initial dataset is reduced by %1.0f%%', 100*(n-nbIsofeatures)/n);
        end
    end
    
    methods(Access = protected)
        %> @brief Compute the isofeature matrix I. Features i and j are
        %> isofeature if they are redundant and the difference between
        %> their retention times is smaller than @a maxRetentionTimeShift.
        %> In this case I(i,j) = @a ISOFEATURE_FLAG_VALUE
        %> @param[in, optional] varargin
        %> @return the isofeature matrix (biotracs.data.model.DataMatrix)
        function doCalculateIsofeatures( this, varargin )
			w = biotracs.core.waitbar.Waitbar('Name', 'Calculate isofeature matrix');
			w.show();
			
            [ shifts ] = this.dataSet.getVariablePositions( );
            if any(isnan(shifts))
                error('FeatureGroupCalculator:InvalidVariablePositions', 'Some variable positions are not defined the DataSet');
            end
            
            [ ~, sortedIndex ] = sort(shifts);
            n = size( this.redundancyMatrix.data,1 );
            isofeatureData = this.redundancyMatrix.data;
            isofeatureData( isofeatureData > 0 ) = 0;

            for i = sortedIndex(1:n)
				w.show(i/n);
                nbAdjacentPoints = 0;
                isAdjacentIsofeature = true;
                idx = [];
                for j = sortedIndex(i:n)
                    isCloseToTheCurrentFeature = abs(shifts(i)-shifts(j)) <= this.maxIsofeatureShift;
                    if isCloseToTheCurrentFeature
                        if this.redundancyMatrix.data(i,j)
                            idx = [idx, j]; %#ok<AGROW>
                            nbAdjacentPoints = nbAdjacentPoints + 1;
                        else
                            isAdjacentIsofeature = false;
                        end
                    else
                        isAdjacentIsofeature = false;
                    end
                    
                    if ~isAdjacentIsofeature
                        if nbAdjacentPoints-1 >= this.minNbOfAdjacentFeatures
                            isofeatureData(i,idx) = this.ISOFEATURE_FLAG_VALUE;
                        end
                        break;
                    end
                end

            end 

			biotracs.core.env.Env.writeLog('%s', 'Linking isofeatures');
			
            if max(this.linkingOrders) > 0
                % Compact isofeature matrix based on the tansitivity property
                % i.e. if A1 & A2 have coeluted and A2 & A3 have coeluted then
                % A1 & A2 & A3 have coeluted
                % Denote by A, the adjacency matrix A(i,j) = 3 if Ai and Aj are
                % isofeatures
                % Denote by x = diag(n) = I the matrix representing the set of
                % all initial node positions
                % Then F = x + A*x + ... A^(n-1)*x = I + A + A^2 + ... + A^n-1 the is
                % walking function, say the linking function, from any nodes to
                % all the other nodes of the graph in n-1 steps
                % According to the transitivity property, F will link all the
                % node (isofeatures linked between them)
                % trick : After scaling each walking step by 1/n!, we have
                % F = I + A + A^2/2 + ... + A^n-1/(n-1)! = expm(A)
                
                %if issparse(isofeatureData)
                %    I = speye(n);
                %else
                %    I = eye(n);
                %end
                if isinf( max(this.linkingOrders) )
                    isofeatureData  = expm(isofeatureData);
                else
                    ulo = unique(this.linkingOrders);
                    ulo( ulo == 0 | ulo == 1 ) = [];  %order 0 and 1 are useless
                    for i = ulo
                        isofeatureData  = isofeatureData + isofeatureData^i;
                    end
                end
            end
            
            isofeatureData = isofeatureData + this.redundancyMatrix.data;    
            isofeatureData( isofeatureData > this.REDUNDANCY_FLAG_VALUE ) = this.ISOFEATURE_FLAG_VALUE;
            
            if this.minNbOfFeaturesPerGroup > 0
                nbLinked = sum( isofeatureData >= this.ISOFEATURE_FLAG_VALUE, 2 );
                rowIdx = nbLinked > 0 & nbLinked < this.minNbOfFeaturesPerGroup;
                isofeatureData( rowIdx, : ) = 0;
            end
            
            this.redundancyMatrix = biotracs.data.model.DataMatrix(...
                isofeatureData, ...
                this.dataSet.getColumnNames(), ...
                this.dataSet.getColumnNames()...
                );
        end

    end
    
end

