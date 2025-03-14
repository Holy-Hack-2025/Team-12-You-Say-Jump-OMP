## Project Description
We implement an interactive dashboard that integrates with inventory management systems to optimize supplier selection by balancing sustainability, reliability, and price. By leveraging advanced optimization techniques, we help businesses reduce waste, ensure supply chain stability, and accelerate the shift towards a circular economy. Our approach minimizes costs while promoting responsible sourcing and long-term sustainability.
![image](https://github.com/user-attachments/assets/d3b3e39f-888c-4532-96d4-2808da3c80e0)



## Overview
This script "Model_final" performs gradient descent optimization with Armijo backtracking on a rotated asymmetric convex function. The optimization process is visualized using an interactive 3D surface plot with Plotly.
![image](https://github.com/user-attachments/assets/28f9428b-b80f-40be-809d-9920b15a4956)

## Requirements
- `numpy`
- `casadi`
- `plotly`

## User Inputs
The script prompts the user for the following inputs:
- **Bounds for x and y** (lower and upper limits)
- **Initial guess for x and y**

If the initial guess is out of the specified bounds, an error is raised.

## Function Definition
The objective function is defined as:

$\[ z = (10 - x - 7)^2 + 1.5(y - 6)^2 + 4e^{-0.8((10 - x - 7)^2 + (y - 6)^2)} \]$

where $\( x \)$ is rotated around a vertical axis.

## Optimization Process
### Gradient Computation
The script computes the gradient of the function using CasADi and defines it as a function.

### Armijo Backtracking
An adaptive step size strategy using Armijo backtracking is implemented:
1. Start with an initial step size $\( \alpha = 1.0 \)$.
2. Reduce $\( \alpha \)$ by a factor $\( \beta = 0.5 \)$ until the function value decreases sufficiently.

### Gradient Descent Execution
The optimization process iterates up to 50 times, updating \( x \) and \( y \) using:

$\[ x_{k+1} = x_k - \alpha \nabla_x f(x_k, y_k) \]$
$\[ y_{k+1} = y_k - \alpha \nabla_y f(x_k, y_k) \]$

The algorithm stops if the gradient norm falls below $\( 10^{-6} \)$.

## Visualization
### Surface Plot
A 3D surface plot is generated using Plotly with:
- The function surface colored using a Viridis colormap.
- The **initial guess** marked in blue.
- The **optimized minimum** marked in red.
- The **optimization path** shown as a black line.

### Axes and Legend
- The axes are labeled:
  - `x-axis`: Reliability
  - `y-axis`: Price
  - `z-axis`: Footprint
- The legend is positioned outside the plot for better visibility.

## Execution
Run the script and input the requested values when prompted. The result is an interactive 3D visualization of the optimization process.

## Example Usage
```bash
python script.py
```

## Dependencies Installation
```bash
pip install numpy casadi plotly
