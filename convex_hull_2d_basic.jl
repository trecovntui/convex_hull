#=

       (y)
		|
		|
		|
		|
		|
	    O-----------(x)
       /
      /
     /
	/
  (z) (z used for checking orientation)

=#


using Plots
using Distributions
using LinearAlgebra

# FYI:
# .* is dot product

n_points = 50

# n_points columns of 2d points with coordinate values between 0 and 10
# points[i, :] gives the ith point
points = rand(Uniform(0, 10), n_points, 2)
# points = Float64.([0;0;; 1;1;; 3;3;; 5;5;; 1;0;; 3;2;; 5;4;; 6;5])'
# points = Float64.([1;1;; 0;1;; 0;0;; 1;0;; 0;0.5;; 0.5;1;; 1;0.5;; 0.5;0;; 1;0.2;; 1;0.7])'

# c - nx2 matrix of points where column 1 has x coordinates and column 2 has y coordinates.
# n - Total number of points.
#
# Returns point(s) with minimum x.

function find_minima_x(c, n)
	min_x_indices = [1]
	for index in 2:n
		if(c[index, :][1] < c[min_x_indices[1], :][1])
			min_x_indices = [index]
		elseif((c[index, :][1] > c[min_x_indices[1], :][1]))
			# Do nothing.
		else
			min_x_indices = [min_x_indices; index]
		end
	end
	return min_x_indices
end

# c - Nx2 matrix of points where column 1 has x coordinates and column 2 has y coordinates.
# N - Total number of points.
# show - If true, show plot.
function find_hull(c, N, show)
	min_x_indices = find_minima_x(c, N)
	min_x_points = c[min_x_indices, :]

	# This is so we pick the point with the least y
	# when we have multiple points with the same minimum x.
	min_x_y_index = findmin(min_x_points[:, 2])[2]
	min_x_index = min_x_indices[min_x_y_index]
	min_x_point = c[min_x_index, :]

	# Remove min_x_point from the list
	# because this already belongs to the hull.
	# TODO: need to fix the case for multiple min points with same x
	c = c[1:end .!=min_x_index, 1:end]

	sort_angles = [((min_x_point - c[i, :])[2] / norm(c[i, :] - min_x_point)) for i in 1:(N - 1)]
	sorted_indices = sortperm(sort_angles)

	# The left most point is definitely on the hull.
	# The point making the least angle is also on the hull.
	hull = [min_x_point;; c[sorted_indices[1], :]]

	# Remove the point making the least angle from the point list.
	sorted_indices = sorted_indices[1:end .!=1]

	for index in 1:(N - 1)
		if(index < (N - 1))
			point3 = c[sorted_indices[index], :]
		end
		
		if(index == (N - 1))
			# First hull point.
			# This is to ensure that no hull points exist on the
			# last edge of the hull (which ends at the first point).
			point3 = hull[:, 1]
		end
		
		skip_point = false
		
		while(true)
			point1 = hull[:, end - 1]
			point2 = hull[:, end - 0]
			
			hull_edge = (point2 - point1)
			test_edge = (point3 - point1)
			
			# z-coordinate of the cross product.
			# > 0 means anti-clockwise which we want for the convex hull.
			# < 0 is clockwise
			orientation = cross([test_edge; 0], [hull_edge; 0])[3]

			if(orientation < 0.0)
				# Remove the last point and add the new point (done after the while).
				hull = hull[1:end, 1:end .!=end]
				
			elseif(orientation > 0.0)
				break
				
			else # TODO: I don't think this is alright for checking =0.
				if(norm(point3 - point1) > norm(point2 - point1))
					# Remove the last point and add the new point (done after the while).
					hull = hull[1:end, 1:end .!=end]
				else
					# Point is closer, ignore it.
					skip_point = true
				end
				break
			end
		end
		
		if(!skip_point)
			hull = [hull;; point3]
		end
	end
	
	# First vertex is also repeated at the end so the plot loops.
	
	if(show)
		display(scatter(c[:, 1], c[:, 2], legend = false, color = "blue", markersize = 1))
		display(plot!(hull[1, :], hull[2, :]))
		display(scatter!(hull[1, :], hull[2, :], color = "red", markersize = 3))
	end
	
	return hull
end

convex_hull = find_hull(points, n_points, true)