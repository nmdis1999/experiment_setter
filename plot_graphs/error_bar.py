import matplotlib.pyplot as plt
import pandas as pd
import sys
import os
import glob

# get directory names from command-line arguments
csv_directory = sys.argv[1]
png_directory = sys.argv[2]

# get all csv files in the directory
csv_files = glob.glob(os.path.join(csv_directory, '*.csv'))

for file_name in csv_files:
    # read data from csv file
    data = pd.read_csv(file_name)

    # create a new figure
    plt.figure(figsize=(10, 8))

    colors = {'A':'blue', 'B':'red', 'C':'green'}
    color_i = [colors.get(k, 'black') for k in data['ids']]

    for pos, y, err, color in zip(data['versions'], data['means'], data['confidence_intervals'], color_i):
        plt.errorbar(pos, y, err, color=color, fmt='.')

    # rotate x labels for better visibility
    plt.xticks(rotation=90)

    # set title and labels
    plt.title('Clang Versions Benchmark')
    plt.xlabel('Clang Version')
    plt.ylabel('Mean with 99% Confidence Interval')

    # show the plot
    plt.tight_layout()

    # get the base name of the file (without extension)
    base_name = os.path.splitext(os.path.basename(file_name))[0]

    # create the directory if it doesn't exist
    os.makedirs(png_directory, exist_ok=True)

    # save the figure with the base name of the csv file appended to 'test'
    plt.savefig(os.path.join(png_directory, 'errorbar_{}.png'.format(base_name)))

