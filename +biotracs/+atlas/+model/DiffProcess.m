% BIOASTER
%> @file		DiffProcess.m
%> @class		biotracs.atlas.model.DiffProcess
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef DiffProcess < biotracs.core.mvc.model.Process
    
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
        function this = DiffProcess()
            %#function biotracs.atlas.model.DiffProcessConfig
            
            this@biotracs.core.mvc.model.Process();
            this.setDescription('Differential analysis intrument');
            
            % enhance outputs specs
            this.addInputSpecs({...
                struct(...
                'name', 'DataSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.DiffProcessResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            dataSet = this.getInputPortData('DataSet');
            dataSet = dataSet.selectXSet();
            
            result = this.getOutputPortData('Result');
            LoQ = min(dataSet.data(dataSet.data(:) > 0)) ./ 10;
            
            patterns = this.config.getParamValue('GroupPatterns');
            rowGrpStrategy = dataSet.createRowGroupStrategy(patterns);
            grpLabels = rowGrpStrategy.getGroupLabels();
            nbGroups = length(grpLabels);
            
            statTable = biotracs.core.mvc.model.ResourceSet();
            diffTable = biotracs.core.mvc.model.ResourceSet();
            cpt = 0;
            
            %ceate groups of data
            grpsToCompare = this.config.getParamValue('GroupsToCompare');
            for g=1:nbGroups
                sliceNames = rowGrpStrategy.getSliceNamesOfGroup(grpLabels{g});
                
                if ~isempty(grpsToCompare)
                    [ ~, sliceIdx ] = ismember(grpsToCompare, sliceNames);
                else
                    nbSlices = length(sliceNames);
                    sliceIdx  = 1:nbSlices;
                end
                
                sliceIdx = sliceIdx(sliceIdx ~= 0);
                
                for i=1:length(sliceIdx)
                    grpName1 = sliceNames{sliceIdx(i)};
                    groupData1 = dataSet.getDataByRowName( ['(^',grpName1,'$)|(_',grpName1,'_)|(^',grpName1,'_)|(_',grpName1,'$)'] );
                    if isempty(groupData1), continue; end
                    for j=(i+1):length(sliceIdx)
                        grpName2 = sliceNames{sliceIdx(j)};
                        groupData2 = dataSet.getDataByRowName( ['(^',grpName2,'$)|(_',grpName2,'_)|(^',grpName2,'_)|(_',grpName2,'$)'] );
                        if isempty(groupData2), continue; end
                        
                        % fill zero values in groupData1
                        negIdx = groupData1 <= 0;
                        nbNeg = sum(negIdx(:));
                        if nbNeg > 0 && ~this.config.getParamValue('NegativeValuesImputation')
                            %error('Cannot compute fold changes because of negative values in data. Set parameter NegativeValuesImputation to true')
                        else
                            groupData1( negIdx ) = LoQ * rand(1,nbNeg);
                        end
                        
                        % fill zero values in groupData2
                        negIdx = groupData2 <= 0;
                        nbNeg = sum(negIdx(:));
                        if nbNeg > 0 && ~this.config.getParamValue('NegativeValuesImputation')
                            %error('Cannot compute fold changes because of negative values in data. Set parameter NegativeValuesImputation to true')
                        else
                            groupData2( negIdx ) = LoQ * rand(1,nbNeg);
                        end
                        % Normality Test
                  
                        sG1 = size(groupData1);
                        sG2 = size(groupData2);
                       
                        hG1 = [];
                        hG2 = [];
                        for f=1:sG1(2)
                            [Hg1 ] = swtest(groupData1(1:sG1(1),f));
                            hG1 = [hG1, Hg1];
                        end
                       for f=1:sG2(2)     
                            [Hg2 ] = swtest(groupData2(1:sG2(1),f));
                            hG2 = [hG2, Hg2];
                        end
               %check with adama
                        warning('\r The group1 have a %g features on %g of total features which does not follow a normal distribution, %g percent \r',sum(hG1>0), length(hG1), sum(hG1>0)/length(hG1) )
                        warning('\r The group2 have a %g features on %g of total features which does not follow a normal distribution, %g percent \r', sum(hG2>0), length(hG2), sum(hG2>0)/length(hG2) )

                        if strcmp(this.config.getParamValue('Method'), 'ttest')
                        
                            
                            [pvalues,zscores] = mattest(groupData1', groupData2');
                            foldchanges = mean(groupData1) ./ mean(groupData2);
                            
                            if any(foldchanges <= 0) || any(isnan(foldchanges)) || any(isinf(foldchanges))
                                warning('Some fold changes are negative or infinite numbers. You probably need to scale your data to have non-zero positive values or set parameter NegativeValuesImputation to true for impute negative values')
                            end
                            
                            %adjust p-value
                            q = this.config.getParamValue('PValueThreshold');
                            [~, ~, ~, adjPValue] = fdrbh.fdrbh(pvalues,q,'dep');
                            
                            diffMatrix = biotracs.data.model.DataMatrix(...
                                [pvalues, -log10(pvalues), adjPValue, -log10(adjPValue), zscores, abs(zscores), foldchanges(:), log2(foldchanges(:))], ...
                                {'P-Value', '-Log10[P-Value]', 'Adj-P-Value', '-Log10[Adj-P-Value]', 'Z-Score', 'Abs[Z-Score]', 'FoldChange', 'Log2[FoldChange]'}, ...
                                dataSet.getColumnNames() ...
                                );
                            
                        elseif strcmp(this.config.getParamValue('Method'), 'MannWhitney')
                            pvalues = [];
                            zscores = [];
                            for k=1:sG1(2)
                                [pval,~, z] = ranksum(groupData1(1:sG1(1),k), groupData2(1:sG2(1),k));
                                pvalues=[pvalues; pval];
                                zscores= [zscores;z.ranksum];
                            end
                            
                            foldchanges = mean(groupData1) ./ mean(groupData2);
                            
                            if any(foldchanges <= 0) || any(isnan(foldchanges)) || any(isinf(foldchanges))
                                warning('Some fold changes are negative or infinite numbers. You probably need to scale your data to have non-zero positive values or set parameter NegativeValuesImputation to true for impute negative values')
                            end
                            
                            %adjust p-value
                            q = this.config.getParamValue('PValueThreshold');
                            [~, ~, ~, adjPValue] = fdrbh.fdrbh(pvalues,q,'dep');
                            
                            diffMatrix = biotracs.data.model.DataMatrix(...
                                [pvalues, -log10(pvalues), adjPValue, -log10(adjPValue), zscores, abs(zscores), foldchanges(:), log2(foldchanges(:))], ...
                                {'MWXXP-Value', '-Log10[P-Value]', 'Adj-P-Value', '-Log10[Adj-P-Value]', 'Z-Score', 'Abs[Z-Score]', 'FoldChange', 'Log2[FoldChange]'}, ...
                                dataSet.getColumnNames() ...
                                );
                        else
                            % error('Not yet avalable')
                            % [pvalues,h,stats] = ranksum(groupData1', groupData2');
                            % foldchanges = mean(groupData1) ./ mean(groupData2);
                            % foldchangesQ2 = median(groupData1) ./ median(groupData2);
                            % diffMatrix = biotracs.data.model.DataMatrix(...
                            % [pvalues, -log10(pvalues), zscores, abs(zscores), foldchanges(:), log2(foldchanges(:)), foldchangesQ2(:), log2(foldchangesQ2(:))], ...
                            % {'P-Value', '-Log10[P-Value]', 'Z-Score', 'Abs[Z-Score]', 'FoldChange', 'Log2[FoldChange]', 'FoldChangeQ2', 'Log2[FoldChangeQ2]'}, ...
                            % dataSet.getColumnNames() ...
                            % );
                        end
                        
                        %mavolcanoplot(groupData1', groupData2', pvalues, 'Labels', dataSet.getColumnNames());
                        cpt = cpt + 1;
                        diffTable.add(diffMatrix.sortRows(1), [ grpName1, '_', grpName2 ]);
                    end
                    
                    if isempty(groupData1) || isempty(groupData2)
                        error('SPECTRA:Diff:InvalidGroups', 'The provided group names are not valid');
                    end
                    
                    meanMatrix = mean(groupData1);
                    stdMatrix = std(groupData1);
                    medianMatrix = median(groupData1);
                    iqrMatrix = iqr(groupData1);
                    statMatrix = biotracs.data.model.DataMatrix(...
                        [meanMatrix', stdMatrix', medianMatrix', iqrMatrix'], ...
                        {['Mean ', grpName1], ['Std ', grpName1], ['Q2 ', grpName1], ['IQR ', grpName1]}, ...
                        dataSet.getColumnNames() ...
                        );
                    statTable.add(statMatrix, sliceNames{sliceIdx(i)});
                end
                
            end
            
            diffTable.setLabel('DiffTable')...
                .setDescription('Differential analysis results');
            
            statTable.setLabel('StatisticsTable')...
                .setDescription('Group statistics');
            
            %collect results
            result.set('DiffTable', diffTable);
            result.set('StatTable', statTable);
            
            %filtered results
            filteredDiffTable = result.getSignificantDiffTable( ...
                'PValueThreshold', this.config.getParamValue('PValueThreshold'), ...
                'FoldChangeThreshold', this.config.getParamValue('FoldChangeThreshold') ...
                );
            filteredDiffTable.setLabel('SignificantDiffTable');
            result.set('SignificantDiffTable', filteredDiffTable);
            
            %trigger output
            this.setOutputPortData('Result', result);
        end
        
    end
    
    
end
