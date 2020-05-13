# Supervisor Repo for AGD Lab 2020

## Task 1: Pump it Up

We solve the challenge [Pump it Up: Data Mining the Water Table](https://www.drivendata.org/competitions/7/pump-it-up-data-mining-the-water-table).
It is an imbalanced three-class problem, scored by accuracy.
Most features are categorical.
The given train:test ratio is 80:20.

### Setup

We use R version `3.6.3`.
Required R packages: `data.table`, `xgboost`

### Data Preparation

To use our code, download the data, name the relevant files `train_data.csv`, `test_data.csv`, `test_labels.csv`
(no need to store the 4th file, which demonstrates the submission format)
and place them in a folder `data/` within this repo.

### Data Exploration

If you have followed the instructions above, you can directly run `ExploreData.R`.

### Internal Scoring

For scoring within the course, we use one or several data splits which are unknown to the students.
Their task is to write a pipeline which can process any number of train and test files, following our naming conventions.
`SplitForStudentsRepeatedHoldout.R` creates the splits.
`ScoreStudents.R` reads in the submissions and computes the official score (which is accuracy, unfortunately -- we could change that).

### Demo Submissions

We have submission scripts which comply to the input format and the submission format of the course.
By changing the naming pattern of the input and output files, the scripts can also be used to create submissions for the challenge itself.

- `CreateSubmission_Majority.R` is a baseline: It predicts the most frequent class from the train data.
- `CreateSubmission_xgboost.R` is a more competitive solution. It uses `xgboost` without any hyper-parameter tuning. Also, there is no feature engineering. We have to do some minimal pre-processing, as the one-hot-encoding of the categories or the training procedure afterwards have problems with the following points:
  - NA values
  - categorical features which have too many categories
  - different categories in training and test data for some features

## Task 2: Authorship Attribution

We try to find the author for works written by John Stuart Mill, Harriet Taylor Mill or both of them together.
For this purpose, we use a corpus of their complete works.
This problem also is rather imbalanced, most works being written by John Stuart Mill alone.
The problem can be posed as a clustering or a classification challenge.

### Setup

We use Python version `3.8.2` and `Anaconda 3 2019.10`/`conda 4.8.3` for package management.
For reproducibility purposes, we exported our environment with `conda env export > environment.yml`.
You should be able to import the environment via `conda env create -f environment.yml`
and the activate it with `conda activate agdlab_20`.
After activating, call `ipython kernel install --user --name=agdlab_20` to make the environment available in `Jupyter`.

### Data Preparation

To use our code, obtain the corpus with its three sub-directories (for the three author types).
`prepare_data.py` creates a copy of the corpus in which all information is stripped from the file names.
This also has the advantage of shortening the file names, which contain author, date and complete title otherwise
(with some variability in the naming pattern).
Furthermore, the Python script create a info file containing the input-output name mapping as well as the class labels.
To use the script on your computer, you have to adapt the input and output path manually.

### Data Exploration

`Playground.ipynb` demonstrates several analysis steps like:

- checking the class distribution in the meta-data
- computing a count/term-frequency matrix for the documents
- analyzing the impact of a parameter in the matrix creation
- using dimensionality reduction to visualize the matrix
- classification
- clustering

### Classification Scoring

For scoring, we again use splits which are unknown to the students.
As for task 1, the students need to write a pipeline which can process any number of train and test files,
following our naming conventions.
`split_data.py` creates the splits with stratified k-fold cross-validation.
We only store the meta-data -- file name and author for train, just the file name for test.
`score_classification.py` reads in the submissions and computes (multi-class) MCC.

### Demo Submissions

We provide two submission scripts which comply to the I/O format of the course.

- `predict_majority.py` is a baseline: It predicts the most frequent class from the train data.
- `predict_xgboost.py` uses `xgboost` on the (relative) term-frequency matrix. No tuning of the pre-processing or training.

### R Code (Legacy)

- `PrepareData.R` does some first pre-processing, though only on the file path/name level.
- `ExploreData.R` converts the text to a frequency representation (`stylo`) and runs a demo classification (`xgboost`) and clustering (`stats::hclust`).

We use R version `3.6.3`.
Required R packages: `data.table`, `stylo`, `xgboost`
