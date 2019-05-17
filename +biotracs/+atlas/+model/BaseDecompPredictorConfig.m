% BIOASTER
%> @file		BaseDecompPredictorConfig.m
%> @class		biotracs.spectra.pcomp.model.BaseDecompPredictorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef BaseDecompPredictorConfig < biotracs.atlas.model.BasePredictorConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseDecompPredictorConfig( )
            this@biotracs.atlas.model.BasePredictorConfig( );
            this.createParam(...
                'NbComponents', [], ...
                'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'Strict', true) ...
            ); 
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
