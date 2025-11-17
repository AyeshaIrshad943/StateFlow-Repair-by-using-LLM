function loadEnv()
% loadEnv - Reads .env file and sets environment variables in MATLAB

    envFile = '.env';

    if ~isfile(envFile)
        warning('.env file not found in current folder: %s', pwd);
        return;
    end

    fid = fopen(envFile, 'r');
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if isempty(line) || startsWith(line, '#')
            continue; % skip empty or commented lines
        end
        if contains(line, '=')
            parts = split(line, '=');
            if numel(parts) == 2
                key = strtrim(parts{1});
                value = strtrim(parts{2});
                setenv(key, value);
            end
        end
    end
    fclose(fid);
end
