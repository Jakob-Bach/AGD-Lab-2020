import glob
import re

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import LabelEncoder
from tqdm import tqdm
import xgboost as xgb

input_dir = 'data/corpus/'
corpus_dir = 'data/corpus/'
output_dir = 'data/corpus/'

for test_file in tqdm(glob.glob(input_dir + 'split_test_data_[0-9][0-9]*.csv')):
    # Read in
    train_file = test_file.replace('test', 'train')
    train_file_info = pd.read_csv(train_file, sep='|')
    test_file_info = pd.read_csv(test_file, sep='|')
    id_string = re.search('([0-9]+)\\.csv', train_file).group(1)

    # Engineer features
    vectorizer = TfidfVectorizer(input='filename', use_idf=False, norm='l1')
    train_texts = [corpus_dir + x for x in train_file_info.output_file]
    test_texts = [corpus_dir + x for x in test_file_info.output_file]
    X_train = vectorizer.fit_transform(train_texts)
    X_test = vectorizer.transform(test_texts)

    # Encode output
    label_encoder = LabelEncoder()
    y_train = label_encoder.fit_transform(train_file_info.author)

    # Train model
    model = xgb.XGBClassifier(random_state=25, n_estimators=20)
    model.fit(X=X_train, y=y_train)

    # Predict
    pred_test = model.predict(X_test)

    # Write output
    test_file_info['author'] = label_encoder.inverse_transform(pred_test)
    test_file_info.to_csv(output_dir + 'prediction_' + id_string + '.csv',
                          sep='|', index=False, line_terminator='\n')
