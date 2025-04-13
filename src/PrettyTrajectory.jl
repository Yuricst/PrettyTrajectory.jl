"""Module for pretty trajectory plotting with Makie"""

module PrettyTrajectory
    using FileIO
    using GeometryBasics
    using GLMakie
    using LinearAlgebra

    include("planets.jl")

    export plot_planet!
end