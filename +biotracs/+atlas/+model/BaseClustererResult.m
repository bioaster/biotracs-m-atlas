% BIOASTER
%> @file		BaseClustererResult.m
%> @class		biotracs.atlas.model.BaseClustererResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef (Abstract) BaseClustererResult < biotracs.atlas.model.BaseLearnerResult
    
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
        function this = BaseClustererResult()
            %#function biotracs.atlas.view.BaseClustererResult
            
            this@biotracs.atlas.model.BaseLearnerResult();
            this.classNameOfElements = {'biotracs.core.mvc.model.Resource'};
        end

        %-- C --

        %-- G --

        function nbclust = getNumberOfInstanceClasses( this )
            centroids = this.get('InstanceClassCentroids').getData();
            nbclust = length(centroids.mu);
        end

        %-- S --

        function setInstanceClassCentroidData( this, iCentroids )
            d = biotracs.data.model.DataObject( iCentroids );
            this.set('InstanceClassCentroids', d);
        end
        
        function setInstanceClassListData( this, iClassList )
            d = biotracs.data.model.DataObject( iClassList );
            this.set('InstanceClassList', d);
        end
        
        function setInstanceClassData( this, iClassData, iInstanceNames )
            %size(iClassData)
            %size(iInstanceNames)
            dm = biotracs.data.model.DataMatrix( iClassData, {'ClassMembership'}, iInstanceNames );
            this.set('InstanceClasses', dm);
        end
        
        function setVariableClassCentroidData( this, iCentroids )
            d = biotracs.data.model.DataObject( iCentroids );
            this.set('VariableClassCentroids', d);
        end
        
        function setVariableClassListData( this, iClassList )
            d = biotracs.data.model.DataObject( iClassList );
            this.set('VariableClassList', d);
        end
        
        function setVariableClassData( this, iClassValues, iVariableNames )
            dm = biotracs.data.model.DataMatrix( iClassValues, {'ClassMembership'}, iVariableNames );
            this.set('VariableClasses', dm);
        end
        
        %-- P --
        
    end
    
    
    methods( Access = protected )

    end
    
end
