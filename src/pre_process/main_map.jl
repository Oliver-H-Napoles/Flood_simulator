include("../def_var.jl")
include("dimensions.jl")
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
    big_big = zeros(rows*3, cols*3)

    suffix = ["45_", "435", "42_"]
    for line in 1:3
        prefix = "2$line"
        line_f = line*rows
        line_i = (line-1)*rows+1
        for column in 1:3
            col_f = column*cols
            col_i = (column-1)*cols+1
            load_tile = "$(prefix)S$(suffix[column])ZN.tif"
            curr_tile = Float64.(channelview(load("data/$(load_tile)")))
            print("$(E)Adding $load_tile to the map")
            big_big[line_i:line_f, col_i:col_f] .= curr_tile
            tile = nothing
            GC.gc()
        end
    end
    print("\nsaving file...")
    save("data/sample_map/concat_rio.tif", colorview(Gray, big_big))
    print("$(E)file saved!\n")
end


if abspath(PROGRAM_FILE) == @__FILE__
    gen_main_matrix()
end
