% BIOASTER
%> @file		PoolLearnerResult.m
%> @class		biotracs.atlas.model.PoolLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef PoolLearnerResult < biotracs.atlas.model.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PoolLearnerResult()
            this@biotracs.atlas.model.BaseLearnerResult()
            this.bindView(biotracs.atlas.view.PoolLearnerResult());
            this.add(biotracs.data.model.DataMatrix, 'PoolingMap');
            this.add(biotracs.data.model.DataMatrix, 'PoolingVariables');
        end

        %-- G --
        
        function poolingVariables = getPoolingVariables( this )
            poolingVariables = this.getProcess().getInputPortData('PoolingVariables');  
            if isa( poolingVariables, 'biotracs.core.mvc.model.ResourceSet' )
                poolingVariables = poolingVariables.getAt(1);
            end
        end
        
    end
    
    methods

        
    end
    
end
