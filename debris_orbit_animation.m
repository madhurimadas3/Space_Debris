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
    semi_major_axis = semi_major_axes(idx);
    eccentricity = eccentricities(idx);
    RAAN = deg2rad(RAANs(idx));
    argPerigee = deg2rad(argPerigees(idx));
    inclination = deg2rad(inclinations(idx));

    % Generate True Anomaly values for plotting the full orbit (fixed)
    theta = linspace(0, 2*pi, 500);
    r = (semi_major_axis * (1 - eccentricity^2)) ./ (1 + eccentricity * cos(theta));
    x_orbit = r .* (cos(RAAN) .* cos(theta + argPerigee) - sin(RAAN) .* sin(theta + argPerigee) .* cos(inclination));
    y_orbit = r .* (sin(RAAN) .* cos(theta + argPerigee) + cos(RAAN) .* sin(theta + argPerigee) .* cos(inclination));
    z_orbit = r .* (sin(theta + argPerigee) .* sin(inclination));
    
    % Plot the orbit and initial position
    orbit_handles(idx) = plot3(x_orbit, y_orbit, z_orbit, 'Color', colors{idx}, 'LineWidth', 1.5);
    debris_handles(idx) = plot3(x_orbit(1), y_orbit(1), z_orbit(1), 'o', 'MarkerSize', 6, 'MarkerFaceColor', colors{idx});
end

% Add legend
legend([orbit_handles, debris_handles], [debris_names, strcat(debris_names, ' (Initial)')], 'Location', 'best');

% Set animation parameters
duration = 60; % total animation time in seconds
frames = 100;  % number of frames
time_step = 2 * pi / frames;  % incremental angle step per frame
filename = 'orbit_animation.gif';  % Name of the GIF file

% Set 3D view and limits
view(3);
axis([-10000 10000 -10000 10000 -10000 10000]);

% Animate and save each frame to GIF
for t = 1:frames
    for idx = 1:length(debris_names)
        semi_major_axis = semi_major_axes(idx);
        eccentricity = eccentricities(idx);
        RAAN = deg2rad(RAANs(idx));
        argPerigee = deg2rad(argPerigees(idx));
        inclination = deg2rad(inclinations(idx));

        % Calculate current position based on the time step
        current_theta = t * time_step;  % Incremental angle for animation
        r = (semi_major_axis * (1 - eccentricity^2)) ./ (1 + eccentricity * cos(current_theta));
        x = r * (cos(RAAN) * cos(current_theta + argPerigee) - sin(RAAN) * sin(current_theta + argPerigee) * cos(inclination));
        y = r * (sin(RAAN) * cos(current_theta + argPerigee) + cos(RAAN) * sin(current_theta + argPerigee) * cos(inclination));
        z = r * (sin(current_theta + argPerigee) * sin(inclination));

        % Update debris position in the plot
        set(debris_handles(idx), 'XData', x, 'YData', y, 'ZData', z);
    end

    % Capture frame for GIF
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);

    % Write to GIF
    if t == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end

hold off;
