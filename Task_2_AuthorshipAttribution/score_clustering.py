import csv
import pandas as pd
from pathlib import Path
import re
from sklearn.metrics import normalized_mutual_info_score

truth_dir = Path('data/corpus/')
clustering_dir = Path('data/corpus/')

# Check existence of files
if not truth_dir.is_dir():
    raise FileNotFoundError('The directory with the ground truth files does not exist.')
if not clustering_dir.is_dir():
    raise FileNotFoundError('The directory with the clustering files does not exist.')
truth_file_paths = list(truth_dir.glob('split_clustering_labels_[0-9][0-9]*.csv'))
clustering_file_paths = list(clustering_dir.glob('clustering_[0-9][0-9]*.csv'))
if len(truth_file_paths) == 0:
    raise FileNotFoundError('No ground truth files.')
if len(clustering_file_paths) == 0:
    raise FileNotFoundError('No clustering files.')
if len(clustering_file_paths) != len(truth_file_paths):
    raise FileNotFoundError('Number of clustering and ground truth files differ.')

# Scoring
scores = []
for truth_file_path in truth_file_paths:
    id_string = re.search('([0-9]+)\\.csv', str(truth_file_path)).group(1)
    clustering_file_path = clustering_dir.joinpath('clustering_' + id_string + '.csv')
    if clustering_file_path not in clustering_file_paths:
        raise FileNotFoundError('No matching clustering file for "' + id_string + '".')
    truth_data = pd.read_csv(truth_file_path, sep='|', quoting=csv.QUOTE_NONE)
    clustering_data = pd.read_csv(clustering_file_path, sep='|')
    if clustering_data.shape[0] != truth_data.shape[0]:
        raise ValueError('Number of observations wrong.')
    if clustering_data.shape[1] != truth_data.shape[1]:
        raise ValueError('Number of columns wrong (index column might be saved).')
    if list(clustering_data) != list(truth_data):
        raise ValueError('Column name wrong (might be quoted).')
    merged = truth_data.merge(clustering_data, on='output_file')
    scores.append(normalized_mutual_info_score(labels_true=merged.author_x, labels_pred=merged.author_y))
print(round(sum(scores) / len(scores), 3))
