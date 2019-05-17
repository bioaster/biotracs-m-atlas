% BIOASTER
%> @file		SelectedVariableDataMatrix.m
%> @class		biotracs.atlas.model.SelectedVariableDataMatrix
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		3° Oct. 2018

classdef SelectedVariableDataMatrix < biotracs.data.model.DataMatrix
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = SelectedVariableDataMatrix( varargin )
            this@biotracs.data.model.DataMatrix( varargin{:} );
        end

        %-- C --
        
        %-- G --
    end
    
    methods(Static)
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.atlas.model.SelectedVariableDataMatrix();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.atlas.model.SelectedVariableDataMatrix();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.atlas.model.SelectedVariableDataMatrix();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.atlas.model.SelectedVariableDataMatrix();
            this.doCopy( iDataSet );
        end
        
        function this = import( iFilePath, varargin )
            isTableClassDefined = any(strcmpi(varargin, 'TableClass'));
            if ~isTableClassDefined
                varargin = [varargin, {'TableClass', 'biotracs.atlas.model.SelectedVariableDataMatrix'}];
            end
            this = biotracs.data.model.DataTable.import( iFilePath, varargin{:} );
        end
        
    end
    
end
