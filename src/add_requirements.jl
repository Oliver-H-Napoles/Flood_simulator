using Pkg
Pkg.add(["Images",
        "Plots",
        "Rasters",
        "ArchGDAL",
        "Shapefile",
        "DataFrames",
        "IJulia",
        "Proj",
        "Serialization",
        "LsqFit",
        "SymbolicRegression",
        "Statistics"])
using IJulia
installkernel("Julia")