function responseText = callChatGPT(prompt)
   
   loadEnv();
    apiKey = getenv('OPENAI_API_KEY');
    if isempty(apiKey)
        error('API key not found. Please check your .env file.');
    end


    url = 'https://api.openai.com/v1/chat/completions'; %responses for gpt-5

    headers = {
        'Authorization', ['Bearer ' apiKey];
        'Content-Type', 'application/json'
    };

    data = struct;
   % data.model = 'gpt-4'; %gpt-4o-mini, gpt-4o, gpt-4-turbo, gpt-4.1-mini
    data.model = 'gpt-4.1-mini';

    data.temperature = 0.8;
    %data.top_p = 0.9;
    data.messages = {
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

        if isstruct(rawResponse) && isfield(rawResponse, 'choices') && ...
           isstruct(rawResponse.choices) && isfield(rawResponse.choices(1), 'message')
            responseText = strtrim(rawResponse.choices(1).message.content);
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

