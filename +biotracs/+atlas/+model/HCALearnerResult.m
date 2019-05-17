% BIOASTER
%> @file		HCALearnerResult.m
%> @class		biotracs.atlas.model.HCALearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef HCALearnerResult < biotracs.atlas.model.BaseClustererResult
    
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
        function this = HCALearnerResult( varargin )
            this@biotracs.atlas.model.BaseClustererResult();
            this.bindView( biotracs.atlas.view.HCALearnerResult );
        end
        
        %-- C --
        
        %-- G --

        function this = setTreeData( this, iTree, iVariableNames, iInstanceNames )
            if isa(iTree, 'clustergram')
                set( iTree, ...
                    'RowLabels', strrep(iInstanceNames,'_','-'), ...
                    'ColumnLabels',strrep(iVariableNames,'_','-'), ...
                    'Linkage', {'average', 'average'} ...
                );
            end
            treeObject = biotracs.data.model.DataObject( iTree );	  %@ToDo: use DataMatrix
            this.set( 'Tree', treeObject );
        end
        
    end
    
    methods( Access = protected )

    end
end
