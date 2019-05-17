% BIOASTER
%> @file		AggregLearnerResult.m
%> @class		biotracs.atlas.view.AggregLearnerResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef AggregLearnerResult < biotracs.atlas.view.BaseLearnerResult
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AggregLearnerResult()
            this@biotracs.atlas.view.BaseLearnerResult()
        end
        
        function h = viewGraphHtml( this, varargin )
            p = inputParser();
			p.addParameter('WorkingDirectory', '', @ischar)
			p.parse(varargin{:});

            h = [];
            isofeatureMap = this.model.get('IsoFeatureMap');
            names = isofeatureMap.getVariableNames();
            n = length(names);
            
            nodes = struct('name', cell(1,n), 'group', cell(1,n));
            links = struct('source', cell(1,n), 'target', cell(1,n), 'value', cell(1,n));
            linkCpt = 1;
            %A = sparse(n,n);
            for i=1:n
                nodes(i).name = names{i};
                nodes(i).group = 1;
                indexes = isofeatureMap.data{i};
                for j=1:length(indexes)
                    if i == j, continue; end
                    links(linkCpt).source = i-1;
                    links(linkCpt).target = indexes(j)-1;
                    links(linkCpt).value = 1;
                    linkCpt = linkCpt+1;
                    %A(i,j) = 1;
                    %A(j,i) = 1;
                end
            end
            graph = struct('type','pathway', 'nodes', nodes, 'links', links);
            jsonText = jsonencode(graph);

            wd = '';
			if ~this.model.getProcess().isNil() && isempty( p.Results.WorkingDirectory )
				wd = this.model.getProcess()...
					.getConfig()...
					.getParamValue('WorkingDirectory');
			else
				wd = fullfile(p.Results.WorkingDirectory);
            end
            
            if isempty(wd)
				wd = biotracs.core.env.Env.tempFolderPath();
            end
            
            if ~isfolder(wd) && ~mkdir(wd)
				error('SPECTRA:DataTable:DiskAccessRestriction', 'The working dorectory does not exist and cannot be created. Please check disk access rights');
            end
				
            div = biotracs.core.html.Div();
            div.addClass('bioviz-container');
            
            scriptText = [...
                '$(document).ready(function(){ ', ...
                '$(".bioviz-container").height("600px"); ', ...
                'var jsonGraph = ', jsonText, '; ', ...
                'var p = new bioviz.Pathway(''',div.uid,'''); p.viewJsonGraph( jsonGraph ); ', ...
                '})'...
                ];
            script = biotracs.core.html.Script(scriptText);
            website = biotracs.core.html.Website();
            doc = website.getIndexDoc();
            doc.append(div)...
                .append( script );
            website.setBaseDirectory( wd );
            website.generateHtml();
            %website.show();
        end
        
    end
end
