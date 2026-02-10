using Images, Rasters

function get_sample_dimensions(sample)
    println("getting sample")
    sample_matrix = Float64.(load(sample))
    rows, cols = size(sample_matrix)
    return rows, cols
end

function check_overall_dimensions()
    sample_rows = []
    sample_cols = []
    for file in readdir("data")
        if endswith(file, ".tif") 
            rows, cols = get_sample_dimensions("data/$file")
            push!(sample_rows, rows)
            push!(sample_cols, cols)
        end
    end
    println(sample_rows)
    println(sample_cols)
end

if abspath(PROGRAM_FILE) == @__FILE__
    check_overall_dimensions()
end