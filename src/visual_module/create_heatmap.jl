using Images, Plots

function tif2heatmap(file)
    println("Converting tif into heatmap...")
    img = load(file)

    heights = Float64.(channelview(img))

    map = heatmap(heights,
        c = :terrain,
        title = "Regional Elevation map",
        xlabel = "Longitude",
        ylabel = "Latitude",
        aspect_ratio = :equal
    )

    return map
end