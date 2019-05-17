% BIOASTER
%> @file		TSNELearner.m
%> @class		biotracs.atlas.model.TSNELearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef TSNELearner < biotracs.atlas.model.BaseLearner
    
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
        function this = TSNELearner()
            this@biotracs.atlas.model.BaseLearner();
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.TSNELearnerResult' ...
                )...
             });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doLearn( this, X0, varargin )
            ndim = this.config.getParamValue('NbDimensions');
            [redudedX0] = tsne.tsne( X0, ndim );
            result = this.getOutputPortData('Result');
            reducedDataSet = biotracs.data.model.DataSet( redudedX0 );
            result.set(reducedDataSet, 'ReducedDataSet');
        end
        
        function doLearnCv( this, X0, varargin)
            %not yet implemented
            error('The cross-validation algorithm is not yet implemented for pca')
        end
        
    end
    
    
end
