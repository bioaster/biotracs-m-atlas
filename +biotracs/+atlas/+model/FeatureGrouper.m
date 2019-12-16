% BIOASTER
%> @file		FeatureGrouper.m
%> @class		biotracs.atlas.model.FeatureGrouper
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef FeatureGrouper < biotracs.core.mvc.model.Process
    
    properties(Constant)
    end
    
    properties(Access = protected)
        featureGroupCalculator = 'biotracs.atlas.helper.FeatureGroupCalculator';
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FeatureGrouper()
            %#function biotracs.atlas.model.FeatureGrouperConfig biotracs.data.model.DataSet biotracs.spectra.data.model.IsoFeatureMap biotracs.data.model.DataMatrix biotracs.atlas.helper.FeatureGroupCalculator
            
            this@biotracs.core.mvc.model.Process();
            this.configType = 'biotracs.core.mvc.model.ProcessConfig';
            this.setDescription('Algorithm for feature grouping');
            
            this.addInputSpecs({...
                struct(...
                'name', 'DataSet',...
                'class', 'biotracs.data.model.DataSet' ...
                ),...
                struct(...
                'name', 'IsoFeatureMap',...
                'required', false, ...
                'class', 'biotracs.spectra.data.model.IsoFeatureMap' ...
                )...
                });
            
            this.addOutputSpecs({...
                struct(...
                'name', 'DataSet',...
                'class', 'biotracs.data.model.DataSet' ...
                ),...
                struct(...
                'name', 'RedundancyMatrix',...
                'class', 'biotracs.data.model.DataMatrix' ...
                )...
                struct(...
                'name', 'IsoFeatureMap',...
                'class', 'biotracs.spectra.data.model.IsoFeatureMap' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            dataSet = this.getInputPortData('DataSet');
            isoFeatureMap = this.getInputPortData('IsoFeatureMap'); 
            
            arg = this.config.getParamsAsCell();
            [ calculator ] = feval(this.featureGroupCalculator, dataSet, arg{:} );
                
            if hasEmptyData(isoFeatureMap)  
                [ isoFeatureSet, ~ ] = calculator.reduceDataSet();
                redundancyMatrix = calculator.redundancyMatrix();
                isoFeatureMap = calculator.getIsoFeatureMap();
            else
                [ isoFeatureSet, ~ ] = biotracs.atlas.helper.FeatureGroupCalculator.reduceDataSetUsingIsofeatureMap( dataSet, isoFeatureMap, arg{:} );
                isoFeatureMap = biotracs.spectra.data.model.IsoFeatureMap();
                redundancyMatrix = biotracs.data.model.DataMatrix();
            end

            if ~hasEmptyData(isoFeatureSet)
                isoFeatureSet.setLabel(dataSet.getLabel());                
                this.setOutputPortData('DataSet', isoFeatureSet);
                this.setOutputPortData('RedundancyMatrix', redundancyMatrix);
                this.setOutputPortData('IsoFeatureMap', isoFeatureMap);
            end
        end

    end
    
end