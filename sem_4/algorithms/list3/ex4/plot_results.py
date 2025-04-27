import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("results.csv")

# Usuń wartości odstające z czasów (np. wartości powyżej 95 percentyla)
def remove_outliers(series, percentile=95):
    threshold = np.percentile(series, percentile)
    return series.where(series <= threshold)

scenarios = df['scenario'].unique()
results = []

for scenario in scenarios:
    data = df[df['scenario'] == scenario].copy()

    x = np.log(data['n'])
    y_comp = data['comparisons']
    y_time = remove_outliers(data['time_microsec'])  # oczyszczony czas
    # y_time = data['time_microsec'] 


    # usunięcie NaN po filtrze odstających
    mask = ~y_time.isna()
    x_filtered = x[mask]
    y_time_filtered = y_time[mask]

    # Estymacja współczynników
    c_comp, _ = np.polyfit(x, y_comp, 1)
    c_time, _ = np.polyfit(x_filtered, y_time_filtered, 1)

    results.append({
        'scenario': scenario,
        'c_comp': round(c_comp, 3),
        'c_time': round(c_time, 3)
    })

df_factors = pd.DataFrame(results)
print(df_factors)

# Wykresy: liczba porównań
plt.figure(figsize=(10, 6))
for scenario in scenarios:
    data = df[df['scenario'] == scenario]
    plt.plot(np.log(data['n']), data['comparisons'], label=scenario)
plt.xlabel('ln(n)')
plt.ylabel('comparisons')
plt.title('Number of Comparisons vs ln(n)')
plt.legend()
plt.grid(True)
plt.savefig("comparisons_vs_ln_n.png")
plt.show()

# Wykresy: czas po usunięciu wartości odstających
plt.figure(figsize=(10, 6))
for scenario in scenarios:
    data = df[df['scenario'] == scenario].copy()
    # y_time = data['time_microsec']
    y_time = remove_outliers(data['time_microsec'])
    plt.plot(np.log(data['n']), y_time, label=scenario)
plt.xlabel('ln(n)')
plt.ylabel('time (microseconds)')
plt.title('Execution Time vs ln(n)')
plt.legend()
plt.grid(True)
plt.savefig("time_vs_ln_n.png")
plt.show()




# import pandas as pd
# import matplotlib.pyplot as plt
# import numpy as np

# df = pd.read_csv("results.csv")

# # Oszacowanie O(1) współczynnika dla liczby porównań i czasu
# scenarios = df['scenario'].unique()
# results = []

# for scenario in scenarios:
#     data = df[df['scenario'] == scenario]
#     x = np.log2(data['n'])
#     y_comp = data['comparisons']
#     y_time = data['time_microsec']

#     c_comp, _ = np.polyfit(x, y_comp, 1)
#     c_time, _ = np.polyfit(x, y_time, 1)

#     results.append({
#         'scenario': scenario,
#         'c_comp': round(c_comp, 3),
#         'c_time': round(c_time, 3)
#     })

# df_factors = pd.DataFrame(results)
# print(df_factors)

# # Wykresy
# for metric in ['comparisons', 'time_microsec']:
#     plt.figure(figsize=(10, 6))
#     for scenario in scenarios:
#         data = df[df['scenario'] == scenario]
#         plt.plot(np.log2(data['n']), data[metric], label=scenario)
#     plt.xlabel('log2(n)')
#     plt.ylabel(metric)
#     plt.title(f'{metric.capitalize()} vs log2(n)')
#     plt.legend()
#     plt.grid(True)
#     plt.savefig("plots")
#     plt.show()
