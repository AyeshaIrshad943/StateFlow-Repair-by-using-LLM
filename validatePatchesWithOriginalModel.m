function validatePatchesWithOriginalModel(correctModel, ValidatedPatches, validatedDir, executeTest)
    validated = {};
    validatedPatchCount = 0;

    % init log table
    logData = table( ...
        strings(0,1), false(0,1), nan(0,1), nan(0,1), false(0,1), datetime.empty(0,1), ...
        'VariableNames', {'ModelName', 'IsValid', 'TimeDiff', 'CriticalityDiff', 'VerdictMatch', 'Timestamp'} ...
    );

    if isempty(ValidatedPatches)
        disp('No validated patches found to validate.');
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        xlsxFile  = fullfile(validatedDir, ['ValidationResults_' timestamp '.xlsx']);   % <--- save to validatedDir
        try
            writetable(logData, xlsxFile);
            fprintf('\n Excel Validation log saved: %s\n', xlsxFile);
        catch
            csvFile = fullfile(validatedDir, ['ValidationResults_' timestamp '.csv']); % <--- save to validatedDir
            warning('Failed to write Excel file. Saving as CSV instead.');
            writetable(logData, csvFile);
        end
        return;
    end

    % helper to append row
    function appendRow(modelPath, isValid, tDiff, cDiff, vMatch)
        logData(end+1, :) = {string(modelPath), logical(isValid), double(tDiff), double(cDiff), logical(vMatch), datetime("now")};
    end

    isCell = iscell(ValidatedPatches);

    % drop numeric junk
    if isCell
        badMask = cellfun(@isnumeric, ValidatedPatches);
        if any(badMask)
            fprintf('Dropping %d numeric entries from ValidatedPatches.\n', sum(badMask));
            ValidatedPatches = ValidatedPatches(~badMask);
        end
    end

    for i = 1:length(ValidatedPatches)
        if isCell
            item = ValidatedPatches{i};
        else
            item = ValidatedPatches(i);
        end

        if isstruct(item)
            if ~isfield(item, 'modelName') || isempty(item.modelName)
                warning('ValidatedPatches{%d} struct missing field "modelName". Skipping.', i);
                appendRow("<missing-modelName>", false, NaN, NaN, false);
                continue;
            end
            modelPath = item.modelName;
        elseif ischar(item) || (isstring(item) && isscalar(item))
            modelPath = char(item);
        else
            warning('ValidatedPatches{%d} is %s, expected struct or string model path. Skipping.', i, class(item));
            appendRow("<invalid-item>", false, NaN, NaN, false);
            continue;
        end

        modelFile = [modelPath '.slx'];

        try
            if ~isfile(modelFile)
                warning('File not found: %s', modelFile);
                appendRow(modelPath, false, NaN, NaN, false);
                continue;
            end

            bdclose('all');
            open_system(correctModel, 'loadonly');
            [verdictCorrect, timeCorrect, critCorrect, ~] = executeTest(correctModel);

            open_system(modelPath, 'loadonly');
            [verdictPatch, timePatch, critPatch, ~] = executeTest(modelPath);

            verdictMatch = isequal(verdictCorrect, verdictPatch);
            timeDiff     = abs(timePatch - timeCorrect);
            critDiff     = abs(critPatch - critCorrect);
            isValid      = verdictMatch && timeDiff < 1e-3 && critDiff < 1e-3;

            appendRow(modelPath, isValid, timeDiff, critDiff, verdictMatch);

            if isValid
                disp(['Patch validated: ', modelPath]);
                validatedPatchCount = validatedPatchCount + 1;
                validated{validatedPatchCount} = struct( ...
                    'modelName',   modelPath, ...
                    'verdict',     verdictPatch, ...
                    'timeVerdict', timePatch, ...
                    'criticality', critPatch, ...
                    'timestamp',   datetime('now') ...
                );
                [~, baseName, ~] = fileparts(modelPath);
                copyfile(modelFile, fullfile(validatedDir, [baseName '.slx']));
            else
                disp(['Patch failed validation: ', modelPath]);
            end

        catch ME
            disp(['Validation error for model ', modelPath]);
            disp(getReport(ME));
            appendRow(modelPath, false, NaN, NaN, false);
        end
    end

    % save validated patches list to validatedDir
    save(fullfile(validatedDir, 'validated_and_confirmed_patches.mat'), 'validated');

    % write logs into validatedDir
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    xlsxFile  = fullfile(validatedDir, ['ValidationResults_' timestamp '.xlsx']);
    try
        writetable(logData, xlsxFile);
        fprintf('\n Excel Validation log saved: %s\n', xlsxFile);
    catch
        csvFile = fullfile(validatedDir, ['ValidationResults_' timestamp '.csv']);
        warning('Failed to write Excel file. Saving as CSV instead.');
        writetable(logData, csvFile);
    end

    fprintf('Rows written: %d (validated: %d)\n', height(logData), validatedPatchCount);
end
