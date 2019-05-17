% BIOASTER
%> @file		TSNELearnerResult.m
%> @class		biotracs.atlas.model.TSNELearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef (Abstract)TSNELearnerResult < biotracs.atlas.model.BaseLearnerResult
    
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
        function this = TSNELearnerResult( iNbMatrixElements )
            this@biotracs.atlas.model.BaseLearnerResult( iNbMatrixElements );
            this.classNameOfElements = {'biotracs.data.model.DataMatrix'};
            
            this.add( 'ReducedDataSet', biotracs.data.model.DataMatrix.empty() );
        end
 
    end

end
