"""Animate an orbit"""

using GLMakie
using ProgressMeter

# if !@isdefined PrettyTrajectory
#     include(joinpath(@__DIR__, "..", "src", "PrettyTrajectory.jl"))
# end
include(joinpath(@__DIR__, "..", "src", "PrettyTrajectory.jl"))

function test_animate_planet()
    # create fictitious trajectory state history
    n_steps = 200
    timestamps = Vector(1:n_steps)
    rs = Matrix([1.2.*cos.(LinRange(0, 4π, n_steps)) 1.2.*sin.(LinRange(0, 4π, n_steps)) LinRange(-1, 1, n_steps)])

    animator = PrettyTrajectory.OrbitAnimator(timestamps, rs)   # initialize animator object

    save_to_file = false
    sleep_display = 0.025

    # create animation
    begin
        i_time = animator.time_step    # somehow need to redefine in this scope!
        fig = Figure(size = (600,500))
        ax = Axis3(fig[1, 1], aspect=:data, elevation = deg2rad(30), azimuth = deg2rad(300),
                    protrusions = (45,18,36,30),  # (left,right,bottom,top)
        )
        xlims!(ax, -1.5, 1.5)
        ylims!(ax, -1.5, 1.5)
        zlims!(ax, -1.5, 1.5)

        # plot static elements
        ω = 2π / n_steps
        @show i_time, typeof(i_time)
        rotation = [0.0, 0.0,@lift($i_time * ω)]
        PrettyTrajectory.plot_planet!(ax, 1.0, (0.0, 0.0, 0.0); rotation = rotation)

        # plot trajectories
        for (isat,sat_trail_points) in enumerate(animator.trail_points)
            lines!(ax, sat_trail_points, color=:red, label = "Trajectory")
        end
        for (isat,sat_lifted_states) in enumerate(animator.lifted_states)
            scatter!(ax, sat_lifted_states..., color=:red, label = "Spaceraft", markersize = 10, marker = :diamond)
        end
        Legend(fig[2,1], ax, orientation = :horizontal)

        # animate to file
        if save_to_file == true
            PrettyTrajectory.update_to_file!(fig, animator, joinpath(@__DIR__, "plots", "test_animate_planet.gif"), true)

        # live display
        else 
            PrettyTrajectory.update_live!(fig, animator, sleep_display, true)
        end
    end
    @test true
end

test_animate_planet()