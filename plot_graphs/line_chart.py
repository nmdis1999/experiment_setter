import matplotlib.pyplot as plt
import numpy as np
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

    profiles = data['profiles'].unique().tolist()
    mode = data['mode'].unique().tolist()

    means = data.pivot(index='mode', columns='profiles', values='means').values.tolist()
    ci = data.pivot(index='mode', columns='profiles', values='confidence_intervals').values.tolist()

    plt.figure(figsize=(6, 5))

    for i in range(len(mode)):
        plt.plot(profiles, means[i], '-.', label=mode[i])
        plt.fill_between(profiles, np.array(means[i]) + np.array(ci[i]), np.array(means[i]) - np.array(ci[i]), alpha=0.25)

    plt.title('Clang Versions Benchmark')
    plt.xlabel('Clang Version')
    plt.ylabel('Mean with 99% Confidence Interval')

    plt.legend()

    plt.tight_layout()

    # get the base name of the file (without extension)
    base_name = os.path.splitext(os.path.basename(file_name))[0]

    # create the directory if it doesn't exist
    os.makedirs(png_directory, exist_ok=True)

    # save the figure with the base name of the csv file appended to 'test'
    plt.savefig(os.path.join(png_directory, 'errorbar_{}.png'.format(base_name)))

