"""Plot geometries in 2D"""


function plot_circle!(
    axis::Axis,
    r::Real,
    center::Tuple{Real,Real};
    color=:gray10,
    linewidth=1.5,
    label=nothing,
    steps::Int=200
)
    lines!(axis,
        r .* cos.(LinRange(0, 2π, steps)) .+ center[1],
        r .* sin.(LinRange(0, 2π, steps)) .+ center[2],
        color=color, linewidth=linewidth, label = label,
    )
    return
end


function plot_box!(
    ax::Axis,
    r_lb::Tuple{Real,Real},
    r_ub::Tuple{Real,Real};
    color=:gray10,
    linewidth=1.5,
    label=nothing,
)
    lines!(ax,
        [r_lb[1], r_lb[1]], [r_lb[2], r_ub[2]],
        color=color, linewidth=linewidth, label = label,
    )
    lines!(ax,
        [r_ub[1], r_ub[1]], [r_lb[2], r_ub[2]],
        color=color, linewidth=linewidth, label = label,
    )
    lines!(ax,
        [r_lb[1], r_ub[1]], [r_lb[2], r_lb[2]],
        color=color, linewidth=linewidth, label = label,
    )
    lines!(ax,
        [r_lb[1], r_ub[1]], [r_ub[2], r_ub[2]],
        color=color, linewidth=linewidth, label = label,
    )
    return
end

