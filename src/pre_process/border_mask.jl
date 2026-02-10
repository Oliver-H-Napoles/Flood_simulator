using Rasters, Shapefile, DataFrames


function create_state_mask(raster_template, shp_path, state_sigla="RJ")
    #=
    Creates a boolean mask aligned with the 'raster_template' geometry.
    Areas outside the state will be 'true' (to be changed to 3000 later).
    =#
    table = Shapefile.Table(shp_path)
    rows = collect(table)
    df = DataFrame(rows)
    idx = findfirst(df.sigla .== state_sigla)
    geom = Shapefile.shape(rows[idx])

    # boolmask returns 1 for inside the polygon, 0 for outside
    # We use the existing raster as a template for CRS, size, and resolution
    mask_grid = boolmask(geom; to=raster_template)
    return mask_grid
end

function create_states_mask(raster_template, shp_path, ufs::Tuple)
    #=
    Creates a boolean mask for multiple states.
    'ufs' should be a tuple of strings, e.g., ("RJ", "SP", "MG")
    =#
    println("Loading shapefile...")
    table = Shapefile.Table(shp_path)
    df = DataFrame(table)

    # 1. Find ALL indices where the sigla is in your tuple
    # We use 'findall' and a check function (s -> s in ufs)
    idxs = findall(s -> s in ufs, df.sigla)
    
    if isempty(idxs)
        error("No states found matching: $ufs")
    end

    println("Found states: $(df.sigla[idxs])")

    # 2. Extract the geometries for ALL matching rows
    # Shapefile.shapes(table) gets all shapes, we slice it with [idxs]
    geoms = Shapefile.shapes(table)[idxs]

    # 3. Create the mask
    # boolmask accepts a Vector of geometries and treats them as one big region
    println("Rasterizing mask...")
    mask_grid = boolmask(geoms; to=raster_template)
    
    return mask_grid
end

function apply_flood_boundary!(elevation_raster, state_mask, boundary_value=3000)
    # We iterate through the raster. If the mask is false (outside RJ), 
    # we set the elevation to 3000.
    # Using 'rebuild' or broadcasting is the fastest way in Rasters.jl

    output = modify(elevation_raster) do data
        # data is the underlying array
        # state_mask is a BitArray/Boolean grid
        for i in eachindex(data)
            if !state_mask[i]
                data[i] = boundary_value
            end
        end
        return data
    end

    return output
end

