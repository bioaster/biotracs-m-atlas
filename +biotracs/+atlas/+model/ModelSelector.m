% BIOASTER
%> @file		ModelSelector.m
%> @class		biotracs.atlas.model.ModelSelector
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef ModelSelector < biotracs.atlas.model.BaseLearner
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ModelSelector()
            this@biotracs.atlas.model.BaseLearner();
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.ModelSelectorResult' ...
                )...
                });
            this.bindEngine( biotracs.atlas.model.PLSLearner(), 'ModelLearningEngine' );
            this.bindEngine( biotracs.atlas.model.LarsenLearner(), 'VariableSelectionEngine' );
        end
        
    end
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            e = this.getEngine('VariableSelectionEngine');
            if strcmp(class(e), 'biotracs.atlas.model.VariableSelector') %#ok<STISA>
                error('SPECTRA:ModelSelector:InvalidEngine', 'The VariableSelectionEngine engine is not defined');
            end            
            this.doBeforeRun@biotracs.atlas.model.BaseLearner();
        end	
        
        
        function doLearnPerm( varargin )
            % do nothing
        end	
        
        function doLearnCv( varargin )
            % do nothing
        end  	
        
        function doLearn( this, ~, ~ )
            verbose = this.config.getParamValue('Verbose');
            trSet = this.getInputPortData('TrainingSet');
            [m,n] = getSize(trSet.selectXSet());
            [~,q] = getSize(trSet.selectYSet());
            minNbVars = this.config.getParamValue('MinNbVariablesToSelect');
            maxNbVars = min( [3*m, ceil(n/2), this.config.getParamValue('MaxNbVariablesToSelect')] );
            pValue = this.config.getParamValue('PValue');

            %variable selection & ranking
            if verbose
                this.logger.writeLog('%s','Model regularization and variable ranking');
            end
            engine = this.getEngine('VariableSelectionEngine');
            engine.setInputPortData('TrainingSet',trSet);
            engine.config.updateParamValue('NbVariablesToSelect', maxNbVars)...
                        .updateParamValue('Verbose', true);
            engine.run();
            varSelectionResult = engine.getOutputPortData('Result');

            if verbose
                this.logger.writeLog('%s', 'Model selection using permutation tests');
            end
            
            %model learning
            perfData = nan(maxNbVars,6);   %set all default p-values to 1
            isInValidityDomain = false;
            %isValidityDomainLost = false;
            %nbIterationsAfterValidityDomainLoss = 0;
            nbIterationsOutOfValidityDomain = 0;
            
            %Starts with at leat n = 5 variables to prevent singularities
            for nbVars = minNbVars:maxNbVars
                if verbose && mod(nbVars-1, fix(maxNbVars/5)) == 0
                    this.logger.writeLog('%d variables tested (%1.0f%%)', nbVars, 100*nbVars/maxNbVars);
                end
                varTable = varSelectionResult.getSelectedVariables( nbVars );
                varIdx = varTable.getDataByColumnName('VariableIndex');
                [ perfData(nbVars,:) ] = this.doComputeModelPerf( varIdx );
                
                currentPValue = perfData(nbVars,end);
                if ~isInValidityDomain && currentPValue <= pValue
					if verbose
						this.logger.writeLog('Validity domain found (model p-value = %0.3g)',currentPValue);
					end
                    isInValidityDomain = true;
                    %isValidityDomainLost = false;
                end
                
                if isInValidityDomain && currentPValue > pValue
					if verbose
						this.logger.writeLog('Validity domain lost (model p-value = %0.3g)', currentPValue);
					end
                    isInValidityDomain = false;
                    %isValidityDomainLost = true;
                end
                
                if ~isInValidityDomain
                    nbIterationsOutOfValidityDomain = nbIterationsOutOfValidityDomain + 1;
                else
                    nbIterationsOutOfValidityDomain = 0;
                end
                
                %if isValidityDomainLost
                %    nbIterationsAfterValidityDomainLoss = nbIterationsAfterValidityDomainLoss + 1;
                %end
                
                if nbIterationsOutOfValidityDomain >= max(10,3*q)
                    if verbose
                        this.logger.writeLog('%s', 'stop search.');
                    end
                    break;
                end
            end
            
            if verbose && mod(nbVars-1, fix(nbVars/5)) ~= 0
                this.logger.writeLog('%d variables tested (%0.3g%%)', nbVars, 100*nbVars/maxNbVars);
            end
            
            %set stats
            if nbVars < maxNbVars
                perfData(nbVars+1:end,:) = [];
            end
            
            result = this.getOutputPortData('Result');
            perfMatrix = biotracs.data.model.DataMatrix( [(1:nbVars)', perfData], {'NbVariables', 'R2Y','Q2Y','E2','CV_E2','TStatistics','PValue'} );
            perfMatrix.setLabel( trSet.getLabel() );
            stats = biotracs.atlas.model.BaseLearnerStats();
            stats.set('ModelSelectPerf', perfMatrix);
            result.set('Stats', stats);
            
            %select optimal datasets
            this.doComputeSelectedDataSetAndSetResults( trSet, varSelectionResult );

            this.setOutputPortData('Result', result);
        end

        function doComputeSelectedDataSetAndSetResults( this, trSet, varSelectionResult )
            result = this.getOutputPortData('Result');
            [ stats ] = result.computeOptimalModelStatistics( 'PValue', this.config.getParamValue('PValue') );
            
            if stats.H  %if Null Hypthesis is rejected 
                minNbVars = stats.NbVariables(1);
                maxNbVars = stats.NbVariables(2);
                optimalNbVariables = fix(stats.NbVariables(1) + stats.NbVariables(2))/2;
                
                varTable = varSelectionResult.getSelectedVariables( minNbVars );
                varIdx = varTable.getDataByColumnName('VariableIndex');
                smallDataSet = horzmerge( trSet.selectXSet().selectByColumnIndexes(varIdx), trSet.selectYSet() );
                smallDataSet.setLabel( trSet.getLabel() );

                if minNbVars == maxNbVars
                    optimalDataSet = smallDataSet;    %shallow copy
                    optimalVarTable = varTable;
                    largeDataSet = trSet.selectByColumnIndexes([]);
                    largeDataSet.setLabel( trSet.getLabel() );
                else
                    optimalVarTable = varSelectionResult.getSelectedVariables( optimalNbVariables );
                    varIdx = optimalVarTable.getDataByColumnName('VariableIndex');
                    optimalDataSet = horzmerge( trSet.selectXSet().selectByColumnIndexes(varIdx), trSet.selectYSet() );
                    optimalDataSet.setLabel( trSet.getLabel() );
                    
                    varTable = varSelectionResult.getSelectedVariables( maxNbVars );
                    varIdx = varTable.getDataByColumnName('VariableIndex');
                    largeDataSet = horzmerge( trSet.selectXSet().selectByColumnIndexes(varIdx), trSet.selectYSet() );
                    largeDataSet.setLabel( trSet.getLabel() );
                end
                
                nbModels = maxNbVars-minNbVars+1;
                selectedModelMap = biotracs.atlas.model.SelectedModelMap(nbModels);
                for i=1:nbModels
                    nbVar = minNbVars + (i-1);
                    selecteVarDataMatrix = varSelectionResult.getSelectedVariables(nbVar);
                    selectedModelMap.setAt(i, selecteVarDataMatrix);
                end
            else
                smallDataSet = trSet.selectByColumnIndexes([]);
                smallDataSet.setLabel( trSet.getLabel() );
                largeDataSet = trSet.selectByColumnIndexes([]);
                largeDataSet.setLabel( trSet.getLabel() );
                optimalDataSet = trSet.selectByColumnIndexes([]);
                optimalDataSet.setLabel( trSet.getLabel() );
                optimalVarTable = biotracs.atlas.model.SelectedVariableDataMatrix();
                optimalVarTable.setLabel( trSet.getLabel() );
                selectedModelMap = biotracs.atlas.model.SelectedModelMap();
            end
            
            %optimalDataSet.getRowNamePatterns()
            
            result.set('SmallestSelectedDataSet', smallDataSet);
            result.set('LargestSelectedDataSet', largeDataSet);
            result.set('SelectedModelMap',selectedModelMap );
            result.set('OptimalSelectedVariableDataMatrix', optimalVarTable);
            result.set('OptimalSelectedDataSet', optimalDataSet);
        end
        
        function [ perfData ] = doComputeModelPerf( this, iVariableIndices )
            trSet = this.getInputPortData('TrainingSet');
            selectedTrSet = horzmerge( trSet.selectByColumnIndexes(iVariableIndices), trSet.selectYSet() );

            %selectedTrSet.summary()
            %pause
            learner = this.getEngine('ModelLearningEngine').copy();
            learner.setInputPortData('TrainingSet',selectedTrSet);
            learner.run();
            result = learner.getOutputPortData('Result');
            learningStats = result.getStats();
            perfData = zeros(1,6);
            if isa(learner, 'biotracs.atlas.model.PLSLearner')
                ncomp = result.getOptimalNbComponents();
                perfData(1) = learningStats.get('R2Y').data(ncomp);
                perfData(2) = learningStats.get('Q2Y').data(ncomp);
                perfData(3) = learningStats.get('E2').data(ncomp);
                perfData(4) = learningStats.get('CV_E2').data(ncomp);
            else
                perfData(1) = learningStats.get('R2Y').data();
                perfData(2) = learningStats.get('Q2Y').data();
                perfData(3) = learningStats.get('E2').data();
                perfData(4) = learningStats.get('CV_E2').data();
            end
            
            [ pValueMatrix ] = result.getPermutationTestSignificance();
            if this.isDiscriminantAnalysis()
                pValueData = pValueMatrix.getDataFor( 'CV_E2',{'TStatistic','PValue'} );
            else
                pValueData = pValueMatrix.getDataFor( 'Q2Y',{'TStatistic','PValue'} );
            end
            perfData(5:end) = pValueData';
        end
        
    end
    
end
