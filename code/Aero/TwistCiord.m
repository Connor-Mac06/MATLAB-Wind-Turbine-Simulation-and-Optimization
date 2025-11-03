clear
clc

% Load data
chord_data_raw = struct2array(load('Chord2.mat'));
twist_data_raw = struct2array(load('Twist2.mat'));

% Extract radii and values
radii = chord_data_raw(1, :);       % radial positions (same for both datasets)
chord_dat = chord_data_raw(2, :);   % chord values
twist_dat = twist_data_raw(2, :)+6;   % twist values

% Function to interpolate chord and twist at a given radius
function [chord, twist] = getInterpolatedValues(radius, radii, chord_dat, twist_dat)
    % Check that the input radius is within bounds
    if radius < min(radii) || radius > max(radii)
        error('Radius is out of bounds. It must be between %.3f and %.3f.', min(radii), max(radii));
    end

    % Interpolation
    chord = interp1(radii, chord_dat, radius, 'linear');
    twist = interp1(radii, twist_dat, radius, 'linear');
end

% Example usage
radius_input = 0.245; % Replace with your desired radius
[chord_val, twist_val] = getInterpolatedValues(radius_input, radii, chord_dat, twist_dat);

fprintf('At radius %.3f m:\n', radius_input);
fprintf('Interpolated chord = %.4f m\n', chord_val);
fprintf('Interpolated twist = %.4f degrees\n', twist_val);

plot(radii, chord_data_raw)

load('Chord2.mat');  % Load the .mat file containing the variable 'Chord2'

% Add 1 to columns 1 to 28 of the second row
Chord2(2, 1:28) = Chord2(2, 1:28);

% Add 2 to columns 29 to 216 of the second row
Chord2(2, 29:216) = Chord2(2, 29:216);

nChord = Chord2  % Save as a new array named 'nChord'
save('nChord.mat', 'nChord');  % Save the modified variable under the new name

load('nChord.mat');  % Optional: load the modified file back into workspace