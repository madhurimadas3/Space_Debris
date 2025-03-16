% Create a VideoWriter object to save the animation as a video
video = VideoWriter('debris_orbit_animation.mp4', 'MPEG-4');
video.FrameRate = 30; % Set the frame rate
open(video); % Open the video for writing

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
    
    % Capture the current frame and write it to the video file
    frame = getframe(gcf); % Capture the figure as a frame
    writeVideo(video, frame); % Write the frame to the video
    
    % Pause for the time step to control animation speed
    pause(time_step);
end

% Close the video file
close(video);

hold off;
