% BIOASTER
%> @file		AggregLearner.m
%> @class		biotracs.atlas.model.AggregLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregLearner < biotracs.atlas.model.BaseLearner
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregLearner()
            %#function biotracs.atlas.model.AggregLearnerConfig biotracs.atlas.model.AggregLearnerResult
            
            this@biotracs.atlas.model.BaseLearner();           
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.AggregLearnerResult' ...
                )...
                });      
            
            this.bindEngine(biotracs.atlas.model.FeatureGrouper, 'FeatureGrouper');
        end
        
    end
    
    methods(Access = protected)
        
        function doLearnPerm( varargin )
            % do nothing
        end	
        
        function doLearnCv( varargin )
            % do nothing
        end  	
        
        function doLearn( this, ~, ~ )
            %verbose = this.config.getParamValue('Verbose');
            trSet = this.getInputPortData('TrainingSet').selectXSet();
            e = this.getEngine('FeatureGrouper');
            e.setInputPortData('DataSet', trSet);
            e.config.updateParamValue('RedundancyCorrelation', this.config.getParamValue('CorrelationThreshold'));
            e.config.updateParamValue('RedundancyPValue', this.config.getParamValue('CorrelationPValue'));
            e.config.updateParamValue('MinNbOfAdjacentFeatures', 0);
            e.config.updateParamValue('LinkingOrders', Inf);
            e.config.updateParamValue('MinNbOfFeaturesPerGroup', 0);
            e.config.updateParamValue('MaxNbOfFeaturesToUseForConsensus', this.config.getParamValue('MaxNbOfFeaturesPerAggregation'));
            e.config.updateParamValue('ConsensusFunction', this.config.getParamValue('AggregationFunction'));
            e.run();
            isofeatureMap = e.getOutputPortData('IsoFeatureMap');

            result = this.getOutputPortData('Result');
            result.set('IsoFeatureMap', isofeatureMap);
            this.setOutputPortData('Result', result);
        end
        
    end
    
end
