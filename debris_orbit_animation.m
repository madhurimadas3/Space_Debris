% clear everything
clc; clear; close all;

% Load the orbital data saved earlier
load('orbit_data.mat');

% Set up the figure for the animation
figure; hold on; axis equal; grid on;
xlabel('X (km)'); ylabel('Y (km)'); zlabel('Z (km)');
title('3D Space Debris Orbit Animation');

% Plot Earth for reference (center of the plot)
[xs, ys, zs] = sphere(30); % Create a sphere
surf(xs * 6371, ys * 6371, zs * 6371, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); % Scale to Earth radius

% Initialize colors for each debris (use the colors defined previously)
colors = {'r', 'b', 'g', 'm'};

% Initialize the plot handles for the debris and their orbits
debris_handles = [];
orbit_handles = [];

% Loop over the debris and plot their orbits
for idx = 1:length(debris_names)
    % Get the orbital elements for the current debris
    semi_major_axis = semi_major_axes(idx);
    eccentricity = eccentricities(idx);
    RAAN = deg2rad(RAANs(idx));
    argPerigee = deg2rad(argPerigees(idx));
    inclination = deg2rad(inclinations(idx));

    % Generate True Anomaly values (0 to 360 degrees) for the full orbit
    theta = linspace(0, 2*pi, 500);
    
    % Compute orbit in polar coordinates
    r = (semi_major_axis * (1 - eccentricity^2)) ./ (1 + eccentricity * cos(theta));
    
    % Convert to 3D Cartesian Coordinates
    x_orbit = r .* (cos(RAAN) .* cos(theta + argPerigee) - sin(RAAN) .* sin(theta + argPerigee) .* cos(inclination));
    y_orbit = r .* (sin(RAAN) .* cos(theta + argPerigee) + cos(RAAN) .* sin(theta + argPerigee) .* cos(inclination));
    z_orbit = r .* (sin(theta + argPerigee) .* sin(inclination));

    % Plot the orbit (solid line)
    orbit_handles(idx) = plot3(x_orbit, y_orbit, z_orbit, 'Color', colors{idx}, 'LineWidth', 1.5);
    
    % Create a scatter plot handle for the debris (initial position)
    debris_handles(idx) = plot3(x_orbit(1), y_orbit(1), z_orbit(1), 'o', 'MarkerSize', 6, 'MarkerFaceColor', colors{idx});
end

% Add legend for debris names
legend([orbit_handles, debris_handles], [debris_names, strcat(debris_names, ' (Initial)')], 'Location', 'best');

% Set the duration of the animation (60 seconds for 1 minute)
duration = 60; % in seconds
frames = 100; % Number of frames
time_step = duration / frames; % Time between frames

% 3D view
view(3);
axis([-10000 10000 -10000 10000 -10000 10000]);

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

        % Update the position of the current debris
        set(debris_handles(idx), 'XData', x, 'YData', y, 'ZData', z);
    end
    
    % Pause for the time step to control animation speed
    pause(time_step);
end

hold off;
