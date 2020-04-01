# Supervisor Playground

## Task 1: Pump it Up

We solve the challenge [Pump it Up: Data Mining the Water Table](https://www.drivendata.org/competitions/7/pump-it-up-data-mining-the-water-table).
It is an imbalanced three-class problem, scored by accuracy.
Most features are categorical.
The given train:test ratio is 80:20.
To use our code, download the data, name the relevant files `train_data.csv`, `test_data.csv`, `test_labels.csv`
(no need to store the 4th file, which demonstrates the submission format)
and place them in a folder `data/` within this repo.

Required packages: `data.table`, `xgboost`

## Task 2: Authorship Attribution

We try to find the author for works written by John Stuart Mill, Harriet Taylor Mill or both of them together.
For this purpose, we use a corpus of their complete works.
This problem also is rather imbalanced, most works being written by John Stuart Mill alone.
The problem can be posed as a clustering or a classification challenge.
To use our code, obtain the corpus with its three sub-directories (for the three author types).
`PrepareData.R` does some first pre-processing, though only on the file path/name level.

Required packages: `data.table`, `stylo`
