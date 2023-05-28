import pandas as pd
import sys
import os
import math
import glob

# get directory name from command-line arguments
directory_name = sys.argv[1]

# get all csv files in the directory
csv_files = glob.glob(os.path.join(directory_name, '*.csv'))

for file_name in csv_files:
    # read data from csv file
    data = pd.read_csv(file_name)

    # calculate 99% confidence intervals
    data['confidence_intervals'] = data['std_dev'] * 2.576 / math.sqrt(100)

    # drop the standard_deviations column
    data = data.drop(columns=['std_dev'])

    # get the base name of the file (without extension)
    base_name = os.path.splitext(os.path.basename(file_name))[0]

    # specify the directory where you want to save the new csv files
    # use 'csv_files' to represent the new directory within the current directory
    output_directory = "csv_files"

    # create the directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)

    # save the data to a new csv file in the specified directory
    data.to_csv(os.path.join(output_directory, '{}_ci.csv'.format(base_name)), index=False)

