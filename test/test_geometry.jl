"""Plot geometries"""

using GLMakie

if !@isdefined PrettyTrajectory
    include(joinpath(@__DIR__, "..", "src", "PrettyTrajectory.jl"))
end

function test_geometry()
    # plot cones
    vertex = (1.0, 2.0, 3.0)
    rotation = (0.0, 0.0, deg2rad(180))
    fig = Figure(size=(800,800))
    rotations = [
        (0.0, 0.0, 0.0),
        (deg2rad(90), 0.0, 0.0),
        (0.0, deg2rad(90.0), 0.0),
        (0.0, 0.0, deg2rad(90.0)),
    ]
    axes_locations = [(1,1),(1,2),(2,1),(2,2)]
    titles = ["(0,0,0)", "(90,0,0)", "(0,90,0)", "(0,0,90)"]
    for (i,(rotation,axloc)) in enumerate(zip(rotations, axes_locations))
        ax = Axis3(fig[axloc...]; aspect=:data, title="Rotation $(titles[i])", elevation = deg2rad(10))
        scatter!(ax, [vertex[1]], [vertex[2]], [vertex[3]], color=:black)
        PrettyTrajectory.plot_cone!(ax, vertex, 2.0, 3.0; color=:red, alpha=0.15, rotation=rotation)
    end
    save(joinpath(@__DIR__, "plots/test_cones.png"), fig; px_per_unit=2)
    @test true

    fig = Figure(size=(400,400))
    ax = Axis3(fig[1,1:2]; aspect=:data)
    box_lb = [-1.0, -2.0, -0.5]
    box_ub = [1.0, 2.0, 0.5]
    PrettyTrajectory.plot_3d_box!(ax, box_lb, box_ub)
    save(joinpath(@__DIR__, "plots/test_box.png"), fig; px_per_unit=2)
    display(fig)
    @test true
end

test_geometry()