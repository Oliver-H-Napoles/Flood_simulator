using Shapefile, Plots, DataFrames, Rasters

# Loads the BC250 federal units, filters for Rio de Janeiro, 
# and creates a high-quality vector plot.
function get_uf_border(path, UF)
    table = Shapefile.Table(path)
    # Using the 'collect' trick we discussed to ensure indexing works
    rows = collect(table)
    df = DataFrame(rows)
    
    # Check column names if this fails (e.g., NM_UF or SIGLA)
    target_idx = findfirst(df.sigla .== UF)
    land = Shapefile.shape(rows[target_idx])
    plot(land, 
     fillcolor = :lightblue, 
     linecolor = :black, 
     title = "Rio de Janeiro Border",
     aspect_ratio = :equal,
     size = (600, 400))
end

function visualize_rj_border(shp_path)
    table = Shapefile.Table(shp_path)
    
    # Find the row directly in the Shapefile Table
    rj_row = nothing
    for row in table
        if row.sigla == "RJ"
            rj_row = row
            break
        end
    end
    
    if rj_row !== nothing
        println("displaying")
        plot(Shapefile.shape(rj_row), aspect_ratio=:equal, title="RJ Border")
    else
        println("RJ not found")
    end
end
# To run:
# visualize_rj_border("lml_unidade_federacao_a.shp")

function visualize_hydrography_cropped(raster_path::String, shp_path::String; step::Int=10)
    # 1. Load Raster and get its Bounding Box
    println("Loading Raster...")
    elevation = Raster(raster_path)
    
    # Get the extent (Xmin, Xmax, Ymin, Ymax)
    ext = Extents.extent(elevation)
    xmin, xmax = ext.X
    ymin, ymax = ext.Y
    
    println("Map Bounds: Lon $xmin to $xmax, Lat $ymin to $ymax")

    # 2. Load Shapefile
    println("Loading Shapefile Table...")
    table = Shapefile.Table(shp_path)
    
    # 3. Filter Shapes (The Magic Step)
    # We check if each river segment is inside (or overlaps) our map view
    println("Filtering for rivers inside the map...")
    
    filtered_shapes = []
    
    for row in table
        # Get the bounding box of the river segment
        # Shapefile.jl puts the bounding box in the .box field of the geometry
        geom = Shapefile.shape(row)
        
        # Check if the river's box overlaps our map's box
        # This is super fast because we don't check every point, just the box.
        if (geom.box.min.x <= xmax && geom.box.max.x >= xmin) && 
           (geom.box.min.y <= ymax && geom.box.max.y >= ymin)
            push!(filtered_shapes, geom)
        end
    end
    
    println("Found $(length(filtered_shapes)) river segments inside the map.")

    # 4. Plot
    println("Generating Plot...")
    elevation_lowres = elevation[1:step:end, 1:step:end]
    
    p = plot(elevation_lowres, 
             title="RJ Elevation + Filtered Rivers", 
             colormap=:viridis, 
             margin=5Plots.mm)
             
    # Plot only the filtered list
    plot!(p, filtered_shapes, linecolor=:cyan, linewidth=0.8, label="Rivers (Cropped)")
    
    display(p)
end