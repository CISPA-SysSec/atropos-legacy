#!/usr/bin/python

import os, sys, argparse
import glob, time
from tqdm import tqdm
from icecream import ic
#import matplotlib.pyplot as plt
#import termplotlib as tpl
import plotext as plt
from copy import deepcopy

SECOND = 1
MINUTE = 60*SECOND
HOUR = 60*MINUTE
DAY = 24*HOUR

def secondsToCaptionConfig(s):
  useDay = (s >= DAY)
  useHour = (s >= HOUR)
  useMinute = (s >= MINUTE)
  return (useDay, useHour, useMinute)

def secondsToCaption(s, config=None, accuracy=2):
  if config == None:
    config = secondsToCaptionConfig(s)
  (useDay, useHour, useMinute) = config
  caption = ""
  currentS = s
  if useDay:
    inDay = int(currentS / DAY)
    caption += "%02dd:" % inDay
    currentS = currentS % DAY
  if useHour:
    inHour = int(currentS / HOUR)
    caption += "%02dh:" % inHour
    currentS = currentS % HOUR
  if useMinute:
    inMinute = int(currentS / MINUTE)
    caption += "%02dm:" % inMinute
    currentS = currentS % MINUTE
  caption += "%02ds" % currentS
  if caption.count(':') >= accuracy:
    captionSplit = caption.split(':')
    caption = ':'.join(captionSplit[:accuracy])
  return caption

parser = argparse.ArgumentParser(description="", prog="plot.py")
parser.add_argument('--watch', '-w', dest="watch", help="Refresh output", action="store_true")
parser.add_argument('--sleep', '-s', dest="sleep", type=int, nargs='?', default=60)
parser.add_argument('--skip-time', dest="skip_time", help="skip the first x seconds of the plot (to see more changes)", type=int, nargs='?', default=0)
parser.add_argument('--file-filter', dest="file_filter", help="file filter")
args = parser.parse_args()

m = {}
plot_lines = {}
plot = {}
file_times = {}
base_time = None
previous_cumulative_data = set()
previous_cov_files = []

while True:
    if args.file_filter:
      file_filter = args.file_filter
    else:
      file_filter = "/dev/shm/rq/*.cov"
    ic(file_filter)
    cov_files = list(set(glob.glob(file_filter)) - set(previous_cov_files))
    
    if len(cov_files) == 0:
        if args.watch:
            time.sleep(args.sleep)
            continue
        else:
            print("no files in /dev/shm/rq/, waiting ...")
            break

    if args.watch:
        #os.system("clear")
        os.system("date")
        plt.clf()

    for cov_file in cov_files:
        with open(cov_file, "r") as f:
            m[cov_file] = set([x.strip() for x in f.readlines() if x.startswith("cov:")])

    relative_file_times = {f: int(os.path.getctime(f)) for f in cov_files}
    if base_time is None:
      base_time = min(relative_file_times.values())
    relative_file_times = {f: relative_file_times[f] - base_time for f in relative_file_times}
    file_times.update(relative_file_times)
    cumulative_data = deepcopy(previous_cumulative_data)
    for cov_file in sorted(cov_files, key=lambda x: file_times[x]):
        cumulative_data.update(m[cov_file])
        #plot_lines[file_times[cov_file]] = cumulative_data
        plot[file_times[cov_file]] = len(cumulative_data)

    plot_data = [(x,y) for (x,y) in sorted(plot.items(), key=lambda a: a[0]) if x >= args.skip_time]
    X = [x for (x,_) in plot_data]
    Y = [y for (_,y) in plot_data]

    new_cov = cumulative_data - previous_cumulative_data
    if len(new_cov) > 0:
      print("new coverage:")
      for c in sorted(list(new_cov)):
        print(c)
    previous_cumulative_data.update(cumulative_data)
    previous_cov_files.extend(cov_files)

    # generate plot ticks
    t = 0
    xticks = []
    xtickslabels = []
    max_x = max(X)
    if max_x == 0:
      if args.watch:
          time.sleep(args.sleep)
          continue
      else:
        print("max x is zero")
        break
    incrementBy = min(max_x // 6, 12*60*60)
    # if it's a weird number, transform it to the hour value (e.g. 1h:04m becomes 1h:00m)
    if incrementBy > 60*60 and (incrementBy % (60*60)) > 0:
        incrementBy -= (incrementBy % (60*60))
    while t <= max_x:
        xticks.append(t)
        xtickslabels.append(secondsToCaption(t, config=secondsToCaptionConfig(max_x)))
        t += incrementBy
    plt.xticks(xticks, xtickslabels)

    #plt = plt.figure()
    plt.plot(X, Y)
    plt.show()
    #plt.savefig('plot.html')
    if not args.watch:
        ic(plot_data)
        break
    time.sleep(args.sleep)