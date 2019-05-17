% BIOASTER
%> @file		PCAPredictor.m
%> @class		biotracs.atlas.model.PCAPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PCAPredictor < biotracs.atlas.model.BaseDecompPredictor
    
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
        function this = PCAPredictor()
            this@biotracs.atlas.model.BaseDecompPredictor();
            
            % enhance inputs specs
            this.updateInputSpecs({...
                struct(...
                'name', 'PredictiveModel',...
                'class', 'biotracs.atlas.model.PCALearnerResult' ...
                )...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PCAPredictorResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        function [ predictions ] = doPredict( this, X0te, varargin )
            predictiveModel = this.getInputPortData('PredictiveModel');
            XL = predictiveModel.getXLoadingData();
            maxNComp = size(XL,2);
 
            p = inputParser();
            p.addParameter('NbComponents', maxNComp, @isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            ncomp = p.Results.NbComponents;
            
            if isempty(ncomp)
                ncomp = maxNComp;
            end
            
            if ncomp > maxNComp
                error('Only %d components are availables while %d are used', maxNComp, ncomp);
            end
            predictions = struct( 'projX0test', X0te * XL(:,1:ncomp) );        %projXtest on scores            
        end
        
    end
    
    
end
