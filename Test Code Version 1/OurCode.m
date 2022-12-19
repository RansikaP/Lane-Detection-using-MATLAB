clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
fontSize = 22;
timeArray = zeros(1, 99);
i=1;

folder = fileparts(which('Lane Detection Test.mp4')); % Determine where demo folder is (works with all versions).
movieFullFileName = fullfile(folder, 'Lane Detection Test.mp4');

if ~exist(movieFullFileName, 'file')
	strErrorMessage = sprintf('File not found:\n%s\nYou can choose a new one, or cancel', movieFullFileName);
	response = questdlg(strErrorMessage, 'File not found', 'OK - choose a new movie.', 'Cancel', 'OK - choose a new movie.');
	if strcmpi(response, 'OK - choose a new movie.')
		[baseFileNameNoExt, folderName, FilterIndex] = uigetfile('*.avi');
		if ~isequal(baseFileNameNoExt, 0)
			movieFullFileName = fullfile(folderName, baseFileNameNoExt);
		else
			return;
		end
	else
		return;
	end
end

try 
    videoReaderObject = VideoReader(movieFullFileName);
    numberOfFrames = videoReaderObject.NumFrames;
	vidHeight = videoReaderObject.Height;
	vidWidth = videoReaderObject.Width;

    numberOfFramesWritten = 0;
    hFig = figure('Name', 'Video Demo by Image Analyst', 'NumberTitle', 'Off');
    hFig.WindowState = 'maximized';

    promptMessage = sprintf('Do you want to save the individual output frames out to individual disk files?');
	button = questdlg(promptMessage, 'Save individual frames?', 'Yes', 'No', 'Yes');
    
    if contains(button, 'Yes')
		writeToDisk = true;
		
		% Extract out the various parts of the filename.
		[folder, baseFileNameNoExt, extension] = fileparts(movieFullFileName);
		% Make up a special new output subfolder for all the separate
		% movie frames that we're going to extract and save to disk.
		% (Don't worry - windows can handle forward slashes in the folder name.)
		folder = pwd;   % Make it a subfolder of the folder where this m-file lives.
		outputFolder = sprintf('%s/Movie Frames from %s', folder, baseFileNameNoExt);
		% Create the folder if it doesn't exist already.
		if ~exist(outputFolder, 'dir')
			mkdir(outputFolder);
		end
	else
		writeToDisk = false;
    end

    for frame = 1 : numberOfFrames
        thisFrame = read(videoReaderObject, frame);

        hImage = subplot(2, 2, 1);
		image(thisFrame);
		caption = sprintf('Frame %4d of %d.', frame, numberOfFrames);
		title(hImage, caption, 'FontSize', fontSize);
		axis('on', 'image');
        drawnow;

        %tic
        grayImage = rgb2gray(thisFrame);
        bwImage = imbinarize(grayImage);
        subplot(2, 2, 2);
		imshow(bwImage);
		title('Gray Scale Image', 'FontSize', fontSize);
		axis('on', 'image');
        
        if writeToDisk
 			progressIndication = sprintf('Wrote frame %4d of %d.', frame, numberOfFrames);
 		else
 			progressIndication = sprintf('Processed frame %4d of %d.', frame, numberOfFrames);
        end
		disp(progressIndication);

        numberOfFramesWritten = numberOfFramesWritten + 1;
        edgeImage = edge(bwImage, 'canny');
		edgeImage = uint8(255 * edgeImage);
        %timeArray(i) = toc;
        %i = i+1;

        subplot(2, 2, 3);
		imshow(edgeImage);
		title('Canny Edge Image', 'FontSize', fontSize);
		axis('on', 'image');

        %outputFrame = [thisFrame, thisFrame; cat(3, bwImage, bwImage, bwImage), edgeImage];
        outputFrame = edgeImage;

        if writeToDisk
			% Construct an output image file name.
			outputBaseFileName = sprintf('Frame %4.4d.png', frame);
			outputFullFileName = fullfile(outputFolder, outputBaseFileName);
			
			% Write it out to disk.
			imwrite(outputFrame, outputFullFileName, 'png');
        end
    end

    if writeToDisk
		finishedMessage = sprintf('Done!  It wrote %d frames to folder\n"%s"', numberOfFramesWritten, outputFolder);
	else
		finishedMessage = sprintf('Done!  It processed %d frames of\n"%s"', numberOfFramesWritten, movieFullFileName);
    end
	disp(finishedMessage);
	uiwait(msgbox(finishedMessage));
catch ME
	% Some error happened if you get here.
	strErrorMessage = sprintf('Error extracting movie frames from:\n\n%s\n\nError: %s\n\n)', movieFullFileName, ME.message);
	uiwait(msgbox(strErrorMessage));
end
