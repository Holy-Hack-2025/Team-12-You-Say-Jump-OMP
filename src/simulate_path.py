import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Parameters for the simulation
S0 = 2000  # Initial price of the commodity (aluminum) in USD per ton
r = 0.05  # Drift (expected return) of the commodity price
sigma = 0.2  # Volatility (standard deviation of returns)
T = 1  # Time horizon in years
dt = 1/252  # Daily time step (assuming 252 trading days in a year)
N = int(T / dt)  # Number of steps (time points)
simulations = 1000  # Number of Monte Carlo simulations

# Monte Carlo Simulation function
def monte_carlo_simulation(S0, r, sigma, T, dt, N, simulations):
    # Initialize the array to store all the price paths
    paths = np.zeros((simulations, N))
    paths[:, 0] = S0
    
    # Run the simulations
    for i in range(simulations):
        for t in range(1, N):
            Z_t = np.random.normal(0, 1)  # Standard normal random variable
            # GBM price evolution formula
            paths[i, t] = paths[i, t-1] * np.exp((r - 0.5 * sigma**2) * dt + sigma * np.sqrt(dt) * Z_t)
    
    return paths

# Generate the price paths
paths = monte_carlo_simulation(S0, r, sigma, T, dt, N, simulations)

# Extract the final prices for the density plot
final_prices = paths[:, -1]

# Create the figure and axes for the two subplots (price paths and density)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot the simulated price paths
ax1.plot(paths.T, color='blue', alpha=0.1)  # Light blue for each simulation
ax1.set_title(f'Monte Carlo Simulation of Commodity Price Path - {simulations} Paths')
ax1.set_xlabel('Time (Days)')
ax1.set_ylabel('Price (USD)')

# Plot the density of the final prices
sns.kdeplot(final_prices, ax=ax2, color='green', shade=True)
ax2.set_title('Density of Final Prices')
ax2.set_xlabel('Price (USD)')
ax2.set_ylabel('Density')

# Show the plot
plt.tight_layout()
plt.show()
