function [polarMatrix,OptAlpha] = run_xfoil(coords, Re, Mach, Ncrit, alpha_start, alpha_end)
    % Clean up old files

    if exist('polar.dat', 'file')
        delete('polar.dat');
    end
    if exist('airfoil.dat', 'file')
        delete('airfoil.dat');
    end
    if exist('xfoil_input.in', 'file')
        delete('xfoil_input.in');
    end

    % Write airfoil coordinates to file
    fid = fopen('airfoil.dat', 'w');
    fprintf(fid, 'AutoFoil\n');
    fprintf(fid, '%f %f\n', coords');
    fclose(fid);

    % Define angle sequence
    alpha_step = 0.25;
    alphas = (alpha_start:alpha_step:alpha_end)';

    % Create XFOIL command input file with higher iteration limit
fid = fopen('xfoil_input.in', 'w');
fprintf(fid, 'LOAD airfoil.dat\n');
fprintf(fid, 'PPAR\n\n');
fprintf(fid, 'OPER\n');
fprintf(fid, 'M %.3f\n', Mach);        % Set Mach number
fprintf(fid, 'VPAR\n');                % Enter boundary layer parameter menu
fprintf(fid, 'N %.1f\n', Ncrit);       % Set Ncrit value
fprintf(fid, '\n');                    % Return to OPER menu
fprintf(fid, 'VISC %.0f\n', Re);
fprintf(fid, 'ITER 300\n');            % Increased iteration limit
fprintf(fid, 'PACC\n');
fprintf(fid, 'polar.dat\n\n');
fprintf(fid, 'ASEQ %.2f %.2f %.2f\n', alpha_start, alpha_end, alpha_step);
fprintf(fid, 'QUIT\n');
fclose(fid);

    % Run XFOIL
    if ispc
    system('xfoil.exe < xfoil_input.in');
    else
    system('./xfoil < xfoil_input.in');
    end

    % Read XFOIL output, skipping header lines (typically 12)
    try
        data = readmatrix('polar.dat', 'FileType', 'text', 'NumHeaderLines', 12);
        % data columns: alpha, Cl, Cd, ...
        output_alphas = data(:,1);
        polarMatrix_raw = data(:,[1 2 3]); % [alpha, Cl, Cd]
    catch
        warning('Failed to read polar.dat or file is empty.');
        polarMatrix = [];
        return;
    end

    % Fill missing angles with closest known value
    polarMatrix = zeros(length(alphas), 3);
    for i = 1:length(alphas)
        idx = find(abs(output_alphas - alphas(i)) < 1e-6, 1);
        if ~isempty(idx)
            polarMatrix(i,:) = polarMatrix_raw(idx,:);
        else
            % Find the closest known value
            [~, closest_idx] = min(abs(output_alphas - alphas(i)));
            polarMatrix(i,1) = alphas(i); % Use the requested alpha
            polarMatrix(i,2:3) = polarMatrix_raw(closest_idx,2:3); % Copy Cl, Cd
        end
    end
    [Val, IndexVal] = max(polarMatrix(:,2)./polarMatrix(:,3));
    OptAlpha = polarMatrix(IndexVal,1);
end