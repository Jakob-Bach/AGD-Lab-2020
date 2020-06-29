import glob
import pandas as pd
import re
from sklearn.cluster import AgglomerativeClustering
from sklearn.feature_extraction.text import TfidfVectorizer

input_dir = 'data/corpus/'
corpus_dir = 'data/corpus/'
output_dir = 'data/corpus/'

for data_file in glob.glob(input_dir + 'split_clustering_data_[0-9][0-9]*.csv'):
    # Read in
    file_info = pd.read_csv(data_file, sep='|')
    id_string = re.search('[0-9]+', data_file).group()

    # Engineer features
    vectorizer = TfidfVectorizer(input='filename', use_idf=False, norm='l1')
    texts = [corpus_dir + x for x in file_info.output_file]
    X = vectorizer.fit_transform(texts)

    # Train model and implictly label objects
    model = AgglomerativeClustering(n_clusters=3, affinity='cosine', linkage='average')
    model.fit(X=X.toarray())

    # Write output
    file_info['author'] = model.labels_
    file_info.to_csv(output_dir + 'clustering_' + id_string + '.csv',
                     sep='|', index=False, line_terminator='\n')
