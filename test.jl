include("src/def_var.jl")
include("src/pre_process/dimensions.jl")
using Images

function gen_filler_tiles()
    rows, cols = get_sample_dimensions("data/21S42_ZN.tif")

    println("lines:$(rows)\ncolumns:$(cols)")

    zero_block = zeros(rows, cols)
    save("data/23S42_ZN.tif", colorview(Gray, zero_block))

    neg_block = fill(-1.0, rows, cols)
    save("data/21S45_ZN.tif", colorview(Gray, neg_block))

    println("Done!")
end

function gen_main_matrix()
    #=
    Create a big big matrix and fill it with the map tiles
    =#
    print("Generating big matrix")
    rows, cols = get_sample_dimensions("data/21S42_ZN.tif")
    big_big = zeros(rows*2, cols)


    tile1 = Float64.(channelview(load("data/22S435ZN.tif")))
    print("$(E)Adding 22 to the map")
    big_big[1:3600, 1:end] .= tile1
    tile1 = nothing
    GC.gc()

    tile2 = Float64.(channelview(load("data/23S435ZN.tif")))
    print("$(E)Adding 23 to the map")
    big_big[3601:end, 1:end] .= tile2
    tile2 = nothing
    GC.gc()
    
    print("\nsaving file...")
    save("concat_rio_test.tif", colorview(Gray, big_big))
    print("$(E)file saved!\n")
end


if abspath(PROGRAM_FILE) == @__FILE__
    gen_main_matrix()
end
