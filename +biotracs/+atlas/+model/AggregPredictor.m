% BIOASTER
%> @file		AggregPredictor.m
%> @class		biotracs.atlas.model.AggregPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregPredictor < biotracs.atlas.model.BasePredictor
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregPredictor()
            %#function biotracs.atlas.model.AggregPredictorConfig biotracs.atlas.model.AggregPredictorResult biotracs.atlas.view.AggregPredictorResult
            
            this@biotracs.atlas.model.BasePredictor();
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.AggregPredictorResult' ...
                )...
                });    
            
        end
        
    end
    
    methods(Access = protected)
        
        function predStruct = doPredict( this, X0te, varargin )
            p = inputParser();
            p.addParameter('FilteredTestSetColumnNames', {}, @iscellstr);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            predModel = this.getInputPortData('PredictiveModel'); 
            isofeatureMap = predModel.get('IsoFeatureMap');
            teSet = this.getInputPortData('TestSet').selectXSet();

            nbFeaturesPerConsensus = this.config.getParamValue('MaxNbOfFeaturesPerAggregation');
            if isempty(nbFeaturesPerConsensus)
                nbFeaturesPerConsensus = predModel.getProcess().config('MaxNbOfFeaturesPerAggregation');
            end
            
            consensusFunction = this.config.getParamValue('AggregationFunction');
            if isempty(consensusFunction)
                consensusFunction = predModel.getProcess().config('AggregationFunction');
            end
            
            teX0Set = biotracs.data.model.DataSet(X0te, p.Results.FilteredTestSetColumnNames, teSet.rowNames);
            [ predX0testDataSet ] = biotracs.atlas.helper.FeatureGroupCalculator.reduceDataSetUsingIsofeatureMap( ...
                teX0Set, isofeatureMap, ...
                'MaxNbOfFeaturesToUseForConsensus', nbFeaturesPerConsensus, ...
                'ConsensusFunction', consensusFunction ...
                );
            
            predStruct = struct();
            
            result = this.getOutputPortData('Result');
            result.set('XPredictions', predX0testDataSet);
            
            ySet = this.getInputPortData('TestSet').selectYSet();
            if ~ySet.hasEmptyData()
                result.set('AggregatedDataSet', horzmerge(predX0testDataSet, ySet))
            else
                result.set('AggregatedDataSet', predX0testDataSet);
            end
        end
        
        % Overload the base function
        function predStruct = doReverseNormalize( ~, predStruct )
            % Overload the base function
            % Do not perform reverse normalization because the pooled data
            % cannot be properly un-normalized
        end
        
    end
    
end
