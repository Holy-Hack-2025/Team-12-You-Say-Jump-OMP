import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# Load data
data_dir = os.path.join(os.path.dirname(__file__), "../data")
csv_path = os.path.join(data_dir, "generated_data.csv")
data = pd.read_csv(csv_path)

# Extract columns
x_values, y_values, k_values, z_values = data["x"], data["y"], data["x"], data["z"]

# Plot x vs y
plt.figure(figsize=(10, 5))
plt.scatter(x_values, y_values, alpha=0.2, s=5, label="Generated Data")
plt.axvline(x=4, linestyle="--", color="red", label="Mirror Axis (x=4)")
plt.xlabel("x")
plt.ylabel("y")
plt.title("Generated Data with Gradual Increase in Variability for x > 6")
plt.legend()
plt.show()

# Plot x vs z
plt.figure(figsize=(10, 5))
plt.scatter(x_values, z_values, alpha=0.2, s=5, label="Generated Data")
plt.axvline(x=4, linestyle="--", color="red", label="Mirror Axis (x=4)")
plt.xlabel("x")
plt.ylabel("z")
plt.title("Generated Data with Gradual Increase in Variability for x > 6")
plt.legend()
plt.show()
