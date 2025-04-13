"""Observables"""


mutable struct OrbitAnimator
    framerate::Int
    time_step::Observable{Int}
    timestamps::Vector{Int}
    orbits_states::Array{Float64, 3}   # nsat x N_t x 3
    lifted_states
    trail_points
    nsat::Int
end


function OrbitAnimator(timestamps::Vector{Int}, orbits_states::Array{Float64,3}; framerate::Int = 30)
    time_step = Observable{Int}(1)  # initial index
    lifted_states = Vector{Observable{Float64}}[]
    for isat in 1:size(orbits_states,1)
        push!(
            lifted_states,
            [@lift(orbits_states[isat,$time_step,1]),
             @lift(orbits_states[isat,$time_step,2]),
             @lift(orbits_states[isat,$time_step,3]),]
        )
    end
    nsat = size(orbits_states,1)
    trail_points = [Observable(Point3f[orbits_states[i,1,:]]) for i in 1:nsat]
    #@show orbits_states[1,1,:]
    #trail_points = [Observable(Point3f[(0,0,0)]) for i in 1:size(orbits_states,1)]
    OrbitAnimator(
        framerate,
        time_step,
        timestamps,
        orbits_states,
        lifted_states,
        trail_points,
        nsat
    )
end


function OrbitAnimator(timestamps::Vector{Int}, orbit_states::Array{Float64,2}; framerate::Int = 30)
    orbits_states = zeros(1, size(orbit_states)...)
    orbits_states[1,:,:] = orbit_states
    return OrbitAnimator(timestamps, orbits_states; framerate = framerate)
end


function Base.show(io::IO, animator::OrbitAnimator)
    println(io, "Orbit animator struct")
    nsat,ntime,_ = size(animator.orbits_states)
    println(io, "    Number of objects    = $(nsat)")
    println(io, "    Number of time-steps = $(ntime)")
end


function update_to_file!(fig::Figure, animator::OrbitAnimator, filepath::String, trail_points::Bool = true)
    record(fig, filepath; framerate = animator.framerate) do io
        @showprogress for t in animator.timestamps
            animator.time_step[] = t
            if trail_points
                for isat in 1:animator.nsat
                    animator.trail_points[isat][] = push!(animator.trail_points[isat][], animator.orbits_states[isat,t,:])
                end
            end
            recordframe!(io)  # record a new frame
        end
    end
end


function update_live!(fig::Figure, animator::OrbitAnimator, sleep_display::Real, trail_points::Bool = true)
    display(fig)
    @showprogress for t in animator.timestamps
        animator.time_step[] = t
        if trail_points
            for isat in 1:animator.nsat
                animator.trail_points[isat][] = push!(animator.trail_points[isat][], animator.orbits_states[isat,t,:])
            end
        end
        sleep(sleep_display)
    end
end