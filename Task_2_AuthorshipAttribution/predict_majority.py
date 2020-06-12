import glob
import pandas as pd
import re

input_dir = 'data/corpus/'
output_dir = 'data/corpus/'

for test_file in glob.glob(input_dir + 'split_test_data_[0-9][0-9]*.csv'):
    # Read in
    train_file = test_file.replace('test', 'train')
    train_file_info = pd.read_csv(train_file, sep='|')
    test_file_info = pd.read_csv(test_file, sep='|')
    id_string = re.search('([0-9]+)\\.csv', train_file).group()

    # Determine majority class
    majority_class = train_file_info.groupby('author').agg('size').idxmax()

    # Write output
    test_file_info['author'] = majority_class
    test_file_info.to_csv(output_dir + 'prediction_' + id_string + '.csv',\
        sep = '|', index=False, line_terminator='\n')
