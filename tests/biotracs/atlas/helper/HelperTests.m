classdef HelperTests < matlab.unittest.TestCase

    methods (Test)
        
        function testHelper(testCase)
            %groupNames = {'A','B','C'};
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            
            testCase.verifyEqual( Ce{1}, [4, 0; 0, 9] );
            testCase.verifyEqual( Ce{2}, [4, 0; 0, 9] );
            testCase.verifyEqual( Ce{3}, [5, 0; 0, 8] );
            testCase.verifyEqual( C, [4, 0, 0; 0, 4, 0; 0, 0, 5] );
            testCase.verifyEqual( E2, [0, 0, 0] );
            
            expectedC = confusionmat(knownGroups,cell2mat(predGroups));
            testCase.verifyEqual( C, expectedC );
            
            % -------------------------------------------------------------
            
            %groupNames = {'A','B','C'};
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {1, 2, 1, 1, 2, 1, 1, 2, 3, 3, 2, 3, 3};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [3, 2; 1, 7] );
            testCase.verifyEqual( Ce{2}, [2, 2; 2, 7] );
            testCase.verifyEqual( Ce{3}, [4, 0; 1, 8] );
            testCase.verifyEqual( C, [3, 1, 0; 2, 2, 0; 0, 1, 4] );
            testCase.verifyEqual( E2, [0.472222222222222   0.722222222222222   0.200000000000000]/2, 'RelTol', 1e-6 );
            
            expectedC = confusionmat(knownGroups,cell2mat(predGroups));
            testCase.verifyEqual( C, expectedC );
            
            %--------------------------------------------------------------
            
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {[1,2], 1, 1, 1, 2, 2, 2, 2, 3, [3, 2], [1,3], 3, 3};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [4, 1; 1, 9] );
            testCase.verifyEqual( Ce{2}, [4, 2; 0, 9] );
            testCase.verifyEqual( Ce{3}, [5, 0; 2, 8] );
            testCase.verifyEqual( C, [4, 1, 0; 0, 4, 0; 1, 1, 5] );
            testCase.verifyEqual( E2, [0.300000000000000   0.181818181818182   0.285714285714286]/2, 'RelTol', 1e-6 );
            
            %--------------------------------------------------------------
            
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {nan, 1, 1, 1, 2, 2, 2, 2, 3, nan, nan, 3, 3};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [3, 0; 0, 7] );
            testCase.verifyEqual( Ce{2}, [4, 0; 0, 6] );
            testCase.verifyEqual( Ce{3}, [3, 0; 0, 7] );
            testCase.verifyEqual( C, [3, 0, 0; 0, 4, 0; 0, 0, 3] );
            testCase.verifyEqual( E2, [0, 0, 0], 'RelTol', 1e-6 );

            expectedC = confusionmat(knownGroups,cell2mat(predGroups));
            testCase.verifyEqual( C, expectedC );
            
            %--------------------------------------------------------------
            
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {2, 1, 1, 1, 2, [3,1], 2, 2, 3, [3, 2], [1,3], 3, 3};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [3, 2; 1, 9] );
            testCase.verifyEqual( Ce{2}, [3, 2; 1, 8] );
            testCase.verifyEqual( Ce{3}, [5, 1; 2, 8] );
            testCase.verifyEqual( C, [3, 1, 0; 1, 3, 1; 1, 1, 5] );
            testCase.verifyEqual( E2, [0.431818181818182   0.450000000000000   0.396825396825397]/2, 'RelTol', 1e-6 ); 
            
            %--------------------------------------------------------------
            
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {nan, nan, nan, nan, nan, nan, nan, nan, nan, 2, 2, 2, 2};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [0, 0; 0, 4] );
            testCase.verifyEqual( Ce{2}, [0, 4; 0, 0] );
            testCase.verifyEqual( Ce{3}, [0, 0; 4, 0] );
            testCase.verifyEqual( C, [0, 0, 0; 0, 0, 0; 0, 4, 0] );
            testCase.verifyEqual( E2, [nan, nan, nan], 'RelTol', 1e-6 ); 
            
            expectedC = confusionmat(knownGroups,cell2mat(predGroups));
            testCase.verifyEqual( C, expectedC );
            
            %--------------------------------------------------------------
            % NaN means that the membsership group is undefined
            % Error are undefined in any cases
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {nan, nan, nan, nan, nan, nan, nan, nan, nan, nan, nan, nan, nan};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [0, 0; 0, 0] );
            testCase.verifyEqual( Ce{2}, [0, 0; 0, 0] );
            testCase.verifyEqual( Ce{3}, [0, 0; 0, 0] );
            testCase.verifyEqual( C, [0, 0, 0; 0, 0, 0; 0, 0, 0] );
            testCase.verifyEqual( E2, [nan, nan, nan], 'RelTol', 1e-6 ); 
            
            expectedC = confusionmat(knownGroups,cell2mat(predGroups));
            testCase.verifyEqual( C, expectedC );
            
            %--------------------------------------------------------------
            % [] is the "exclusive" negative membership flag, i.e. means that
            % it is negative group with respect to the current group
            knownGroups = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];
            predGroups  = {[], [], [], [], [], [], [], [], [], [], [], [], []};
            [ E2, C, Ce ] = biotracs.atlas.helper.Helper.computeClassificationStats( knownGroups, predGroups );
            testCase.verifyEqual( Ce{1}, [0, 0; 4, 9] );
            testCase.verifyEqual( Ce{2}, [0, 0; 4, 9] );
            testCase.verifyEqual( Ce{3}, [0, 0; 5, 8] );
            
            %conventional confusion matrix  return undefined results
            testCase.verifyEqual( C, [0, 0, 0; 0, 0, 0; 0, 0, 0] );
            
            %the exclusive squared error is maximal
            testCase.verifyEqual( E2, [1, 1, 1]/2, 'RelTol', 1e-6 ); 
        end
  
    end
    
end
