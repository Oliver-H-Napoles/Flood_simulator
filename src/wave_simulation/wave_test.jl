using Plots
include("apply_mask.jl")
include("../def_var.jl")

# Generates a matrix with random "hills" using a simple moving average for smoothness
function generate_earth_layer(rows, cols)
    # Start with random noise
    print("Generating earth_layer...")
    matrix = rand(rows, cols) * 10 
    
    print("$(E)Smoothing terrain...")
    # Smooth the noise to create hills and valleys
    smoothed = copy(matrix)
    for i in 2:rows-1, j in 2:cols-1
        smoothed[i, j] = mean(matrix[i-1:i+1, j-1:j+1])
    end
    println("$(E)Earth layer generated")
    return smoothed
end

# Helper to calculate mean without external libraries
mean(x) = sum(x) / length(x)

#=
# Visualizes the results
function visualize_flood_deprecated(earth_layer, water_layer, water_level)
    # Plot the terrain as a heatmap (browns/greens)
    print("Creating heatmap...")
    p = heatmap(earth_layer, c=:terrain, title="Flood Simulation", aspect_ratio=1)
    
    # Create a mask for the water (only plot where water_layer == 1)
    # We use a semi-transparent blue overlay
    water_viz = [w == 1 ? 1.0 : NaN for w in water_layer]
    
    heatmap!(p, water_viz, c=:ice, alpha=0.7, colorbar=false)
    println("$(E)Displaying heatmap")
    savefig(p, "visualization/flood_at_$(water_level).png")

    
    #display(p)
end
=#

if abspath(PROGRAM_FILE) == @__FILE__
    rows, cols = 50, 50
    water_level = 5.5  # Adjust this to see more or less flooding

    # 1. Setup data
    earth = generate_earth_layer(rows, cols)
    water = create_flood_mask(rows, cols)

    # 2. Run your flood algorithm
    expand_flood_best!(earth, water, water_level)

    # 3. See the results
    visualize_flood_deprecated(earth, water)

end