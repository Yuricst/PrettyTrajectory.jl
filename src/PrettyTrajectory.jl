"""Module for pretty trajectory plotting with Makie"""

module PrettyTrajectory
    using FileIO
    using GeometryBasics
    using GLMakie
    using LinearAlgebra

    include("geometry3d.jl")
    include("planets.jl")

    export rotate_shift_points, plot_3d_box!, plot_cone!
    export plot_sphere_wireframe!, plot_planet!
end