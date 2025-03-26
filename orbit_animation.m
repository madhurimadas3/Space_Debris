% Load the orbital parameters from orbit_data.mat
load('orbit_data.mat', 'debris_names', 'semi_major_axes', 'eccentricities', 'RAANs', 'argPerigees', 'inclinations');

% Create a figure for the animation
figure; hold on; axis equal; grid on;

% Plot Earth as a reference (constant background)
[xs, ys, zs] = sphere(30); % Create a sphere
surf(xs * 6371, ys * 6371, zs * 6371, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); % Scale to Earth radius

% Define animation parameters
frames = 30 * 60; % 30 frames per second * 60 seconds = 1800 frames
time_step = 1 / 30; % Time step between frames (in seconds)

% Initialize handles for the debris and their trajectories (so we can update them in the loop)
debris_handles = NaN(1, length(debris_names)); % Initialize as NaN to store handles
trajectory_handles = NaN(1, length(debris_names)); % Initialize handles for trajectories

% Loop to animate the debris for 60 seconds
for t = 1:frames
    % Loop over each debris and update their positions
    for idx = 1:length(debris_names)
        % Get the orbital elements for the current debris
        semi_major_axis = semi_major_axes(idx);
        eccentricity = eccentricities(idx);
        RAAN = deg2rad(RAANs(idx));
        argPerigee = deg2rad(argPerigees(idx));
        inclination = deg2rad(inclinations(idx));

        % Generate the current True Anomaly based on time (t)
        theta = linspace(0, 2*pi, frames);
        current_theta = theta(t);
        
        % Compute the current position in polar coordinates
        r = (semi_major_axis * (1 - eccentricity^2)) ./ (1 + eccentricity * cos(current_theta));

        % Convert to 3D Cartesian Coordinates
        x = r * (cos(RAAN) * cos(current_theta + argPerigee) - sin(RAAN) * sin(current_theta + argPerigee) * cos(inclination));
        y = r * (sin(RAAN) * cos(current_theta + argPerigee) + cos(RAAN) * sin(current_theta + argPerigee) * cos(inclination));
        z = r * (sin(current_theta + argPerigee) * sin(inclination));

        % Set darker colors for the debris
        color = [0.5 0.5 0.5]; % Dark gray color for debris

        % Plot the debris and store the handle for later updating
        if t == 1
            % Initial plot (first frame)
            debris_handles(idx) = plot3(x, y, z, 'o', 'MarkerSize', 5, 'Color', color);
            % Plot the trajectory with a thicker line
            trajectory_handles(idx) = plot3(x, y, z, 'LineWidth', 2, 'Color', color);
        else
            % Update the position of the debris for subsequent frames
            set(debris_handles(idx), 'XData', x, 'YData', y, 'ZData', z);
            % Update the trajectory
            set(trajectory_handles(idx), 'XData', [get(trajectory_handles(idx), 'XData'), x], ...
                                          'YData', [get(trajectory_handles(idx), 'YData'), y], ...
                                          'ZData', [get(trajectory_handles(idx), 'ZData'), z]);
        end
    end
    
    % Capture the current frame
    frame = getframe(gcf); % Capture the figure as a frame
    img = frame2im(frame); % Convert the frame to an image
    
    % Convert the image to indexed format
    [A, map] = rgb2ind(img, 256); % Convert to indexed image format for GIF
    
    % Save the first frame or append the subsequent frames
    if t == 1
        % Create the GIF file and save the first frame
        imwrite(A, map, 'space_debris_animation.gif', 'GIF', 'LoopCount', Inf, 'DelayTime', time_step);
    else
        % Append the subsequent frames to the GIF
        imwrite(A, map, 'space_debris_animation.gif', 'GIF', 'WriteMode', 'append', 'DelayTime', time_step);
    end
    
    % Pause for the time step to control animation speed
    pause(time_step);
end

% Add legend for debris names
legend(debris_names, 'Location', 'best');

% Final labels & Formatting
xlabel('X (km)'); ylabel('Y (km)'); zlabel('Z (km)');
title('3D Space Debris Orbit');

% Set the 3D view (using proper axis limits)
axis([-1 1 -1 1 -1 1] * max(semi_major_axes) * 1.5); % Extend the axis limits for better view

% Set the view to 3D
view(3);
hold off;
