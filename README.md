# Supervisor Playground

We solve the challenge [Pump it Up: Data Mining the Water Table](https://www.drivendata.org/competitions/7/pump-it-up-data-mining-the-water-table).
It is an imbalanced three-class problem, scored by accuracy.
Most features are categorical.
The train:test ratio is 80:20.
To use our code, download the data, name the relevant files `train_data.csv`, `test_data.csv`, `test_labels.csv`
(no need to store the 4th file, which demonstrates the submission format)
and place them in a folder `data/` within this repo.

Required packages: `data.table`, `xgboost`
