"""Objects in 3D space"""


function rotate_shift_points(points::Vector{Point3f}, rotation::Tuple{Real,Real,Real}, center::Tuple{Real,Real,Real})
    Rx = [1 0 0; 0 cos(rotation[1]) -sin(rotation[1]); 0 sin(rotation[1]) cos(rotation[1])]
    Ry = [cos(rotation[2]) 0 sin(rotation[2]); 0 1 0; -sin(rotation[2]) 0 cos(rotation[2])]
    Rz = [cos(rotation[3]) -sin(rotation[3]) 0; sin(rotation[3]) cos(rotation[3]) 0; 0 0 1]
    R = Rz * Ry * Rx
    rotated_points = [Point3f(R * [p[1], p[2], p[3]] + Vector([center...])) for p in points]
    return rotated_points, R
end

function rotate_shift_points_lift(points::Vector{Point3f}, rotation, center::Tuple{Real,Real,Real}, lift_index::Observable{Int})
    Rx = [1 0 0; 0 cos(rotation[1]) -sin(rotation[1]); 0 sin(rotation[1]) cos(rotation[1])]
    Ry = [cos(rotation[2]) 0 sin(rotation[2]); 0 1 0; -sin(rotation[2]) 0 cos(rotation[2])]
    Rz = @lift([cos($lift_index * rotation[3]) -sin($lift_index * rotation[3]) 0; 
                sin($lift_index * rotation[3]) cos($lift_index * rotation[3]) 0; 
                0 0 1])
    R = @lift($Rz * Ry * Rx)
    rotated_points = @lift([Point3f($R * [p[1], p[2], p[3]] + Vector([center...])) for p in points])
    return rotated_points, R
end


function plot_3d_box!(axis::Axis3, r_lb, r_ub; color=:red, linewidth=1.5)
    # lower edges
    lines!(axis,
        [r_lb[1], r_lb[1]], [r_lb[2], r_ub[2]],[r_lb[3], r_lb[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_ub[1], r_ub[1]], [r_lb[2], r_ub[2]],[r_lb[3], r_lb[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_lb[1], r_ub[1]], [r_lb[2], r_lb[2]],[r_lb[3], r_lb[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_lb[1], r_ub[1]], [r_ub[2], r_ub[2]],[r_lb[3], r_lb[3]],
        color=color, linewidth=linewidth,
    )
    
    # upper edges
    lines!(axis,
        [r_lb[1], r_lb[1]], [r_lb[2], r_ub[2]],[r_ub[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_ub[1], r_ub[1]], [r_lb[2], r_ub[2]],[r_ub[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_lb[1], r_ub[1]], [r_lb[2], r_lb[2]],[r_ub[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_lb[1], r_ub[1]], [r_ub[2], r_ub[2]],[r_ub[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )

    # vertical edges
    lines!(axis,
        [r_lb[1], r_lb[1]], [r_lb[2], r_lb[2]],[r_lb[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_ub[1], r_ub[1]], [r_lb[2], r_lb[2]],[r_lb[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_lb[1], r_lb[1]], [r_ub[2], r_ub[2]],[r_lb[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
    lines!(axis,
        [r_ub[1], r_ub[1]], [r_ub[2], r_ub[2]],[r_lb[3], r_ub[3]],
        color=color, linewidth=linewidth,
    )
end



function plot_cone!(
    ax::Axis3,
    vertex::Tuple{Real,Real,Real}, radius::Real, height::Real;
    show_base::Bool = true,
    rotation::Tuple{Real,Real,Real} = (0.0, 0.0, 0.0),
    N_points::Int = 200,
    alpha::Real = 0.45,
    color=:red,
    linecolor = :red,
    linewidth::Real = 1.0,
    shift_angle::Real = deg2rad(5)
)   
    lower = [Point3f(0,0,0) for _ in 1:N_points]
    upper = [Point3f(height,
                     radius*sin(x+shift_angle),
                     radius*cos(x+shift_angle)) for x in range(0,2pi, length=N_points)]
    lower, _ = rotate_shift_points(lower, rotation, vertex)
    upper, _ = rotate_shift_points(upper, rotation, vertex)
    col = repeat([1:50;50:-1:1],outer=2)
    if show_base
        lines!(ax, upper, color=linecolor, linewidth=linewidth)
    end
    band!(ax, lower, upper, color=col, alpha=alpha, colormap=cgrad([color, color]))
    return
end