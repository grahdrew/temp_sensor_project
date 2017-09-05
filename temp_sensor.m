%% Arduino Project - Temperature Sensor Receive
% * Authors: The Temp Sensor Group
% * Course: ENGR114
% * Date: Sept 4, 2017
% * Description: This script gives the user the option to send data to the IoT at ThingSpeak.org, or retrieve temperature sensor data from
% ThingSpeak and plot it to a graph.

%%  Clear All Variables/Command Window/Close Windows

clc
clear 
close all
delete(instrfindall);       % Clears any existing serial ports


%% Send Data
user_sendreceive = [];      
while (1)
   user_sendreceive = input('Please enter "send" or "retrieve":  ','s');
    if strcmp(user_sendreceive,'send')
 
                %% Open The Serial Port To Connect To The Arduino
                % Check the serial port that the Arduino is connected to by:
                % Going to the Control Panel --> Hardware and Sound --> Devices and Printers
                % and right click: FT231X USB UART, select Properties and then look under
                % Hardware Tab

                % Change 'COM4' to whichever port the arduino is connected to.
                
                user_port = input('Please enter serial port value (usually either COM4 or other):  ','s')
                arduino = serial(user_port, 9600);    % Creates a serial connection via user_port

                %% Ask user for how much data to write
                points_or_time = []                                                                                                                % intializes variable
                while(1)                                                                                                                                 % while true loop
                points_or_time = input('Input "n" for number of data points, or "t" for amount of time: ','s');          % prompts for user input
                write_rate = 20;                                                                                                                     % writes data every 20 seconds
                disp('Data writes at a rate of about 20 sec each');                                                                     % prints to command
                
                    if points_or_time == 'n'                                                                                                       % if statement for user input
                        data_points = input('Enter the number of data points you want to write: ');                          % prompts for number of data points
                        break                                                                                                                            % breaks while loop
                    elseif points_or_time == 't'                                                                                                  % alternative if statement for user input                            
                        time_to_run = input('Enter the number of minutes you want to write data: ');                        % prompts for amount of time in minutes
                        % since the write happens before the pause, the data points possible in
                        % a given time period will include a final data write within the time
                        % specification and the pause lasting past the time period
                        data_points = round(time_to_run*60/write_rate) + 1;  
                        break                                                                                                                       % breaks while loop
                    else                                                                                                                              % else for if what is entered does not match criteria
                        disp('Please enter either n or t')
                    end                                                                                       % end if statement
                end                                                                                           % end while loop

                %% Send the Serial Data to the IoT (Thingspeak) with a Web API Call

                ThingSpeak_channel = '318597';                % Needs to be a string
                Write_API_Key= 'SBV3R3WDH1313XMQ';     % Needs to be a string, 2nd part

                serial_data = [];
                for i = 1:data_points                                         % for loop index for data points
                    fopen(arduino);                                             % opens info from arduino
                    serial_read = fscanf(arduino,'%f');                  % reads serial data
                    fclose(arduino);                                             % Closes arduino serial channel

                    serial_data(end+1) = serial_read;
                    current_data_point = num2str(serial_read);     % Needs to be a string

                    thingSpeakWriteURL = 'https://api.thingspeak.com/update'; % 1st part of url to write to IoT
                    data = ['api_key=',Write_API_Key,'&field1=',current_data_point]; % 3rd part of url to write to IoT
                    url = [thingSpeakWriteURL data];
                    response = webwrite(thingSpeakWriteURL,data);


                    % Show the User API Call and IoT Response
                    disp(['Using ThingSpeak Channel: ', ThingSpeak_channel]) 
                    disp(['Using Write API Key: ', Write_API_Key])
                    disp(['Using Data Point: ', current_data_point])
                    disp(['Sent API request: ',url])
                    pause(2) % Wait 2 seconds for the response, ThingSpeak.com's response is not instant
                    disp(['Request Successful! Data Saved as entry ID: ',response, char(10)])

                    pause(15)
                end

                %% Plots a Nice Graph

                figure(1);                                                   % Assigns to the second plot window
                t = linspace(1,data_points,data_points);      % Creates new variable for time that looks better for graphing
                Z = plot(t, serial_data);                               % Plots the serial_data from above vs the new time variable

                max_data = round(max(serial_data),4);      % set max_data to the rounded max(data) to prevent comparison issues
                min_data = round(min(serial_data),4);        % set min_data to the rounded min(data) to prevent comparison issues
                range = max_data - min_data;                  % calculate range by subtracting max_data from min_data
            max_range = max_data + .05 * range;           % set max_range to 5% of range added to max_data
            min_range = min_data - .05 * range;              % set min_range to 5% of range subtracted from min_data

            % an if statement is required to check for the case that the range would be 
            % 0 and the limits of the y-axis would be impossible
            % when the range is 0, standard ylim is used
            if range ~= 0   
                ylim([min_range, max_range])    
            end

            % Additions to the graph for reference and identification
            xlabel('Time (Seconds)');                    % x-axis label
            ylabel('Temperature (Fahrenheit)');     % y-axis label
            title('Temperature vs. Time');             % Inserts a title to the plot
            legend('Temperature');                      % Adds a legend to the plot 

            grid;                                                 % Turns on grid

            %% Display when finished

            disp('Data collection complete!')           % displays when data collection loop is complete

      break                 %breaks while loop
%% Retrieve Data

    elseif strcmp(user_sendreceive, 'retrieve')
    
            %% Ask user for number of data points to retrieve
            data_points = user_input_temp_sensor();             % prompt for data points
            data_points_str = num2str(data_points);              % convert to string

            %% Retrieve the Serial Data from the IoT (Thingspeak) with a Web API Call

            response = web_api_temp_sensor(data_points_str);            % run web_api_temp_sensor function

            %% Clean structure array data into matrix data to be used in plot

            clean_data = clean_data_temp_sensor(response, data_points);     % run clean_data_temp_sensor function


            %% Show the User API Call and IoT Response
            ThingSpeak_channel = '318597';          % defines channel number on IoT

            disp(['Using ThingSpeak Channel: ', ThingSpeak_channel])        % print to screen
            disp(['Using Data Point: ', data_points_str])                             % print to screen
            disp(['Receive API request: ',num2str(clean_data')])                 % print to screen
            pause(1) % wait 1 second for the response, ThingSpeak.com's response is not instant

            %% Plots a Nice Graph
            plot_data_temp_sensor(clean_data);          % run plot data function

            break   %  break loop
    else
        disp('Please re-enter choice')      %if choice does not match criteria, restart loop
        
    end             % end if statement
end                 % end while loop



%% Define Functions:
        %%  Clean Data Function

        function [ clean_data ] = clean_data_temp_sensor( response, data_points )
        %clean_data_temp_sensor This function takes two inputs: a response from thingspeak.com 
        %with a structure array and a number of data points also designated by the user.
        %It returns data that's been "cleaned" in a standard verticle matrix that's easy to plot with.
        %   The url input requires a very specific structure to access the proper data that is being
        %   filtered and cleaned. 

        %   response = webread('https://api.thingspeak.com/channels/318597/fields/1.json?results=5')
        %   data_points = 5;
        %   
        %   clean_data =    
        %                   80.2900
        %                   78.5300
        %                   77.7400
        %                   82.2200
        %                   79.4800

        clean_data = zeros(1,data_points)';         % initialize clean_data matrix with zeros filled up to num_results input
        for i = 1:data_points                       % create for loop to write data points to increasing indicies in clean_data matrix
            % set clean_data indicies to a number created by str2num fucntion of the url_data structure
            % array, by taking the structure array at the corresponding indice using the field_str variable
            % to call the proper field
            clean_data(i) = str2num(response.feeds(i).field1);
        end

        end

        %% Plot Data Function

        function [] = plot_data_temp_sensor( clean_data )
        %plot_data_temp_sensor This function plots the inputted clean_data points versus
        %the data point number.
        % 
        % This function uses several check throughout to determine the best plot
        % setup in varying input situations. For example, when only 1 input is
        % requested, the format of the plot switches to points of marker size 14 so
        % that the data actually shows on the graph. Also, the y limits of the plot
        % adapt to the range of the data, so when the range is 0, the plot reverts
        % to standard y limits.
        %
        % clean_data is column vector of data

        figure(1)                           % create figure window

        % this if statement is required in the case of a user inputting only 1 data
        % value, where the plot must show a dot at that point, in comparison to
        % multiple data points where a simple line is used as coded in the else
        % portion of the if statement
        if numel(clean_data) == 1
            plot(clean_data,'.','MarkerSize',14)
        else
            plot(clean_data)
        end

        max_data = round(max(clean_data),4);% set max_data to the rounded max(clean_data) to prevent comparison issues
        min_data = round(min(clean_data),4);% set min_data to the rounded min(clean_data) to prevent comparison issues
        range = max_data - min_data;        % calculate range by subtracting max_data from min_data
        max_range = max_data + .05 * range; % set max_range to 5% of range added to max_data
        min_range = min_data - .05 * range; % set min_range to 5% of range subtracted from min_data

        % an if statement is required to check for the case that the range would be 
        % 0 and the limits of the y-axis would be impossible
        % when the range is 0, standard ylim is used
        if range ~= 0   
            ylim([min_range, max_range])    
        end

        % Additions to the graph for reference and identification
        xlabel('Time (Seconds)');           % x-axis label
        ylabel('Temperature (Fahrenheit)'); % y-axis label
        title('Temperature vs. Time');      % Inserts a title to the plot
        grid;                               % Turns on grid

        end

        %% User Input Function

         function [ data_points ] = user_input_temp_sensor()
        %user_input_temp_sensor This function will validate the user input as well 
        %as including error checking to ensure proper inputs are chosen.
        %
        % Function should be called in the command line like this: 
        %                   ** data_points = user_input_temp_sensor()**

        % ask the user for the number of data points they would like to see,
        % ranging from 1 to 8000
        data_points = input('Enter the desired number of data points (1 to 8000): ');

        % create while loop to check for approved number of points inputted and
        % ask the user again for an approved number of points if out of range
        while ~(data_points <= 8000 && data_points >= 1);
            data_points = input('Enter a positive integer less than or equal to 8000: ');
        end

        % inform user that a valid input was received.
        disp([num2str(data_points),' is Valid'])

         end

        %% Web API Function

         function [ response ] = web_api_temp_sensor( data_points_str )
        %web_api_temp_sensor This function pulls data string from the user input in  
        %order to find specific data from thingspeak.

        %   This function will pull the data from the IoT on Thingspeak in order to
        %   populate a matrix, based on user_input, and output that matrix as
        %   response.
        %
        % Input:  data_points_str    => user input on the number of points we want
        %                                       to receive in string format
        %
        % Output: response        => json file with requested data

        ThingSpeak_channel = '318597';         

        thingSpeakReadURL = 'https://api.thingspeak.com/channels/'; 
        field_data = [ThingSpeak_channel, '/fields/1.json?results=',data_points_str]; 
        url = [thingSpeakReadURL field_data];
        response = webread(url);

        end
