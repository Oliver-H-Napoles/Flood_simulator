using Images, Plots
include("../def_var.jl")

function tif2heatmap(file, step=1)
    #=
    Generates a heatmap of the file passed with a resolution decreased by step
    =#

    print("$(E)Converting tif into heatmap...")
    img = load(file)

    raw = Float64.(channelview(img))
    
    processed = copy(raw)

    land_mask = raw .>= 0
    processed[land_mask] .+= 200
    processed[.!land_mask] .-=200

    heights = reverse(processed, dims=1)

    map = heatmap(heights[1:step:end, 1:step:end],
        c = :terrain,
        title = "Regional Elevation map",
        aspect_ratio = :equal,
    )
    println("$(E)Heatmap ready!")
    println("Min: $(minimum(raw)), Max: $(maximum(raw))")
    return map
end