using Images

function create_flood_mask(rows,columns)
    #= Create a matrix to be compared to the land matrix as a water layer
    the start position understand the following setting and will determine the starting position of the water
                1_______2
                |       |
                |       |
                |_______|
                3       4         =#

    water_layer = zeros(rows, columns)
    water_layer[end, end] = 1

    return water_layer
end


function expand_flood_best!(earth_layer, water_layer, water_level)
    #=
        expand the first water point so it covers all reachable terrain based on the water_level
    =#
    flood_counter = 0
    water_pile = CartesianIndex[]
    starting_point = size(water_layer)
    R = CartesianIndices(water_layer)
    push!(water_pile, CartesianIndex(starting_point))
    while !isempty(water_pile)
        current_tile = water_pile[1]
        for j in (CartesianIndex(-1, 0), CartesianIndex(1, 0), 
                CartesianIndex(0, -1), CartesianIndex(0, 1))
            neighbor = current_tile + j
            if !(neighbor ∈ R)||(water_layer[neighbor]==1) continue end
            n_tile = earth_layer[neighbor]
            if n_tile <= water_level
                if (n_tile > -1) flood_counter += 1 end
                water_layer[neighbor] = 1
                push!(water_pile, neighbor)
            end
        end
        popfirst!(water_pile)
    end
    return flood_counter
end

#= Deprecated due to high usega of memory by plots.savefig()
function visualize_flood(earth_layer, water_layer, water_level)
    println("Preparing visualization...")
    # 1. Downsample for plotting (Crucial for performance!)
    # We take every Nth pixel.
    
    # 2. Plot the Terrain
    # Using 'aspect_ratio=:equal' ensures Rio doesn't look squashed
    p = heatmap(earth_layer, 
                c=:terrain, 
                title="Flood Simulation (Level: $water_level m)", 
                aspect_ratio=:equal,
                clims=(-10, 1500)) # Fix color scale so mountains don't hide details
    
    # 3. Create the Water Overlay
    # We convert 0s to NaN so they become transparent
    water_viz = [w == 1 ? 1.0 : NaN for w in water_layer]
    
    heatmap!(p, water_viz, c=:blues, alpha=0.7, colorbar=false)
    # 4. Save with a safe filename
    filename = "visualization/flood_level_$(water_level).png"
    println("Saving to $filename...")
    save(filename, p)
    p = nothing
end
=#

function save_flood_snapshot(earth_matrix, water_matrix, filename)
    println("Generating raw image...")
    
    # 1. Normalize Earth to 0.0 - 1.0 for grayscale
    # We clamp values to avoid issues with outliers
    min_elev, max_elev = -10.0, 1500.0
    normalized = clamp.((earth_matrix .- min_elev) ./ (max_elev - min_elev), 0.0, 1.0)
    
    # 2. Create Base Image (Grayscale Terrain)
    # This creates an RGB image immediately, which is very light.
    img = RGB.(normalized, normalized, normalized)
    
    # 3. Overlay Water (Manual Blue Tint)
    # We iterate and color only the wet pixels
    blue_color = RGB(0.2, 0.6, 1.0) # Nice water blue
    
    rows, cols = size(img)
    for i in 1:rows, j in 1:cols
        if water_matrix[i, j] == 1
            # Blend 70% water, 30% terrain (transparency effect)
            img[i, j] = 0.7 * blue_color + 0.3 * img[i, j]
        end
    end
    
    # 4. Save directly
    println("Writing to disk: $filename")
    save(filename, img')
    println("Saved!")
end 