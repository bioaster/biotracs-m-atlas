%"""
%Unit tests for biotracs.atlas.*
%* License: BIOASTER License
%* Created: Oct. 2014
%Bioinformatics team, Omics Hub, BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""
function testAtlas( cleanAll )
    if nargin == 0 || cleanAll
        clc; close all force;
        restoredefaultpath();
    end
    
    addpath('../../')
    autoload( ...
        'PkgPaths', {fullfile(pwd, '../../../../')}, ...
        'Dependencies', {...
            'biotracs-m-atlas', ...
        }, ...
        'Variables',  struct(...
            'RExecutableFilePath', '%USER_DIR%/Documents/R/R-3.3.3/bin/Rscript.exe', ...
            'VennDiagramFilePath', '%BIOTRACS_M_ATLAS_DIR%/externs/r/VennDiagram/venn.R' ...
        ) ...
    );

    %% Tests
    import matlab.unittest.TestSuite;
    %Tests = TestSuite.fromFolder('./', 'IncludingSubfolders', true);
    
    Tests = TestSuite.fromFile('./helper/HelperTests.m');
    
    %Tests = TestSuite.fromFile('./model/AggregLearnerTests.m');
    %Tests = TestSuite.fromFile('./model/CovaLearnerTests.m');
    %Tests = TestSuite.fromFile('./model/DiffProcessTests.m');
    %Tests = TestSuite.fromFile('./model/HCALearnerTests.m');
    %Tests = TestSuite.fromFile('./model/KmeansLearnerTests.m');
    %Tests = TestSuite.fromFile('./model/LarsenTests.m');
    %Tests = TestSuite.fromFile('./model/ModelSelectorTests.m');
    %Tests = TestSuite.fromFile('./model/PartialDiffProcessTests.m');
    %Tests = TestSuite.fromFile('./model/PCALearnerTests.m');
    %Tests = TestSuite.fromFile('./model/PermutationTests.m');
    %Tests = TestSuite.fromFile('./model/PLSDATests.m');
    %Tests = TestSuite.fromFile('./model/PLSRTests.m');
    %Tests = TestSuite.fromFile('./model/PoolLearnerTests.m');
    %Tests = TestSuite.fromFile('./model/PoolPredictorTests.m');
    %Tests = TestSuite.fromFile('./model/SldaTests.m');
    
    Tests = TestSuite.fromFile('./model/VennDiagramTests.m');
    
    %Tests = TestSuite.fromFile('./model/GenericMLWorkflowTests.m');
    
    Tests.run;
end