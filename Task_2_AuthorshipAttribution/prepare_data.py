import glob
import os
import shutil

import pandas

input_dir = 'C:/MyData/Corpus_raw/'  # place it high in file hierarchy, or some files might not be copied (file names are very long)
output_dir = 'data/corpus/'

# Prepare input and output
if not os.path.isdir(input_dir):
    raise FileNotFoundError('The input directory does not exist.')
input_file_paths = glob.glob(input_dir + "**", recursive=True)
input_file_paths = [file for file in input_file_paths if os.path.isfile(file)]
if len(input_file_paths) == 0:
    raise FileNotFoundError('The input directory does not contain any files.')
if not os.path.isdir(output_dir):
    os.mkdir(output_dir)
old_output_files = os.listdir(output_dir)  # assumes that there are no dirs
for old_output_file in old_output_files:
    os.remove(output_dir + old_output_file)

# Process and store meta-data
digits = len(str(len(input_file_paths)))  # same length to ease sorting
file_info = []
for i in range(len(input_file_paths)):
    input_file = os.path.basename(input_file_paths[i])
    author = input_file.split('_')[0]
    output_file = 'text_' + str(i).rjust(digits, '0') + '.txt'  # leading zeros
    file_info.append({'input_file': input_file, 'output_file': output_file,
                      'author': author})
    shutil.copyfile(input_file_paths[i], output_dir + output_file)
file_info = pandas.DataFrame(file_info)
file_info.to_csv(output_dir + 'file_info.csv', sep='|', index=False, line_terminator='\n')
