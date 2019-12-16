% BIOASTER
%> @file		BaseDecompLearnerResult.m
%> @class		biotracs.atlas.model.BaseDecompLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract)BaseDecompLearnerResult < biotracs.atlas.model.BaseLearnerResult
    
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
        function this = BaseDecompLearnerResult( varargin )
            %#function biotracs.atlas.view.BaseDecompLearnerResult
            
            this@biotracs.atlas.model.BaseLearnerResult();
            this.set('XLoadings', biotracs.data.model.DataMatrix.empty());
            this.set('XScores', biotracs.data.model.DataMatrix.empty());
            this.set('XResiduals', biotracs.data.model.DataMatrix.empty());
            this.set('XVarExplained', biotracs.data.model.DataMatrix.empty());
        end
        
        %-- E --

        %-- G --
        
        function XL = getXLoadingData( this )
            XL = this.get('XLoadings').getData();
        end
        
        function dm = getXLoadings( this )
            dm = this.get('XLoadings');
        end
        
        function XS = getXScoreData( this )
            XS = this.get('XScores').getData();
        end
        
        function ds = getXScores( this )
            ds = this.get('XScores');
        end
        
        function Xvar = getXVarExplainedData( this )
            var = this.get('XVarExplained').getData();
            Xvar = var(1,:);
        end
        
        function XR = getXResidualData( this )
            XR = this.get('XResiduals').getData();
        end
        
        %-- H --
        
        function tf = hasCrossValidationData( this, varargin )
            tf = false;
        end
        
        function tf = hasPermutationTestData( this, varargin )
            tf = false;
        end
        
    end
    
    methods
        
        function setXLoadingData( this, XL, iInstanceNames )
            d = biotracs.data.model.DataMatrix(XL, 'PC', iInstanceNames);
            this.set('XLoadings', d);
        end
        
        function setXScoreData( this, XS, iInstanceNames )
            d = biotracs.data.model.DataSet( XS, 'PC', iInstanceNames );
            this.set('XScores', d);
        end

        function setXResidualData( this, XR, iVariableNames, iInstanceNames )
            d = biotracs.data.model.DataSet( XR, iVariableNames, iInstanceNames );
            this.set('XResiduals', d);
        end
        
        function setXVarExplainedData( this, varExp )
            d = biotracs.data.model.DataMatrix( varExp, 'PC', {'XVarExplained'} );
            this.set('XVarExplained', d);
        end
        
    end

end
