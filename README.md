# Supervisor Repo for AGD Lab 2020

## Task 1: Pump it Up

We solve the challenge [Pump it Up: Data Mining the Water Table](https://www.drivendata.org/competitions/7/pump-it-up-data-mining-the-water-table).
It is an imbalanced three-class problem, scored by accuracy.
Most features are categorical.
The given train:test ratio is 80:20.

To use our code, download the data, name the relevant files `train_data.csv`, `test_data.csv`, `test_labels.csv`
(no need to store the 4th file, which demonstrates the submission format)
and place them in a folder `data/` within this repo.

Required R packages: `data.table`, `xgboost`

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
- `CreateSubmission_xgboost` is a more competitive solution. It uses `xgboost` without any hyper-parameter tuning. Also, there is no feature engineering. We have to do some minimal pre-processing, as the one-hot-encoding of the categories or the training procedure afterwards have problems with the following points:
  - NA values
  - categorical features which have too many categories
  - different categories in training and test data for some features

## Task 2: Authorship Attribution

We try to find the author for works written by John Stuart Mill, Harriet Taylor Mill or both of them together.
For this purpose, we use a corpus of their complete works.
This problem also is rather imbalanced, most works being written by John Stuart Mill alone.
The problem can be posed as a clustering or a classification challenge.
To use our code, obtain the corpus with its three sub-directories (for the three author types).
`PrepareData.R` does some first pre-processing, though only on the file path/name level.

Required R packages: `data.table`, `stylo`
