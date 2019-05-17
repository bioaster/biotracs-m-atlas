% BIOASTER
%> @file		BaseLearnerResult.m
%> @class		biotracs.atlas.model.BaseLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseLearnerResult < biotracs.atlas.model.BaseResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseLearnerResult()
            this@biotracs.atlas.model.BaseResult();
            this.set('Stats', biotracs.atlas.model.BaseLearnerStats());
        end
        
        %-- B --
        
        %-- G --

        function d = getStats( this, varargin )
            d = this.get('Stats');
        end

        function getRegCoef( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function getCrossValidationRegCoef( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function getCrossValidationVariableRanking( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function getPermutationTestSignificance( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function getYResidualData( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function hasCrossValidationData( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        function hasPermutationTestData( varargin )
            error('Not implemented here. Must be implemeted in inherited class.');
        end
        
        %-- I --
   
        %-- S --
        
        function setStatData( this, iStatData, varargin )
            learningStats = this.get('Stats');
            learningStats.setStatData(iStatData, varargin{:});
        end

    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
    
end
