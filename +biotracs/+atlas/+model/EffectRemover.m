% BIOASTER
%> @file		EffectRemover.m
%> @class		biotracs.atlas.model.EffectRemover
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef EffectRemover < biotracs.core.mvc.model.Process
    
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
        
        % Constructor
        function this = EffectRemover()
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'DataSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                });
            
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'DataSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                struct(...
                'name', 'Statistics',...
                'class', 'biotracs.data.model.DataMatrix' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            
            effectsToRemove = this.config.getParamValue('EffectsToRemove');
            if ~isempty(effectsToRemove) 
                [filteredDataSet, stats] = this.doRemoveBooleanEffects();
            else
                error('No effect to remove');
            end
 
            this.setOutputPortData('DataSet', filteredDataSet);
            this.setOutputPortData('Statistics', stats);
        end
        
        function [residualDataSet, stats] = doRemoveBooleanEffects(this)
            dataSet = this.getInputPortData('DataSet');
            
            effectsToRemove = this.config.getParamValue('EffectsToRemove');
            refecenceGroups = this.config.getParamValue('ReferenceGroups');
            
            %initialize residual dataset
            if dataSet.hasResponses()
                residualDataSet = dataSet.selectXSet();
            else
                residualDataSet = dataSet.copy();
            end
           
           
            residualDataSet.setRowNamePatterns(effectsToRemove);
            
            nbEffects = length(effectsToRemove);
            resX = residualDataSet.data;
            resVar = zeros(1,nbEffects);
            totVar = sum(var(resX));
            
            %extract refecence dataset
            if isempty(refecenceGroups)
                refDataSet = residualDataSet.copy();
            else
                grp = strcat('(',refecenceGroups,')');
                grp = strjoin(grp,'|');
                refDataSetIndexes = residualDataSet.getRowIndexesByName( grp );
                refDataSet = residualDataSet.selectByRowName( grp );
            end

            
            %partial iterative correction
            for i = 1:nbEffects
                gs = biotracs.data.helper.GroupStrategy( refDataSet.rowNames(), effectsToRemove(i) );
                refSliceIdx = gs.getSlicesIndexesOfGroup( effectsToRemove{i} );
                nbSlices = size(refSliceIdx,2);
                gs = biotracs.data.helper.GroupStrategy( residualDataSet.rowNames(), effectsToRemove(i) );
                sliceIdx = gs.getSlicesIndexesOfGroup( effectsToRemove{i} );

                % remove multiplicative components
                if isempty(refecenceGroups)
                    refRes = resX;
                else
                    refRes = resX(refDataSetIndexes,:);
                end
                
                for j = 1:nbSlices
                    refIdx = refSliceIdx(:,j);
                    refStdData = std(refRes(refIdx,:));
                    
                    %refMeanData = mean(refRes(refIdx,:));
                    idxOfZeros = (refStdData == 0);
                    if any(idxOfZeros)
                        delta = min( refStdData(~idxOfZeros) ) * 1e-3;
                        refStdData = refStdData + delta;
                    end
                    idx = sliceIdx(:,j);
                    resX(idx,:) = biotracs.math.centerscale( resX(idx,:), {[], refStdData}, 'Center' , false, 'Scale', 'uv' );
                end
                
                if isempty(refecenceGroups)
                    %refRes = resX;
                    refDataSet.setData(resX, false);
                else
                    %refRes = resX(refDataSetIndexes,:);
                    refDataSet.setData(resX(refDataSetIndexes,:), false);
                end
                

                % remove additive components
                refStdData = std(refDataSet);
                idxOfZeros = (refStdData == 0);
                if any(idxOfZeros)
                    error('SPECTRA:EffectRemover:FeaturesWithZeroVariance', ...
                        'Some features in the reference data have zero variance after removal of multiplicative effets\n\tFeatures: %s', ...
                        join(refDataSet.getColumnNames(idxOfZeros)) ...
                        );
                end
                
                
                ncomps = this.config.getParamValue('NbComponentsPerEffect');
                learner = biotracs.atlas.model.PLSLearner();
                c = learner.getConfig();
                c.updateParamValue('NbComponents',ncomps);
                c.updateParamValue('Center',true);
                c.updateParamValue('Scale','none');
                learner.setInputPortData('TrainingSet',refDataSet.createXYDataSet());
                learner.run();
                learnerResult = learner.getOutputPortData('Result');
                XL = learnerResult.get('XLoadings').data;
                YL = learnerResult.get('YLoadings').data;
                B = learnerResult.get('RegCoef').data;
                standardizedX = biotracs.math.centerscale( resX, refDataSet.data, 'Center' , true, 'Scale', 'none' );
                predY =  standardizedX * B;
                predX = predY * YL * (YL' * YL)^-1 * XL';
                predX = biotracs.math.reversecenterscale( predX, refDataSet.data, 'Center' , true, 'Scale', 'none' );
                resX = resX - predX;
                residualDataSet.setData(resX,false);
                
                %residual variance
                resVar(i) = sum(var(resX));
            end
            
            stats = biotracs.data.model.DataMatrix( [totVar, resVar]./totVar, ['X', effectsToRemove], {'Var'} );
        end
        
    end
end