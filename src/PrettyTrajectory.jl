"""Module for pretty trajectory plotting with Makie"""

module PrettyTrajectory
    using FileIO
    using GeometryBasics
    using GLMakie
    using LinearAlgebra
    using ProgressMeter

    include("geometry3d.jl")
    include("planets.jl")
    include("animator.jl")

    export rotate_shift_points, plot_3d_box!, plot_cone!
    export plot_sphere_wireframe!, plot_planet!
end