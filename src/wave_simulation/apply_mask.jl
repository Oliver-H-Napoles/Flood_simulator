

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
    water_pile = CartesianIndex[]
    starting_point = size(water_layer)
    R = CartesianIndices(water_layer)
    push!(water_pile, CartesianIndex(starting_point))
    while !isempty(water_pile)
        current_tile = water_pile[1]
        for j in (CartesianIndex(-1, 0), CartesianIndex(1, 0), 
                CartesianIndex(0, -1), CartesianIndex(0, 1))
            neighbor = current_tile + j
            if !(neighbor ∈ R) continue end
            if earth_layer[neighbor] <= water_level
                water_layer[neighbor] = 1
                push!(water_pile, neighbor)
            end
        end
        popfirst!(water_pile)
    end
end