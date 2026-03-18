function done = LLMPatch_State(state, rt, stateIndex, logger)

    done = false;
    originalLabel = strtrim(state.LabelString);

    %variable extraction
    data_faulty = rt.find('-isa', 'Stateflow.Data');
    inputs     = data_faulty(strcmp({data_faulty.Scope}, 'Input'));
    outputs    = data_faulty(strcmp({data_faulty.Scope}, 'Output'));
    locals     = data_faulty(strcmp({data_faulty.Scope}, 'Local'));
    parameters = data_faulty(strcmp({data_faulty.Scope}, 'Parameter'));
    constants  = data_faulty(strcmp({data_faulty.Scope}, 'Constant'));

    inputNames  = strjoin(string({inputs.Name}), ', ');
    outputNames = strjoin(string({outputs.Name}), ', ');
    localNames  = strjoin(string({locals.Name}), ', ');
    paramNames  = strjoin(string({parameters.Name}), ', ');
    constNames  = strjoin(string({constants.Name}), ', ');

    variableContext = sprintf([ ...
        '- Inputs: %s\n' ...
        '- Outputs: %s\n' ...
        '- Locals: %s\n' ...
        '- Parameters: %s\n' ...
        '- Constants: %s\n'], ...
        inputNames, outputNames, localNames, paramNames, constNames);

    try
        fewshotExamples = fileread("fewshot_states.json");
        fewshotExamples = sprintf('--- Illustrative Examples (for guidance only, do not copy directly) ---\n%s\n--- End of Examples ---', fewshotExamples);
    catch
        warning('fewshot_states.json not found. Continuing without examples.');
        fewshotExamples = '';
    end

    promptTemplate = strjoin({
        'You are a Stateflow repair assistant. Your task is to repair the condition labels of states in a Stateflow model.\n', ...
        'Always provide a change because the state is highly likely to be buggy.',...
        '--- Context ---\n', ...
        'State name: "%s"\n', ...
        'Current label:\n"%s"\n', ...
        'Available variables (use ONLY these, do not invent new ones):\n%s\n\n', ...
        '--- Repair Instructions ---\n', ...
        '1. If the label contains (entry:/during:/exit:) preserve them but you can replace them or can keep the same as in given label.\n', ...
        '2. Examples of mutations include, but are not limited to these:\n', ...
        '   - Replace wrong numeric values (1 <-> -1, 10 <-> 15 etc).\n', ...
        '   - Replace wrong boolean values (true <-> false) (0 <-> 1).\n', ...
        '   - Replace wrong assignment expressions (e.g., HOT = TEMPERATURE + REF <-> HOT = 0 or HOT = 1).\n', ...
        '   - Insert or delete a variable if required.\n', ...
        '3. Do NOT invent new variables.\n', ...
        '4. Only return the repaired action/condition.\n', ...
        '5. Ensure the result is compilable in MATLAB Stateflow.\n', ...
        '--- Output Format ---\n', ...
        'STRICT JSON:\n', ...
        '{ "patch": "<patched label here>" }\n\n', ...
        '--- Few-Shot Examples ---\n', ...
        '%s\n', ...
    }, '');

    prompt = sprintf(promptTemplate, char(state.Name), originalLabel, variableContext, fewshotExamples);

    try
        fprintf('\nState %d: "%s"\n', stateIndex, originalLabel);
        gptResponse = callChatGPT(prompt);

        match = regexp(gptResponse, '"patch"\s*:\s*"([^"]+)"', 'tokens', 'once');
        if ~isempty(match)
            newAction = strtrim(match{1});
            newAction = strrep(newAction, '\n', newline);
            newAction = strrep(newAction, '\t', '    ');

            if contains(lower(newAction), 'during:') || ...
               contains(lower(newAction), 'entry:')  || ...
               contains(lower(newAction), 'exit:')
                newLabelFull = newAction;
            else
                if contains(originalLabel, 'during:')
                    newLabelFull = regexprep(originalLabel, '(?<=during:\s*)(.*?);', newAction, 'once');
                elseif contains(originalLabel, 'entry:')
                    newLabelFull = regexprep(originalLabel, '(?<=entry:\s*)(.*?);', newAction, 'once');
                elseif contains(originalLabel, 'exit:')
                    newLabelFull = regexprep(originalLabel, '(?<=exit:\s*)(.*?);', newAction, 'once');
                else
                    newLabelFull = newAction;
                end
            end

            if ~startsWith(strtrim(newLabelFull), char(state.Name))
                newLabelFull = char(state.Name) + newline + newLabelFull;
            end

            if isempty(newLabelFull) || ...
               count(newLabelFull, '(') ~= count(newLabelFull, ')') || ...
               count(newLabelFull, '[') ~= count(newLabelFull, ']') || ...
               length(newLabelFull) > 500
                fprintf('LLM produced invalid patch, rejected.\n');
                logger.log(stateIndex, originalLabel, true, false, "");
                return;
            end

            if ~strcmp(originalLabel, newLabelFull)
                fprintf('LLM detected a Fault\n');
                fprintf('LLM provided patch: "%s"\n', newLabelFull);
                state.LabelString = newLabelFull;
                done = true;
                logger.log(stateIndex, originalLabel, true, true, newLabelFull);
            else
                fprintf('LLM did not change the label\n');
                logger.log(stateIndex, originalLabel, false, false, "");
            end

        else
            fprintf('LLM did not detect a Fault \n');
            logger.log(stateIndex, originalLabel, false, false, "");
        end

    catch ME
        disp('GPT call or patch application failed.');
        logger.log(stateIndex, originalLabel, false, false, "");
    end
end

