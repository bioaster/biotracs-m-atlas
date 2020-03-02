# BioTracs Atlas application

The `biotracs-m-atlas` application provides MATLAB libraries for data analysis using machine learning algorithms (unsupervised analysis, regression, classification, clustering, ...).

# Learn more about the BioTracs project

To learn more about the BioTracs project, please refers to https://github.com/bioaster/biotracs

# Usage

Please refer to the documentation at https://bioaster.github.io/biotracs/documentation

```matlab
% file main.m
% -----------------------------------------
addpath('/path/to/autoload.m');

% Load the biotracs framework
% pkgdir is the directory with containing all biotracs git repo are downloaded
autoload( ...
	'PkgPaths', {'/path/to/pkgdir'}, ...
	'Dependencies', {...
		'biotracs-m-atlas', ...
	}, ...
	'Variables',  struct(...
	) ...
);
	
% PCA analysis
pca = biotracs.atlas.model.PCALearner();

pca.getConfig()...
	.updateParamValue('NbComponents', 3)...
	.updateParamValue('Center', true)...
	.updateParamValue('Scale', 'uv')...
	.updateParamValue('WorkingDirectory', '/path/to/pca-working-directory/');

dataSet = biotracs.data.model.DataSet.import('/path/to/dataset.csv');
pca.setInputPortData('TrainingSet', dataSet);
pca.run();

pcaResult = process.getOutputPortData('result');

% View PCA score plot with cluster contours
pcaResult.view(...
	'ScorePlot', ...
	'NbComponents', 2 ...
	);
scoreDataSet = pcaResult.getXScores().summary();

% Kmeans clustering in the PCA score plot
kmeans = biotracs.atlas.model.KmeansLearner();
kmeans.getConfig()...
	.updateParamValue('Center', false)...
	.updateParamValue('Scale', 'none')...
	.updateParamValue('MaxNbClusters', 2)...
	.updateParamValue('Method', 'kmeans')...
	.updateParamValue('WorkingDirectory', '/path/to/kmeans-working-directory/');

kmeans.setInputPortData('TrainingSet', scoreDataSet);
kmeans.run();
kmeansResults = kmeans.getOutputPortData('Result');

% View PCA score plot with cluster contours
pcaResult.view(...
	'ScorePlot', ...
	'ClusteringResult', kmeansResults, ...
	'NbDimensions', 2 ...
	);
				
```

# Dependencies

BioTracs modules only rely on MATLAB software. 

The other biotracs-modules that `biotracs-atlas` relies on are given in the file `packages.json`. Please recursively download these depdencies in the same directory where `biotracs-atlas` module is located. All these modules are provided on github.

# License

BIOASTER license https://github.com/bioaster/biotracs/blob/master/LICENSE
