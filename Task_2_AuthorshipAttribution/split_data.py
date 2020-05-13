from numpy.random import default_rng
import pandas as pd
from sklearn.model_selection import StratifiedKFold

seed_value = 25
num_splits = 10
file_info_path = 'data/corpus/file_info.csv'
output_dir = 'data/corpus/'
clustering = False

rnd_generator = default_rng(seed=seed_value)
file_info = pd.read_csv(file_info_path, sep = '|')
cv = StratifiedKFold(n_splits=num_splits, shuffle=True, random_state=seed_value)
splits = cv.split(X=file_info.author, y=file_info.author) # X required, but not used
i = 0
for train_idx, test_idx in splits:
    rnd_generator.shuffle(train_idx) # prevent objects being ordered by class
    rnd_generator.shuffle(test_idx)
    if clustering: # only train (= larger part of) data, labels stored separately
        file_info.iloc[train_idx].drop(columns=['input_file', 'author']).to_csv(
            output_dir + 'split_clustering_data_' + str(seed_value + i) + '.csv',
            sep = '|', index=False, line_terminator='\n')
        file_info.iloc[train_idx].drop(columns=['input_file']).to_csv(
            output_dir + 'split_clustering_labels_' + str(seed_value + i) + '.csv',
            sep = '|', index=False, line_terminator='\n')
    else: # train and test data (for the latter, labels stored separately)
        file_info.iloc[train_idx].drop(columns='input_file').to_csv(
            output_dir + 'split_train_data_' + str(seed_value + i) + '.csv',
            sep = '|', index=False, line_terminator='\n')
        file_info.iloc[test_idx].drop(columns=['input_file', 'author']).to_csv(
            output_dir + 'split_test_data_' + str(seed_value + i) + '.csv',
            sep = '|', index=False, line_terminator='\n')
        file_info.iloc[test_idx].drop(columns=['input_file']).to_csv(
            output_dir + 'split_test_labels_' + str(seed_value + i) + '.csv',
            sep = '|', index=False, line_terminator='\n')
    i += 1
