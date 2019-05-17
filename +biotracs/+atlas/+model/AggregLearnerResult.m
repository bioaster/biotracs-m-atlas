% BIOASTER
%> @file		AggregLearnerResult.m
%> @class		biotracs.atlas.model.AggregLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregLearnerResult < biotracs.atlas.model.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregLearnerResult()
            this@biotracs.atlas.model.BaseLearnerResult()
            this.set('IsoFeatureMap',biotracs.spectra.data.model.IsoFeatureMap.empty());
            %this.set('AdjacencyMatrix',biotracs.spectra.data.model.DataMatrix.empty());
            this.bindView(biotracs.atlas.view.AggregLearnerResult());
        end

        %-- G --

    end
    
    methods

        
    end
    
end
