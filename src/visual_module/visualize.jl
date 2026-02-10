include("../def_var.jl")
include("create_heatmap.jl")

function h_show(file_path, step)
    print("$(E)Initializing visualization...")

    map = tif2heatmap(file_path, step)

    print("$(E)Saving as png...")
    savefig(map, "visualization/$(basename(splitext(file_path)[1]))_heatmap.png")
    print("$(E)Png saved!\n")
    plot(map)
end


if abspath(PROGRAM_FILE) == @__FILE__
    if isempty(ARGS)
        println("coe rapa, vou abrir oq?")
        println("manda assim ó: visualize.jl data/{teu troço aqui}")
        exit(1)
    end

    file_path = ARGS[1]
    h_show(file_path, 3)
end
