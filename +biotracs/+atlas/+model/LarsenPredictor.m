% BIOASTER
%> @file		LarsenPredictor.m
%> @class		biotracs.atlas.model.LarsenPredictor
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef LarsenPredictor < biotracs.atlas.model.BasePredictor
    
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
        function this = LarsenPredictor()
            this@biotracs.atlas.model.BasePredictor();
            
            % enhance outputs specs
            this.addInputSpecs({...
                struct(...
                'name', 'PredictiveModel',...
                'class', 'biotracs.atlas.model.LarsenLearnerResult' ...
                )...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.LarsenPredictorResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doPredict( varargin )
            error('SPECTRA:MethodNotImplemented','No yet implemented');
        end
        
    end
    
    
end
