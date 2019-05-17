% BIOASTER
%> @file		PLSPredictorResult.m
%> @class		biotracs.atlas.pls.model.PLSPredictorResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PLSPredictorResult < biotracs.atlas.model.BaseDecompPredictorResult
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PLSPredictorResult()
            nbMatrixElements = 0; %X Projection and Y Prediction matrices
            this@biotracs.atlas.model.BaseDecompPredictorResult( nbMatrixElements );
            %this.classNameOfElements = {'biotracs.data.model.DataTable'};
            this.bindView( biotracs.atlas.view.PLSPredictorResult );
        end
 
    end
    
end
