using Rasters, Plots
include("../def_var.jl")

function tif2heatmap(file, step=1)
    #=
    Generates a heatmap of the file passed with a resolution decreased by step
    =#

    print("$(E)Loading file")
    img = Raster(file)

    print("$(E)Converting to matrix")
    raw = img[1:step:end, 1:step:end].data
    
    processed = copy(raw)
    #=
    land_mask = raw .>= 0
    processed[land_mask] .+= 200
    processed[.!land_mask] .-=200
    =#
    heights = reverse(processed', dims=1)

    y, x = size(heights)
    print("$(E)Converting tif into heatmap...")
    map = heatmap(heights,
        c = :terrain,
        title = "Regional Elevation map",
        aspect_ratio = :equal,
        xlims = (0, x),
    )
    println("$(E)Heatmap ready!")
    println("Min: $(minimum(raw)), Max: $(maximum(raw))")
    return map
end