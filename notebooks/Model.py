import numpy as np
import casadi as ca
import plotly.graph_objects as go

# User-defined inputs
x_lower = float(input("Enter lower bound for x: "))
x_upper = float(input("Enter upper bound for x: "))
y_lower = float(input("Enter lower bound for y: "))
y_upper = float(input("Enter upper bound for y: "))

initial_x = float(input("Enter initial guess for x: "))
initial_y = float(input("Enter initial guess for y: "))

# Validate initial guess
if not (x_lower <= initial_x <= x_upper):
    raise ValueError(f"Initial guess for x ({initial_x}) is out of bounds [{x_lower}, {x_upper}]")
if not (y_lower <= initial_y <= y_upper):
    raise ValueError(f"Initial guess for y ({initial_y}) is out of bounds [{y_lower}, {y_upper}]")

# Define the function in CasADi
x = ca.SX.sym("x")
y = ca.SX.sym("y")

# Rotate the minimum to a higher x value (shifted to x=7 instead of x=3)
x_rotated = 10 - x  # Rotation along a vertical axis

# Asymmetric quadratic function: different curvature in x and y
z = (x_rotated - 7)**2 + 1.5 * (y - 6)**2  # Minimum at (x=7, y=6)

# Add a sharper edge at the bottom
z += ca.exp(-0.8 * ((x_rotated - 7)**2 + (y - 6)**2)) * 4  

# Define the optimization problem
f = ca.Function("f", [x, y], [z])  # Define function

# Define optimization variables
opt_variables = ca.vertcat(x, y)

# Compute gradient (first derivative)
grad = ca.gradient(z, opt_variables)

# Compute Hessian (second derivative matrix)
hessian = ca.hessian(z, opt_variables)[0]

# Define solver using Newton's method with bounds
solver = ca.nlpsol("solver", "ipopt", {
    "x": opt_variables,
    "f": z,
    "g": grad
})

# Initial guess
initial_guess = [initial_x, initial_y]

# Solve optimization problem with bounds applied correctly
sol = solver(x0=initial_guess, lbx=[x_lower, y_lower], ubx=[x_upper, y_upper])

# Extract optimal values
optimal_x, optimal_y = sol["x"].full().flatten()
optimal_z = float(f(optimal_x, optimal_y).full())  # Keep function value as is

print(f"Optimal Solution: x = {optimal_x:.4f}, y = {optimal_y:.4f}, z = {optimal_z:.4f}")

# Generate grid data for visualization
x_values = np.linspace(x_lower, x_upper, 100)
y_values = np.linspace(y_lower, y_upper, 100)
X, Y = np.meshgrid(x_values, y_values)
Z = np.zeros_like(X)
for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        Z[i, j] = f(X[i, j], Y[i, j]).full().flatten()[0]  # Compute function value at each grid point

# Create an interactive 3D surface plot
fig = go.Figure(data=[go.Surface(x=X, y=Y, z=Z, colorscale='Viridis')])  # Use correct Z values

# Plot the found minimum point
fig.add_trace(go.Scatter3d(
    x=[optimal_x], y=[optimal_y], z=[optimal_z],  # Ensure correct placement
    mode='markers', marker=dict(size=8, color='red'),
    name='Optimal Point'
))

# Add axis labels and title
fig.update_layout(
    title="Optimized Minimum of Rotated Asymmetric Convex Surface",
    scene=dict(
        xaxis_title="Days of Delay",
        yaxis_title="Price",
        zaxis_title="Environmental Impact",
        xaxis=dict(showticklabels=False),
        yaxis=dict(showticklabels=False),
        zaxis=dict(showticklabels=False)
    )
)

# Show interactive plot
fig.show()