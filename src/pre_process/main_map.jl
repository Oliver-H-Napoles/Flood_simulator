include("../def_var.jl")
include("dimensions.jl")
using Images
using Rasters 
using ArchGDAL 
using ArchGDAL.GDAL
import Proj

function gen_filler_tiles()
    rows, cols = get_sample_dimensions("../data/21S42_ZN.tif")

    println("rows:$(rows)\ncolumns:$(cols)")

    zero_block = zeros(rows, cols)
    save("../data/23S42_ZN.tif", colorview(Gray, zero_block))

    neg_block = fill(-1.0, rows, cols)
    save("../data/21S45_ZN.tif", colorview(Gray, neg_block))

    println("Done!")
end

function gen_main_matrix_deprecated()
    #=
    Create a big big matrix and fill it with the map tiles
    =#
    print("Generating big matrix")
    rows, cols = get_sample_dimensions("../data/21S42_ZN.tif")
    big_big = zeros(rows*3, cols*3)

    suffix = ["45_", "435", "42_"]
    for row in 1:3
        prefix = "2$row"
        row_f = row*rows
        row_i = (row-1)*rows+1
        for column in 1:3
            col_f = column*cols
            col_i = (column-1)*cols+1
            load_tile = "$(prefix)S$(suffix[column])ZN.tif"
            curr_tile = Float64.(load("../data/$(load_tile)"))
            print("$(E)Adding $load_tile to the map")
            big_big[row_i:row_f, col_i:col_f] .= curr_tile
            tile = nothing
            GC.gc()
        end
    end
    print("\nsaving file...")
    save("../data/sample_map/concat_rio.tif", colorview(Gray, big_big))
    print("$(E)file saved!\n")
end

function gen_main_matrix()
    # 1. Load your tiles as raw matrices (as you are doing now)
    rows, cols = get_sample_dimensions("../data/21S42_ZN.tif")
    big_big = zeros(Float32, rows*3, cols*3)

    suffix = ["45_", "435", "42_"]
    for row in 1:3
        prefix = "2$row"
        row_f = row*rows
        row_i = (row-1)*rows+1
        for column in 1:3
            col_f = column*cols
            col_i = (column-1)*cols+1
            load_tile = "$(prefix)S$(suffix[column])ZN.tif"
            curr_tile = Float64.(load("../data/$(load_tile)"))
            print("$(E)Adding $load_tile to the map")
            big_big[row_i:row_f, col_i:col_f] .= curr_tile
            tile = nothing
            GC.gc()
        end
    end
# ... inside gen_main_matrix, after the loop ...

    # 1. Define Matrix Size (Based on your 3x3 grid)
    total_rows = 3*rows
    total_cols = 3*cols
    
    # 2. Define Start Coordinates (From TOPODATA PDF standard)
    # File "21S45" means: Top-Left Lat = 21°S (-21.0), Top-Left Lon = 45°W (-45.0)
    y_start = -21.0
    x_start = -45.0
    
    # 3. Calculate Exact Resolution 
    pixel_step_y = 3.0 / total_rows  
    pixel_step_x = 4.5 / total_cols 

    # 4. Create Dimensions with explicit 'Rasters' namespace
    # We shift the start by half a pixel because we are using 'Points()' (center of pixel)
    # consistent with standard Elevation data.
    x_range = range(x_start + pixel_step_x/2, step=pixel_step_x, length=total_cols)
    y_range = range(y_start - pixel_step_y/2, step=-pixel_step_y, length=total_rows)

    target_dims = (
        Y(Projected(y_range; crs=EPSG(4674), sampling=Rasters.Points())),
        X(Projected(x_range; crs=EPSG(4674), sampling=Rasters.Points()))
    )

    # 5. Save
    # We use EPSG(4674) (SIRGAS 2000 Lat/Lon) because your units are Degrees.
    # (EPSG 31983 is for Meters/UTM, which would be wrong here!)
    geo_raster = Raster(big_big, dims=target_dims)
    write("../data/sample_map/concat_rio.tif", geo_raster, force=true)
end

if abspath(PROGRAM_FILE) == @__FILE__
    gen_main_matrix()
end
