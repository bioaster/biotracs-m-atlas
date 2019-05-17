% BIOASTER
%> @file		DiffProcessResult.m
%> @class		biotracs.atlas.model.DiffProcessResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef DiffProcessResult < biotracs.core.mvc.model.ResourceSet
    
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

        function this = DiffProcessResult( )
            this@biotracs.core.mvc.model.ResourceSet();
            %this.classNameOfElements = {'biotracs.core.mvc.model.Resource'};
            this.set('SignificantDiffTable', biotracs.core.mvc.model.ResourceSet.empty());
            this.set('DiffTable', biotracs.core.mvc.model.ResourceSet.empty());
            this.set('StatTable', biotracs.core.mvc.model.ResourceSet.empty());
            this.bindView( biotracs.atlas.view.DiffProcessResult );
        end
        
        function topNDiffTable = getSignificantDiffTable( this, varargin )
            p = inputParser();
            config = this.process.getConfig();
            p.addParameter('PValueThreshold', config.getParamValue('PValueThreshold'), @isnumeric);
            p.addParameter('FoldChangeThreshold', config.getParamValue('FoldChangeThreshold'), @isnumeric);
            p.addParameter('GroupsToCompare', {}, @iscell);
            p.parse( varargin{:} );
            
            diffTable = this.get('DiffTable');
            nbDiffMatrices = diffTable.getLength();
            
            groupsToCompare = p.Results.GroupsToCompare;

            topNDiffTable = biotracs.core.mvc.model.ResourceSet();
            for g=1:nbDiffMatrices
                %chech that these groups must be compared
                grpNames = strsplit(diffTable.elementNames{g},'_');
                grp1Name = grpNames{1};
                grp2Name = grpNames{2};
                
                if ~isempty(groupsToCompare)
                    Ok = false;
                    for i=1:length(groupsToCompare)
                        Ok = ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp1Name,grp2Name} )) || ...
                            ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp2Name,grp1Name} ));
                        if Ok, break; end
                    end
                else
                    Ok = true;
                end
                
                if ~Ok
                    continue; 
                end
                
                %get diff matrix data
                diffMatrix = diffTable.getAt(g);

                %select corresponding group's stats
                pValues = diffMatrix.getDataByColumnName('^P-Value$');
                tTestValues = diffMatrix.getDataByColumnName('^Z-Score$');
                fcValues = diffMatrix.getDataByColumnName('^FoldChange$');
                labelValues = diffMatrix.getRowNames();
                
                pValueThreshold = p.Results.PValueThreshold;
                fcThreshold = p.Results.FoldChangeThreshold;
                
                sIdx = (pValues <= pValueThreshold) & (fcValues >= fcThreshold | 1./fcValues >= fcThreshold);
                tTestValues = tTestValues(sIdx);
                pValues = pValues(sIdx);
                fcValues = fcValues(sIdx);
                labelValues = labelValues(sIdx);

                d = biotracs.data.model.DataMatrix( ...
                    [pValues(:), -log10(pValues(:)), tTestValues(:), abs(tTestValues(:)), fcValues(:), log2(fcValues(:))], ...
                    {'P-Value', '-Log10[P-Value]', 'Z-Score', 'Abs[Z-Score]', 'FoldChange', 'Log2[FoldChange]'}, ...
                    labelValues ...
                    );
                topNDiffTable.add( d.sortRows(1), diffTable.elementNames{g} );
            end
        end
        
        %Deprecated
        function topN = getSignificantList( this, varargin ) %#ok<STOUT,INUSD>
            error('SPECTRA:Diff:Result', 'This method is deprecated. Use getSignificantDiffTable() instead');
            
            p = inputParser();
            p.addParameter('PValueThreshold', 0.05, @isnumeric);
            p.addParameter('GroupsToCompare', {}, @iscell);
            p.parse( varargin{:} );
            
            diffTable = this.get('DiffTable');
            nbDiffMatrices = diffTable.getNbColumns();
            
            groupsToCompare = p.Results.GroupsToCompare;
            
            topN = cell(1,nbDiffMatrices);
            for g=1:nbDiffMatrices
                %chech that these groups must be compared
                grp1Name = diffTable.getColumnTag(g).Group1;
                grp2Name = diffTable.getColumnTag(g).Group2;
                if ~isempty(groupsToCompare)
                    Ok = false;
                    for i=1:length(groupsToCompare)
                        Ok = ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp1Name,grp2Name} )) || ...
                            ~isempty(biotracs.core.utils.cellfind( groupsToCompare, {grp2Name,grp1Name} ));
                        if Ok, break; end
                    end
                else
                    Ok = true;
                end
                
                if ~Ok, continue; end
                
                %get diff matrix data
                diffMatrix = diffTable.getDataAt(g).sortRows(1);
                
                %select corresponding group's stats
                pValues = diffMatrix.data(:,1)';
                tTestValues = diffMatrix.data(:,2)';
                labelValues = diffMatrix.getRowNames();
                
                pValueThreshold = p.Results.PValueThreshold;
                sIdx = pValues < pValueThreshold;
                tTestValues = tTestValues(sIdx);
                pValues = pValues(sIdx);
                labelValues = labelValues(sIdx);

                d = biotracs.data.model.DataMatrix( ...
                    [pValues(:), tTestValues(:), abs(tTestValues(:))], ...
                    {'PValue','tTestValue', 'AbsTTestValue'}, ...
                    labelValues ...
                    );
                topN{g} = d.sortRows(-3);
            end
        
        end
        
    end
end
