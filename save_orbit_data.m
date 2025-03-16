% save_orbit_data.m
clc; clear;

% Open and read TLE files
tle_files = {'cosmos-1408-debris.txt', 'cosmos-2251-debris.txt', 'fengyun-1c-debris.txt', 'iridium-33-debris.txt'}; 
debris_names = {'cosmos-1408','cosmos-2251', 'fengyun-1c','iridium-33'};

% Initialize arrays to store orbital data
semi_major_axes = [];
eccentricities = [];
RAANs = [];
argPerigees = [];
inclinations = [];

% Loop for each file
for idx = 1:length(tle_files)
    filename = tle_files{idx};

    % Open and read TLE file
    fileID = fopen(filename, 'r');
    
    if fileID == -1
        warning('Error opening file: %s. skipping...', filename);
        continue;
    end
    
    tle_data = textscan(fileID, '%s', 'Delimiter', '\n');
    fclose(fileID);
    
    % Extract orbital elements from TLE Line 2
    line2 = tle_data{1}{3}; % Second data line (Line 2 of TLE)
    
    % Extract the necessary orbital elements
    inclination = str2double(line2(9:16));      % Inclination (degrees)
    RAAN = str2double(line2(18:25));            % Right Ascension of Ascending Node (degrees)
    eccentricity = str2double(['0.' line2(27:33)]); % Eccentricity (decimal)
    argPerigee = str2double(line2(35:42));      % Argument of Perigee (degrees)
    meanMotion = str2double(line2(53:63));      % Mean Motion (revolutions per day)
    
    % Calculate the semi-major axis
    mu = 398600.4418; % Earth's gravitational parameter (km^3/s^2)
    n_rad = meanMotion * (2 * pi) / (24 * 3600); % Convert rev/day to rad/s
    semi_major_axis = (mu / (n_rad^2))^(1/3);   % Semi-major axis in km

    % Store the extracted data
    semi_major_axes = [semi_major_axes; semi_major_axis];
    eccentricities = [eccentricities; eccentricity];
    RAANs = [RAANs; RAAN];
    argPerigees = [argPerigees; argPerigee];
    inclinations = [inclinations; inclination];
end

% Save the data to a .mat file for future use
save('orbit_data.mat', 'semi_major_axes', 'eccentricities', 'RAANs', 'argPerigees', 'inclinations', 'debris_names');
