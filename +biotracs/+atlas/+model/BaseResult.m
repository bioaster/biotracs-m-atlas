% BIOASTER
%> @file		BaseResult.m
%> @class		biotracs.atlas.model.BaseResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		6 Mar. 2015

classdef (Abstract) BaseResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseResult()
            this@biotracs.core.mvc.model.ResourceSet();
        end
        
        %-- B --
        
        %-- G --
        
        function trSet = getTrainingSet( this )
            if isNil(this.process)
                error('SPECTRA:BaseResult:NoProcessFound','No process is associated with this resource');
            end
            trSet = this.process.getInputPortData('TrainingSet');
        end

        function teSet = getTestSet( this )
            if isNil(this.process)
                error('SPECTRA:BaseResult:NoProcessFound','No process is associated with this resource');
            end
            teSet = this.process.getInputPortData('TestSet');
        end
        
        function m = getNbTrainingInstances( this )
            trSet = this.getTrainingSet();
            m = trSet.getNbInstances();
        end
        
        function m = getNbTestInstances( this )
            teSet = this.getTestSet();
            m = teSet.getNbInstances();
        end
        
        function n = getNbVariables( this )
            trSet = this.getTrainingSet();
            n = trSet.getNbVariables();
        end
        
        function n = getNbResponses( this )
            trSet = this.getTrainingSet();
            n = trSet.getNbResponses();
        end
        
        function names = getTrainingInstanceNames( this )
            trSet = this.getTrainingSet();
            names = trSet.getInstanceNames();
        end
        
        function names = getTestInstanceNames( this )
            teSet = this.getTestSet();
            names = teSet.getInstanceNames();
        end
        
        function names = getResponseNames( this )
            trSet = this.getTrainingSet();
            names = trSet.getResponseNames();
        end
        
        function names = getVariableNames( this )
            trSet = this.getTrainingSet();
            names = trSet.getVariableNames();
        end
        
        function names = getInstanceNames( this )
            trSet = this.getTrainingSet();
            names = trSet.getRowNames();
        end
        
        %-- I --
        
        function tf = isSupervisedAnalysis( this )
            trSet = this.getTrainingSet();
            tf = trSet.hasResponses();
        end
        
        function tf = isDiscriminantAnalysis( this )
            trSet = this.getTrainingSet();
            tf = trSet.hasCategoricalResponses();
        end
            
        %-- S --
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    
    end
    
    
end
