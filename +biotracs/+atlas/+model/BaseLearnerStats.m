% BIOASTER
%> @file		BaseLearnerStats.m
%> @class		biotracs.atlas.model.BaseLearnerStats
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef BaseLearnerStats < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaseLearnerStats( )
            %estimation stats
            this@ biotracs.core.mvc.model.ResourceSet();
            this.add(biotracs.data.model.DataMatrix(), 'R2X');
            this.add(biotracs.data.model.DataMatrix(), 'AdjR2X');
            this.add(biotracs.data.model.DataMatrix(), 'R2Y');
            this.add(biotracs.data.model.DataMatrix(), 'AdjR2Y');
            this.add(biotracs.data.model.DataMatrix(), 'R2Yi');
            this.add(biotracs.data.model.DataMatrix(), 'AdjR2Yi');
            this.add(biotracs.data.model.DataMatrix(), 'MSEE_X');
            this.add(biotracs.data.model.DataMatrix(), 'MSEE_Y');
            this.add(biotracs.data.model.DataMatrix(), 'MSEE_Yi');
            %this.add(biotracs.data.model.DataMatrix(), 'MCR');
            this.add(biotracs.data.model.DataMatrix(), 'E2');
            this.add(biotracs.data.model.DataMatrix(), 'E2i');
            
            %cross-validation stats
            this.add(biotracs.data.model.DataMatrix(), 'MSEP_X');
            this.add(biotracs.data.model.DataMatrix(), 'MSEP_Y');
            this.add(biotracs.data.model.DataMatrix(), 'MSEP_Yi');
            this.add(biotracs.data.model.DataMatrix(), 'Q2X');            
            this.add(biotracs.data.model.DataMatrix(), 'Q2Y');
            this.add(biotracs.data.model.DataMatrix(), 'Q2Yi');
            this.add(biotracs.data.model.DataMatrix(), 'CV_E2');
            this.add(biotracs.data.model.DataMatrix(), 'CV_E2i');
            %this.add(biotracs.data.model.DataMatrix(), 'CV_MCR');
            
            %permutation stats distributions
            this.add(biotracs.data.model.DataMatrix(), 'PermR2Y');
            this.add(biotracs.data.model.DataMatrix(), 'PermAdjR2Y');
            %this.add(biotracs.data.model.DataMatrix(), 'PermMCR');
            this.add(biotracs.data.model.DataMatrix(), 'PermE2');
            this.add(biotracs.data.model.DataMatrix(), 'PermVip');
            
            %class info
            this.add(biotracs.data.model.DataMatrix(), 'ClassInfo');
            this.add(biotracs.data.model.DataMatrix(), 'CVClassInfo');
            
            %class info
            this.add(biotracs.data.model.DataMatrix(), 'ModelSelectPerf');
        end

        %-- B --
        
        %-- G --
          
        %-- H --
        
        %-- I --
   
        %-- S --
        
        %> @param iStats Structure containing statistics
        %> @param iResponsesNames Names of the response variables
        %> @param iIterName Name of the iteration axe
        function setStatData( this, iStats, iResponseNames, iIterName )
            % Estimation performance
            if isfield( iStats, 'R2X' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.R2X, {'R2X'}, iIterName );
                this.set('R2X', dataMatrix);
            end
            
            if isfield( iStats, 'adjR2X' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.adjR2X, {'AdjR2X'}, iIterName );
                this.set('AdjR2X', dataMatrix);
            end
            
            if isfield( iStats, 'R2Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.R2Y, {'R2Y'}, iIterName );
                this.set('R2Y', dataMatrix);
            end
            
            if isfield( iStats, 'adjR2Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.adjR2Y, {'AdjR2Y'}, iIterName );
                this.set('AdjR2Y', dataMatrix);
            end
            
            if isfield( iStats, 'R2Yi' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.R2Yi, strcat('R2Y_',iResponseNames), iIterName );
                this.set('R2Yi', dataMatrix);
            end
            
            if isfield( iStats, 'adjR2Yi' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.adjR2Yi, strcat('AdjR2Y_',iResponseNames), iIterName );
                this.set('AdjR2Yi', dataMatrix);
            end
            
            if isfield( iStats, 'E2' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.E2, {'E2'}, iIterName );
                this.set('E2', dataMatrix);
            end
            
            if isfield( iStats, 'E2i' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.E2i, strcat('E2_',iResponseNames), iIterName );
                this.set('E2i', dataMatrix);
            end
            
            if isfield( iStats, 'MSEE_X' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEE_X, {'MSEE_X'}, iIterName );
                this.set('MSEE_X', dataMatrix);
            end
            
            if isfield( iStats, 'MSEE_Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEE_Y, {'MSEE_X'}, iIterName );
                this.set('MSEE_Y', dataMatrix);
            end
            
            if isfield( iStats, 'MSEE_Yi' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEE_Yi, strcat('MSEE_Y_',iResponseNames), iIterName );
                this.set('MSEE_Yi', dataMatrix);
            end
                
            %if isfield( iStats, 'MCR' )
            %    dataMatrix = biotracs.data.model.DataMatrix( iStats.MCR, {'MCR'}, iIterName );
            %    this.set('MCR', dataMatrix);
            %end

            
            % Prediction perfomances
            if isfield( iStats, 'Q2X' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.Q2X, {'Q2X'}, iIterName );
                this.set('Q2X', dataMatrix);
            end
            
            if isfield( iStats, 'Q2Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.Q2Y, {'Q2Y'}, iIterName );
                this.set('Q2Y', dataMatrix);
            end
            
            if isfield( iStats, 'Q2Yi' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.Q2Yi, strcat('Q2Y_',iResponseNames), iIterName );
                this.set('Q2Yi', dataMatrix);
            end
            
            if isfield( iStats, 'MSEP_X' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEP_X, {'MSEP_X'}, iIterName );
                this.set('MSEP_X', dataMatrix);
            end
            
            if isfield( iStats, 'MSEP_Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEP_Y, {'MSEP_Y'}, iIterName );
                this.set('MSEP_Y', dataMatrix);
            end
            
            if isfield( iStats, 'MSEP_Yi' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.MSEP_Yi, strcat('MSEP_Y_',iResponseNames), iIterName );
                this.set('MSEP_Yi', dataMatrix);
            end
            
            %if isfield( iStats, 'CV_MCR' )
            %    dataMatrix = biotracs.data.model.DataMatrix( iStats.CV_MCR, {'CV_MCR'}, iIterName );
            %    this.set('CV_MCR', dataMatrix);
            %end
            
            if isfield( iStats, 'CV_E2' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.CV_E2, {'CV_E2'}, iIterName );
                this.set('CV_E2', dataMatrix);
            end
            
            if isfield( iStats, 'CV_E2i' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.CV_E2i, strcat('CV_E2i_', iResponseNames), iIterName );
                this.set('CV_E2i', dataMatrix);
            end
            
            %permutation stats
            if isfield( iStats, 'permR2Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.permR2Y, {'PermR2Y'}, iIterName );
                this.set('PermR2Y', dataMatrix);
            end
            
            if isfield( iStats, 'permAdjR2Y' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.permAdjR2Y, {'PermAdjR2Y'}, iIterName );
                this.set('PermAdjR2Y', dataMatrix);
            end
            
            %if isfield( iStats, 'permMCR' )
            %    dataMatrix = biotracs.data.model.DataMatrix( iStats.permMCR, {'PermMCR'}, iIterName );
            %    this.set('PermMCR', dataMatrix);
            %end
            
            if isfield( iStats, 'permE2' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.permE2, {'PermE2'}, iIterName );
                this.set('PermE2', dataMatrix);
            end
            
            if isfield( iStats, 'permE2' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.permE2, {'PermE2'}, iIterName );
                this.set('PermE2', dataMatrix);
            end
            
            if isfield( iStats, 'permVip' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.permVip, {'PermVip'}, iIterName );
                this.set('PermVip', dataMatrix);
            end
            
            if isfield( iStats, 'ClassSep' )
                dataMatrix = biotracs.data.model.DataMatrix( iStats.ClassSep, iResponseNames, {'Normalized', 'Unnormalized'} );
                this.set('ClassSep', dataMatrix);
            end  
            
%             if isfield( iStats, 'classInfo' )
%                 n = length(iStats.classInfo);
%                 dataMatrixList = cell(n,1);
%                 for i=1:n
%                     info = iStats.classInfo{i};
%                     data = [ ...
%                         info.posMean; info.posStd; info.pos95; info.posT2; info.posLim; ...
%                         info.negMean; info.negStd; info.neg95; info.negT2; info.negLim; ...
%                         info.classSep; ...
%                         ];
%                     rowNames = {...
%                         'PositiveClassMean', 'PositiveClassStd', 'PositiveClassIC95', 'PositiveClassICT2', 'PositiveClassLimit', ...
%                         'NegativeClassMean', 'NegativeClassStd', 'NegativeClassIC95', 'NegativeClassICT2', 'NegativeClassLimit', ...
%                         'ClassSeparator', ...
%                         };
%                     dataMatrixList{i} = biotracs.data.model.DataMatrix( data, iResponseNames, rowNames );
%                 end
%                 dataTable = biotracs.data.model.DataTable(dataMatrixList, {'ClassInfoMatrix'}, iIterName);
%                 this.set('ClassInfo', dataTable);
%             end
%             
%             if isfield( iStats, 'CVClassInfo' )
%                 n = length(iStats.CVClassInfo);
%                 dataMatrixList = cell(n,1);
%                 for i=1:n
%                     info = iStats.CVClassInfo{i};
%                     data = [ ...
%                         info.posMean; info.posStd; info.pos95; info.posT2; info.posLim; ...
%                         info.negMean; info.negStd; info.neg95; info.negT2; info.negLim; ...
%                         info.classSep; ...
%                         ];
%                     rowNames = {...
%                         'PositiveClassMean', 'PositiveClassStd', 'PositiveClassIC95', 'PositiveClassICT2', 'PositiveClassLimit', ...
%                         'NegativeClassMean', 'NegativeClassStd', 'NegativeClassIC95', 'NegativeClassICT2', 'NegativeClassLimit', ...
%                         'ClassSeparator', ...
%                         };
%                     dataMatrixList{i} = biotracs.data.model.DataMatrix( data, iResponseNames, rowNames );
%                 end
%                 dataTable = biotracs.data.model.DataTable(dataMatrixList, {'ClassInfoMatrix'}, iIterName);
%                 this.set('CVClassInfo', dataTable);
%             end
            
        end

    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function [d] = doSetRQ2( this, RQ2, iResponseNames, iName )
            d = biotracs.data.model.DataMatrix( RQ2 );
            d.setRowNames('#');
            d.setColumnNames(iResponseNames);
            this.set(iName, d);
        end
        
    end
    
    
end
