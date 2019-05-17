% BIOASTER
%> @file		CovaLearner.m
%> @class		biotracs.atlas.model.CovaLearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef CovaLearner < biotracs.atlas.model.BaseLearner
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = CovaLearner()
            error('Not yet available');
            this@biotracs.atlas.model.BaseLearner();
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.BaseClustererResult' ...
                )...
            });
        
            % change the instrument configs
            % ...
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            % create instrument config
            method = this.config.getParamValue('Method');
            switch method
                case 'kmeans'
                    clustProcess = biotracs.atlas.model.KmeansLearner();
                case {'hca', 'hcca'}
                    clustProcess = biotracs.atlas.model.HCALearner();
                otherwise
                    error('Invalid methoid');
            end
            
            % set intrument config
            c = clustProcess.getConfig();
            c.hydrateWith( this.config );

            % create covariance matrix (pairwise column correlation)
            trSet = this.getInputPortData('TrainingSet');
            covSet = biotracs.data.model.DataSet(...     
                corr(trSet.getData()), ...
                trSet.getColumnNames(), ...
                trSet.getColumnNames() ...
            );

            % run process
            clustProcess.setInputPortData( 'TrainingSet', covSet );
            clustProcess.run();
            result = clustProcess.getOutputPortData('Result');
            result.discardProcess();
            
            % set output
            this.setOutputPortData( 'Result', result );
        end
        
        
        function doLearn( ~ )
        end
        
        function doLearnCv( ~ )
            %error('Not yet available for cova');
        end
        
        function doLearnPerm( ~ )
            %error('Not yet available for cova');
        end
        
    end
    
end
