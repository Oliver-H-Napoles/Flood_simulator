println("Initializing visualization...")
include("create_heatmap.jl")

if isempty(ARGS)
    println("coe rapa, vou abrir oq?")
    exit(1)
end

file_path = ARGS[1]

map = tif2heatmap(file_path)

println("Displaying heatmap...")
savefig(map, "$(file_path[6:11])_heatmap.png")
display(map)
