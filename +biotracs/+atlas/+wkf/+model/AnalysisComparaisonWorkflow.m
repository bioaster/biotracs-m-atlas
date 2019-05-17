% BIOASTER
%> @file		AnalysisComparaisonWorkflow.m
%> @class		biotracs.atlas.model.AnalysisComparaisonWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2019

classdef AnalysisComparaisonWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
        workflow;
    end
    
    methods
        % Constructor
        function this = AnalysisComparaisonWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doAnalysisComparaisonWorkflow();
        end
    end
    
    methods(Access = protected)
        
        
        function this = doAnalysisComparaisonWorkflow( this )
            %Add FileImporter Ms feature
            dataSetImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( dataSetImporter, 'DataSetImporter' );
            
            %Add Parser
            
            
            % Add File Formating
            fileFormating = biotracs.atlas.model.FileFormating();
            this.addNode( fileFormating, 'FileFormating' );
            
            %Add TextExporter
            fileFormatingTextExporter =  biotracs.core.adapter.model.FileExporter();
            fileFormatingTextExporter.getConfig() ...
                .updateParamValue('FileExtension', '.csv');
            this.addNode( fileFormatingTextExporter, 'FileFormatingTextExporter' );
            
            %Add DiagVenn
            vennDiagram =  biotracs.dataproc.model.VennDiagram();
            this.addNode( vennDiagram, 'VennDiagram' );
            
            
            % Add Identification of Metabolites
            idMetabolites = biotracs.atlas.model.DiagVennMetabolitesIdentification();
            this.addNode(idMetabolites , 'MetabolitesIded') ;
            
            %Add TextExporter
            idMetabolitesTextExporter =  biotracs.core.adapter.model.FileExporter();
            idMetabolitesTextExporter.getConfig() ...
                .updateParamValue('FileExtension', '.csv');
            this.addNode( idMetabolitesTextExporter, 'IdMetabolitesTextExporter' );
            
            
            dataSetImporter.getOutputPort('DataFileSet').connectTo( fileFormating.getInputPort('DataFileSet') );
            fileFormating.getOutputPort('DataTable').connectTo( fileFormatingTextExporter.getInputPort('Resource'));

            fileFormatingTextExporter.getOutputPort('DataFileSet').connectTo( vennDiagram.getInputPort('DataFileSet'));
            vennDiagram.getOutputPort('DataFileSet').connectTo( idMetabolites.getInputPort('VennDiagDataFileSet') );
%             
            dataSetImporter.getOutputPort('DataFileSet').connectTo( idMetabolites.getInputPort('DataFileSet'));
            idMetabolites.getOutputPort('DataTable').connectTo( idMetabolitesTextExporter.getInputPort('Resource') );
            
            
        end
        
    end
end

