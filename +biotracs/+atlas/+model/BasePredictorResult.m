% BIOASTER
%> @file		BasePredictorResult.m
%> @class		biotracs.atlas.model.BasePredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BasePredictorResult < biotracs.atlas.model.BaseResult
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BasePredictorResult( varargin )
            this@biotracs.atlas.model.BaseResult();
            this.set( 'Stats', biotracs.core.mvc.model.ResourceSet.empty() );
            this.set( 'XPredictions', biotracs.data.model.DataSet.empty() );
            
            this.set( 'YPredictions', biotracs.data.model.DataSet.empty() );
            this.set( 'YPredictionLowerBounds', biotracs.data.model.DataMatrix.empty() );
            this.set( 'YPredictionUpperBounds', biotracs.data.model.DataMatrix.empty() );

            this.set( 'YPredictionMeans', biotracs.data.model.DataSet.empty() );
            this.set( 'YPredictionStds', biotracs.data.model.DataSet.empty() );
            
            this.set( 'YPredictionScores', biotracs.data.model.DataSet.empty() );
            this.set( 'YPredictionScoreMeans', biotracs.data.model.DataSet.empty() );
            this.set( 'YPredictionScoreStds', biotracs.data.model.DataSet.empty() );
        end
        
        %-- B --
        
        %-- E --
        
        %-- G --
        
        function ds = getTrainingSet( this )
            lerningResult = this.process.getInputPortData('PredictiveModel');
            ds = lerningResult.getTrainingSet();
        end

        function pred = getXPredictionData( this )
            pred = this.get('XPredictions').getData();
        end
        
        function pred = getYPredictionData( this )
            pred = this.get('YPredictions').getData();
        end
        
        function pred = getYPredictionDataLowerBounds( this )
            pred = this.get('YPredictionLowerBounds').getData();
        end
        
        function pred = getYPredictionDataUpperBounds( this )
            pred = this.get('YPredictionUpperBounds').getData();
        end

        %-- I --
 
        %-- S --
        
        function setXPredictionData( this, pred )
            ds = biotracs.data.model.DataSet();
            ds.setLabel('XPrediction');
            ds.setData(pred);
            this.set( 'XPredictions', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( this.getVariableNames() );
        end
        
        function setYPredictionData( this, pred )
            ds = biotracs.data.model.DataSet();
            ds.setLabel('YPrediction');
            ds.setData(pred);
            this.set( 'YPredictions', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( this.getResponseNames() );
        end
        
        function setYPredictionDataLowerBounds( this, pred )
            ds = biotracs.data.model.DataMatrix();
            ds.setLabel('YPredictionLowerBounds');
            ds.setData(pred);
            this.set( 'YPredictionLowerBounds', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( this.getResponseNames() );
        end
        
        function setYPredictionDataUpperBounds( this, pred )
            ds = biotracs.data.model.DataMatrix();
            ds.setLabel('YPredictionUpperBounds');
            ds.setData(pred);
            this.set( 'YPredictionUpperBounds', ds );
            ds.setRowNames( this.getTestInstanceNames() );
            ds.setColumnNames( this.getResponseNames() );
        end

    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
    
end
