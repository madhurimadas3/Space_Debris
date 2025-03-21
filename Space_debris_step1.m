% Clear previous data every single time
clc; clear; close all;
%% Read and parse TLE data in MATLAB
% Open and read a TLE file
tle_files = {'cosmos-1408-debris.txt', 'cosmos-2251-debris.txt', 'fengyun-1c-debris.txt', 'iridium-33-debris.txt'}; 
debris_names = {'cosmos-1408','cosmos-2251', 'fengyun-1c','iridium-33'};
colors = {'r','b','g','m'};

figure; hold on;axis equal; grid on; 

% Loop for each file
for idx = 1:length((tle_files));
    filename=tle_files{idx};

    % open & read tle files
    fileID = fopen(filename,'r');

    % debugging 
   if fileID == -1
    warning('Error opening file: %s. skipping...', filename);
    continue;
   
   end
   tle_data = textscan(fileID, '%s', 'Delimiter', '\n');
   fclose(fileID);
   
   % debugging
   if length(tle_data{1}) < 3
    error('TLE file does not have enough lines.');
   end

% Extract lines
line1 = tle_data{1}{2}; % First data line
line2 = tle_data{1}{3}; % Second data line

% Extract orbital elements from TLE Line 2
inclination = str2double(line2(9:16));      % Inclination (degrees)
RAAN = str2double(line2(18:25));            % Right Ascension of Ascending Node (degrees)
eccentricity = str2double(['0.' line2(27:33)]); % Eccentricity (decimal)
argPerigee = str2double(line2(35:42));      % Argument of Perigee (degrees)
meanAnomaly = str2double(line2(44:51));     % Mean Anomaly (degrees)
meanMotion = str2double(line2(53:63));      % Mean Motion (revolutions per day)
    
   % debugging 
  % Check for NaN values
if any(isnan([inclination, RAAN, eccentricity, argPerigee, meanAnomaly, meanMotion]))
    warning('Some extracted orbital elements are NaN in file: %s. skipping...',filename);
    continue;
end
 
% Display extracted data
fprintf('Inclination: %.4f degrees\n', inclination);
fprintf('RAAN: %.4f degrees\n', RAAN);
fprintf('Eccentricity: %.7f\n', eccentricity);
fprintf('Argument of Perigee: %.4f degrees\n', argPerigee);
fprintf('Mean Anomaly: %.4f degrees\n', meanAnomaly);
fprintf('Mean Motion: %.8f rev/day\n', meanMotion);

%% Calculate Semi-major axis
mu = 398600.4418; % Earth's gravitational parameter (km^3/s^2)
n_rad = meanMotion * (2 * pi) / (24 * 3600); % Convert rev/day to rad/s
semi_major_axis = (mu / (n_rad^2))^(1/3); % Semi-major axis in km

fprintf('Semi-Major Axis: %.4f km\n', semi_major_axis);

%% Converting Orbital elements to Cartesian Coordinate and 3D orbit

% Convert degrees to radians
i = deg2rad(inclination);
RAAN = deg2rad(RAAN);
argPerigee = deg2rad(argPerigee);

% Generate True Anomaly values (0 to 360 degrees)
theta = linspace(0, 2*pi, 500);

% Compute orbit in polar coordinates
r = (semi_major_axis * (1 - eccentricity^2)) ./ (1 + eccentricity * cos(theta));

% Convert to 3D Cartesian Coordinates
x = r .* (cos(RAAN) .* cos(theta + argPerigee) - sin(RAAN) .* sin(theta + argPerigee) .* cos(i));
y = r .* (sin(RAAN) .* cos(theta + argPerigee) + cos(RAAN) .* sin(theta + argPerigee) .* cos(i));
z = r .* (sin(theta + argPerigee) .* sin(i));

% Plot the orbit
plot3(x, y, z, colors{idx}, 'LineWidth', 1.5);
end

% Plot Earth (for reference)
[xs, ys, zs] = sphere(30); % Create a sphere
surf(xs * 6371, ys * 6371, zs * 6371, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); % Scale to Earth radius

% Add legend for debris names
legend(debris_names, 'Location', 'best');

% Labels & Formatting
view(3);
xlabel('X (km)'); ylabel('Y (km)'); zlabel('Z (km)');
title('3D Space Debris Orbit');
hold off;
