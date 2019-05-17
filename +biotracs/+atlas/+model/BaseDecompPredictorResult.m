% BIOASTER
%> @file		BaseDecompPredictorResult.m
%> @class		biotracs.atlas.model.BaseDecompPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract)BaseDecompPredictorResult < biotracs.atlas.model.BasePredictorResult
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseDecompPredictorResult( varargin )
            this@biotracs.atlas.model.BasePredictorResult( );
        end
        
        %-- G --

        function pred = getXProjectionData( this )
            pred = this.get('XProjections').getData();
        end

        function pred = getYProjectionData( this )
            pred = this.get('YProjections').getData();
        end
        
        %-- S --

        %-- S --

        function setXProjectionData( this, pred )
            ds = biotracs.data.model.DataMatrix();
            ds.setData(pred);
            this.set( 'XProjections', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( 'PCX' );
        end
        
        function setYProjectionData( this, pred )
            ds = biotracs.data.model.DataMatrix();
            ds.setData(pred);
            this.set( 'YProjections', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( 'PCY' );
        end
        
    end
    
end
