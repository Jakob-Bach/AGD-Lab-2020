import csv
import pandas as pd
from pathlib import Path
from sklearn.metrics import matthews_corrcoef
import re

truth_dir = Path('data/corpus/')
prediction_dir = Path('data/corpus/')

# Check existence of files
if not truth_dir.is_dir():
    raise FileNotFoundError('The directory with the ground truth files does not exist.')
if not prediction_dir.is_dir():
    raise FileNotFoundError('The directory with the prediction files does not exist.')
truth_file_paths = list(truth_dir.glob('split_test_labels_[0-9][0-9]*.csv'))
prediction_file_paths = list(prediction_dir.glob('prediction_[0-9][0-9]*.csv'))
if len(truth_file_paths) == 0:
    raise FileNotFoundError('No ground truth files.')
if len(prediction_file_paths) == 0:
    raise FileNotFoundError('No prediction files.')
if len(prediction_file_paths) != len(truth_file_paths):
    raise FileNotFoundError('Number of prediction and ground truth files differ.')

# Scoring
scores = []
for truth_file_path in truth_file_paths:
    id_string = re.search('([0-9]+)\\.csv', str(truth_file_path)).group(1)
    prediction_file_path = prediction_dir.joinpath('prediction_' + id_string + '.csv')
    if prediction_file_path not in prediction_file_paths:
        raise FileNotFoundError('No matching prediction file for "' + id_string + '".')
    truth_data = pd.read_csv(truth_file_path, sep='|', quoting=csv.QUOTE_NONE)
    prediction_data = pd.read_csv(prediction_file_path, sep='|')
    if prediction_data.shape[0] != truth_data.shape[0]:
        raise ValueError('Number of observations wrong.')
    if prediction_data.shape[1] != truth_data.shape[1]:
        raise ValueError('Number of columns wrong (index column might be saved).')
    if list(prediction_data) != list(truth_data):
        raise ValueError('Column name wrong (might be quoted).')
    merged = truth_data.merge(prediction_data, on='output_file')
    scores.append(matthews_corrcoef(y_true=merged.author_x, y_pred=merged.author_y))
print(round(sum(scores) / len(scores), 3))
