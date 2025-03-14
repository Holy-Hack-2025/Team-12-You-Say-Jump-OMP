import numpy as np
import plotly.graph_objects as go

# Define the function to create an asymmetric convex shape with a sharp bottom edge
def f_convex(x, y):
    """Creates an asymmetric convex shape with a clear minimum and sharp bottom edge, rotated along a vertical axis."""
    # Rotate the minimum to a higher x value (shifted to x=7 instead of x=3)
    x_rotated = 10 - x  # Rotation along a vertical axis

    # Asymmetric quadratic function: different curvature in x and y
    z = (x_rotated - 7)*2 + 1.5 * (y - 6)*2  # Minimum now at (x=7, y=6)

    # Add a sharper edge at the bottom to prevent flattening
    z += np.exp(-0.8 * ((x_rotated - 7)*2 + (y - 6)*2)) * 4  # Sharper edge at the minimum

    # Add mild noise to simulate real-world data smoothness
    noise = np.random.normal(0, 0.2)  # Small noise for smooth convexity
    return z + noise

# Generate grid data to create a rotated surface
x_values = np.linspace(0, 10, 100)
y_values = np.linspace(0, 10, 100)
X, Y = np.meshgrid(x_values, y_values)
Z = np.array([[f_convex(x, y) for x, y in zip(row_x, row_y)] for row_x, row_y in zip(X, Y)])

# Create an interactive 3D surface plot
fig = go.Figure(data=[go.Surface(x=X, y=Y, z=Z, colorscale='Viridis')])

# Add axis labels and title
fig.update_layout(
    title="Rotated Asymmetric Convex Surface (Minimum at Higher X)",
    scene=dict(
        xaxis_title="X-axis",
        yaxis_title="Y-axis",
        zaxis_title="Z-axis"
    )
)

# Show interactive plot
fig.show()