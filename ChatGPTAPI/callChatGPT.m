function responseText = callChatGPT(prompt) 
   
   loadEnv();
    apiKey = getenv('OPENAI_API_KEY');
    if isempty(apiKey)
        error('API key not found. Please check your .env file.');
    end

    %  url = 'https://api.openai.com/v1/chat/completions';
    url = 'https://api.openai.com/v1/responses'; 
    
    headers = {
        'Authorization', ['Bearer ' apiKey];
        'Content-Type', 'application/json'
    };

  % data = struct;
  % data.model = 'gpt-5.4-mini'; % 'gpt-4.1-mini';
  % data.temperature = 0.8; % for gpt 4.1 mini and 5.1 mini
   %data.top_p = 0.9;


   data.model = 'gpt-5.5';
   data.input = prompt;
   %data.reasoning = struct('effort', 'low'); %for GPT 5.5
   data.reasoning = struct('effort','none');
   data.text = struct('verbosity','low');
   data.temperature = 0.8;


    % for Chat completions
    % data.messages = {
    %     struct('role', 'system', 'content', 'You are a helpful AI repairing Stateflow models.'), ...
    %     struct('role', 'user', 'content', prompt)
    % };

    %for responses API
    data.input = {
        struct('role', 'system', 'content', 'You are a helpful AI repairing Stateflow models.'), ...
        struct('role', 'user', 'content', prompt)
    };

    options = weboptions( ...
        'HeaderFields', headers, ...
        'MediaType', 'application/json', ...
        'Timeout', 60);

    try
        disp('Sending prompt to ChatGPT...');
        disp('------------------------');


        rawResponse = webwrite(url, data, options);

        %for Chat completions:
        % if isstruct(rawResponse) && isfield(rawResponse, 'choices') && ...
        %    isstruct(rawResponse.choices) && isfield(rawResponse.choices(1), 'message')
        %     responseText = strtrim(rawResponse.choices(1).message.content);
        %     responseText = strrep(responseText, newline, '');
        %     responseText = strtrim(responseText);
        % 
        %     disp('GPT Response :');
        %     disp(responseText);
        %     disp('------------------------');
        % else
        %     disp('Unexpected response format.');
        %     disp(rawResponse);
        %     responseText = '';
        % end

        % for responses API
        if isstruct(rawResponse) && isfield(rawResponse, 'output')
            responseText = '';

            for i = 1:numel(rawResponse.output)
                if isfield(rawResponse.output(i), 'content')
                    for j = 1:numel(rawResponse.output(i).content)
                        if isfield(rawResponse.output(i).content(j), 'text')
                            responseText = [responseText rawResponse.output(i).content(j).text];
                        end
                    end
                end
            end

            responseText = strtrim(responseText);
            responseText = strrep(responseText, newline, '');
            responseText = strtrim(responseText);

            disp('GPT Response :');
            disp(responseText);
            disp('------------------------');
        else
            disp('Unexpected response format.');
            disp(rawResponse);
            responseText = '';
        end

    catch ME
        disp(' Error contacting ChatGPT API:');
        disp([' ', ME.message]);
        responseText = '';
    end
end 