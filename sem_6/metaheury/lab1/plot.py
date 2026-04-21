import random
import matplotlib.pyplot as plt
import os

def readFile(filename):
    coords = []
    cost = 0
    with open(filename) as f:
        cost = int(f.readline())
        for line in f:
            line_split = line.split()
            coords.append((float(line_split[0]), float(line_split[1])))

    return cost, coords

def plot_path(path, min, filename):
    x = [p[0] for p in path]
    y = [p[1] for p in path]

    x.append(path[0][0])
    y.append(path[0][1])

    plt.figure(figsize=(10,6))
    plt.plot(x, y, 'ro-', markersize=2)
    plt.title(f"Znaleziony cykl ma długość {min}")
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.savefig("plots/" + filename + ".png")

data_dir = os.path.join(os.path.dirname(__file__), 'dataSol')
files = os.listdir(data_dir)
print(f"no. files: {len(files)}\n")

file = "dj38.sol"
for file in files:
    cost, coords = readFile("dataSol/"+file)
    plot_path(coords, cost, file.split(".")[0])
    print(f"{file}")