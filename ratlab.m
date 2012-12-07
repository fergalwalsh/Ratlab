% Author: Fergal Walsh NUIM 

function varargout = ratlab(varargin)
% RATLAB M-file for ratlab.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ratlab_OpeningFcn, ...
                   'gui_OutputFcn',  @ratlab_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ratlab is made visible.
function ratlab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ratlab (see VARARGIN)
	handles.output = hObject;
	handles.directory = './';
	if ~isempty(varargin)
	handles.directory = varargin{1};
	end
	filenames = getFilenames(handles.directory, '*.tif*');
	if length(filenames) < 1
	    pwd
	    error('No TIFF images found in this directory: %s', pwd);
	    return;
	end
	handles.numImages = length(filenames);
	fprintf(1,'\nLoading %d images. Please Wait.\n', handles.numImages);
	handles.images = readImagesToMatrix(filenames, 600, 900);

	%Slices holds metadata for each slice image
	handles.slices = cell(handles.numImages, 1);
	for i=1:handles.numImages
	    slice.filename = filenames{i};
	    slice.box = [1,1,0,0];
		slice.point1 = [1,1];
		slice.point2 = [1,1];
	    slice.z = 0;
	    handles.slices{i} = slice;
	end
	% Initialise values
	handles.imageNumber = 1;
	handles.point.x = 450;
	handles.point.y = 300;
	
	% Set resolution of scanned images - do not expect it to work with anything other that 1200dpi
	dpi = 1200;
	dpcm = dpi / 2.54; % conversion from inches to cenimenters
	handles.pixels_per_mm = dpcm / 10;

	% Load atlas images from mat file
	a = load('atlas2.mat');
	handles.atlas = a.atlas2;
	clear a;
	handles.diagramNumber = 1;
	handles.numDiagrams = length(handles.atlas);
	% handles.currentDiagram = handles.atlas{handles.diagramNumber}.image;
	j = 1;
	handles.gridlines = [];
	for a = [handles.coronalView, handles.atlasView, handles.axialView, handles.sagittalView]
		axes(a);
		% Set up scroll panels
		pos = get(a, 'Position');
		units = get(a, 'Units');
		parent = get(a, 'Parent');
		im = imshow(ones(600,900));
		hsp = imscrollpanel(parent, im);
		set(hsp,'Units',units,'Position',pos);
		set(a, 'UserData', hsp);
		% Create grid lines
		for i = 0:10;
			x1 = 450 + i * handles.pixels_per_mm;
			handles.gridlines(j)  = line([x1, x1],[0, 600],'Color',[.8 .8 .8],'LineWidth',0.5);
			x2 = 450 - i * handles.pixels_per_mm;
			handles.gridlines(j+1) = line([x2, x2],[0, 600],'Color',[.8 .8 .8],'LineWidth',0.5);
			y1 = 300 + i * handles.pixels_per_mm;
			handles.gridlines(j+2) = line([0, 900],[y1, y1],'Color',[.8 .8 .8],'LineWidth',0.5);
			y2 = 300 - i * handles.pixels_per_mm;
			handles.gridlines(j+3) = line([0, 900],[y2, y2],'Color',[.8 .8 .8],'LineWidth',0.5);
			j = j+4;
		end
	end
	
	% Set up drop down menu for choosing images
	imageNumbers = {};
	for i = 1:handles.numImages;
		imageNumbers{i} = num2str(i);
	end
	set(handles.imageNumberBox, 'String', imageNumbers);

	% Set up GUI tools for interactive manual adjustment
	handles.box = imrect(handles.coronalView, [0,0,0,0],'PositionConstraintFcn', @rect_callback);
	handles.rotationLine = imline(handles.coronalView, [0, 0], [0, 0]);

	showCurrentImage(handles);
	showCurrentDiagram(handles);

	% Set up slice lines
	handles.horizontalLine = imline(handles.coronalView, [0, 900], [300, 300], 'PositionConstraintFcn', @horizontalLine_Callback);
	handles.verticalLine = imline(handles.coronalView, [450, 450], [0, 600], 'PositionConstraintFcn', @verticalLine_Callback);
	axes(handles.coronalView);
	guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ratlab_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
	varargout{1} = handles.output;

%Callback to check and constrain the position of horizontal slice line after change in position
function new_pos = horizontalLine_Callback(new_pos)
	if new_pos(2,2) < 1
		new_pos(2,2) = 1;
	elseif new_pos(2,2) > 600
		new_pos(2,2) = 600;
	end
	handles = guidata(gca);
	new_pos(1,1) = 0;
	new_pos(2,1) = 900;
	new_pos(1,2) = new_pos(2,2);
	handles.point.y = floor(new_pos(1,2));
	guidata(gca, handles);
	showAxialSlice(handles);

%Callback to check and constrain the position of verticle slice line after change in position
function new_pos = verticalLine_Callback(new_pos)
	if new_pos(2,1) < 1
		new_pos(2,1) = 1;
	elseif new_pos(2,1) > 900
		new_pos(2,1) = 900;
	end
	handles = guidata(gca);
	new_pos(1,2) = 0;
	new_pos(2,2) = 600;
	new_pos(1,1) = new_pos(2,1);
	handles.point.x = floor(new_pos(1,1));
	guidata(gca, handles);
	showSagittalSlice(handles);
	
% Callback to check and constrain the position of the adjustable bounding box rectangle     
function new_pos = rect_callback(new_pos)
	handles = guidata(gca);
	pos = getPosition(handles.box);
	if new_pos(3) == pos(3) && new_pos(4) == pos(4) 
		new_pos = pos;
		handles.slices{handles.imageNumber}.box = new_pos;
		guidata(gcbo, handles);
	end
	
%Executes when the image number drop down menu is changed
function imageNumberBox_Callback(hObject, eventdata, handles)
% hObject    handle to imageNumberBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	i = get(hObject,'Value');
	if i > handles.numImages
		i = handles.numImages;
	elseif i < 1
		i = 1;
	end
	handles.imageNumber = i;
	set(hObject, 'Value', i);
	guidata(hObject, handles);
	showCurrentImage(handles);

% --- Executes during object creation, after setting all properties.
function imageNumberBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageNumberBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
	if ispc
	    set(hObject,'BackgroundColor','white');
	else
	    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


% --- Executes on button press in nextDiagram.
function nextDiagram_Callback(hObject, eventdata, handles)
% hObject    handle to nextDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	handles.diagramNumber = handles.diagramNumber + 1;
	set(handles.diagramNumberBox, 'String', num2str(handles.diagramNumber));
	diagramNumberBox_Callback(handles.diagramNumberBox, '', handles);

% --- Executes on button press in previousDiagram.
function previousDiagram_Callback(hObject, eventdata, handles)
% hObject    handle to previousDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	handles.diagramNumber = handles.diagramNumber - 1;
	set(handles.diagramNumberBox, 'String', num2str(handles.diagramNumber));
	diagramNumberBox_Callback(handles.diagramNumberBox, '', handles);


function diagramNumberBox_Callback(hObject, eventdata, handles)
% hObject    handle to diagramNumberBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	i = str2num(get(hObject, 'String'));
	if i > handles.numDiagrams
		i = handles.numDiagrams;
	elseif i < 1
		i = 1;
	end
	handles.diagramNumber = i;
	% handles.currentDiagram = handles.atlas{handles.diagramNumber}.image;
	set(hObject, 'String', num2str(i));
	guidata(hObject, handles);
	showCurrentDiagram(handles);

% --- Executes during object creation, after setting all properties.
function diagramNumberBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diagramNumberBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
	if ispc
	    set(hObject,'BackgroundColor','white');
	else
	    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function nextImage_Callback(hObject, eventdata, handles)
% hObject    handle to nextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	handles.imageNumber = handles.imageNumber + 1;
	set(handles.imageNumberBox, 'Value', handles.imageNumber);
	imageNumberBox_Callback(handles.imageNumberBox, '', handles);

function previousImage_Callback(hObject, eventdata, handles)
% hObject    handle to nextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	handles.imageNumber = handles.imageNumber - 1;
	set(handles.imageNumberBox, 'Value', handles.imageNumber);
	imageNumberBox_Callback(handles.imageNumberBox, '', handles);

% --- Executes on selection change in magnificationMenu.
function magnificationMenu_Callback(hObject, eventdata, handles)
% hObject    handle to magnificationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	hsp = get(handles.coronalView, 'UserData');
	api = iptgetapi(hsp);
	contents = get(hObject,'String');
	mag = contents{get(hObject,'Value')};
	if strcmp(mag, 'Fit')
	    mag = api.findFitMag();
	else
	    mag = str2num(mag);
	    mag = mag / 100;
	end
	api.setMagnification(mag);
	% Set each axis to the same magnification
	hsp = get(handles.atlasView, 'UserData');
	api = iptgetapi(hsp);
	api.setMagnification(mag);
	hsp = get(handles.axialView, 'UserData');
	api = iptgetapi(hsp);
	api.setMagnification(mag);
	hsp = get(handles.sagittalView, 'UserData');
	api = iptgetapi(hsp);
	api.setMagnification(mag);

% --- Executes during object creation, after setting all properties.
function magnificationMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnificationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
	if ispc
	    set(hObject,'BackgroundColor','white');
	else
	    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
	set(hObject, 'String', {'Fit', '50', '75', '100', '150', '200', '250'});

% Update the display with the current image in the coronal, axial and sagittal displays
function showCurrentImage(handles)
	I = getCurrentImage(handles);
	axes(handles.coronalView);
	hsp = get(gca, 'UserData');
	api = iptgetapi(hsp);
	api.replaceImage(I,'PreserveView', 1);
	magnificationMenu_Callback(handles.magnificationMenu, '', handles);
	setPosition(handles.box, [0,0,0,0]);
	setPosition(handles.rotationLine, [0,0], [0, 0]);
	showAxialSlice(handles);
	showSagittalSlice(handles);
	guidata(gca, handles);

	
function I = getCurrentImage(handles)
	i = handles.imageNumber;
	contents = get(handles.imageChooserBox,'String');
	value = contents{get(handles.imageChooserBox,'Value')};
	if strcmp(value, 'Original')
		I = handles.slices{i}.original;
	else
		I = handles.images(:,:,i);
	end

    
% Update diagram display
function showCurrentDiagram(handles)
	% I = handles.atlas{handles.diagramNumber}.image;
	f = handles.atlas{handles.diagramNumber}.filename;
	I = readSingleImage(f, 600, 900);
	axes(handles.atlasView);
	hsp = get(gca, 'UserData');
	api = iptgetapi(hsp);
	api.replaceImage(I,'PreserveView', 1);
	magnificationMenu_Callback(handles.magnificationMenu, '', handles);



% --- Executes on button press in processAll.
function processAll_Callback(hObject, eventdata, handles)
% hObject    handle to processAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	set(hObject, 'String', 'Please Wait..');
	set(hObject, 'Enable', 'off');
	for i=1:handles.numImages
		I = getCurrentImage(handles);
		original = I;
	    I = preprocessImage(I);
		I = alignImageUsingFeaturePoints(I);
		box = getBoundingBox(I);
		handles.slices{i}.original = original;
		handles.slices{i}.box = box;
	    handles.images(:,:,i) = I;
	    showCurrentImage(handles);
	    handles = guidata(gca);
	    pause(0.1) % pause to allow the display to update to give user feedback
	    nextImage_Callback(hObject, eventdata, handles);
	    handles = guidata(gca); %update handles structure (it will have been modified by calls to nextImage_Callback)
	    pause(0.1)
	end
	set(hObject, 'String', 'Processing Complete');
	set(handles.manualPanel, 'Visible', 'on');
	set(handles.imageChooserBox, 'String', {'Processed','Original'});
	set(handles.imageChooserBox, 'Visible', 'on');
	guidata(hObject, handles);

% Show the axial slice and the current y value of the horizontal line
function showAxialSlice(handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = handles.images(handles.point.y,:,:);
	I = squeeze(I);
	I(:,end+1) = I(:,end);
	I(1:40,handles.imageNumber) = 0; % black line at left edge of current slice
	I(end-40:end,handles.imageNumber) = 0; % black line at right edge of current slice
	a = 1;
	thickness = 5; 
	interpolate = get(handles.interpolateCheck,'Value'); % check if interpolation check box is checked
	X = uint8(ones(900, thickness * handles.numImages));
	for i=1:handles.numImages
	    b = a + (thickness - 1);
	    for j=a:b
	        if interpolate
		        m = (1/5) * ((j-a) + 1);
				n = 1 - m;
				X(:,j) = (I(:,i).*n + I(:,i+1).*m);
			else
				X(:,j) = I(:,i);
			end
	    end
	    a = b + 1;
	end
	I = X;
	I = imrotate(I, 90);
	axes(handles.axialView);
	hsp = get(gca, 'UserData');
	api = iptgetapi(hsp);
	api.replaceImage(I,'PreserveView', 1);

% Show the sagittal slice and the current x value of the vertical line
function showSagittalSlice(handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = handles.images(:,handles.point.x,:);
	I = squeeze(I);
	I(:,end+1) = I(:,end);
	I(1:40,handles.imageNumber) = 0; % black line at top edge of current slice
	I(end-40:end,handles.imageNumber) = 0; % black line at bottom edge of current slice
	a = 1;
	thickness = 5;
	interpolate = get(handles.interpolateCheck,'Value'); % check if interpolation check box is checked
	X = uint8(ones(600, thickness * handles.numImages));
	for i=1:handles.numImages
	    b = a + (thickness - 1);
	    for j=a:b
	        if interpolate
		        m = (1/5) * ((j-a) + 1);
				n = 1 - m;
				X(:,j) = (I(:,i).*n + I(:,i+1).*m);
			else
				X(:,j) = I(:,i);
			end
	    end
	    a = b + 1;
	end
	I = X;
	axes(handles.sagittalView);
	hsp = get(gca, 'UserData');
	api = iptgetapi(hsp);
	api.replaceImage(I,'PreserveView', 1);



% --- Executes on button press in recalculateAlignment.
function recalculateAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to recalculateAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = getCurrentImage(handles);
	% get the bounding box for the current image
	box = handles.slices{handles.imageNumber}.box;
	
	% Crop the image to the new bounding box position
	temp = ones(600,900).*255;
	t = round(box(2));
	b = round(box(2) + box(4));
	l = round(box(1));
	r = round(box(1) + box(3));
	temp(t:b, l:r) = 0;
	I = I + uint8(temp);
	
	% Get position of end points of manual rotation line
	pos = round(getPosition(handles.rotationLine));
	x1 = pos(1,1);
	y1 = pos(1,2);
	x2 = pos(2,1);
	y2 = pos(2,2);
	x3 = x1;
	y3 = y2;
	theta = angleBetweenPoints(x1,y1,x2,y2,x3,y3);
	I(I==0) = 1;
	I(y2,x2) = 0; % make V point a unique value so we can find it again after rotation
	I(y2,x2+1) = 0;
	
	I = 255 - I;
	I = imrotate(I,theta,'nearest','crop'); %rotate the image
	I = 255 - I;
	
	[X,Y] = find(I==0,1);% V point
	x2 = Y(1);
	y2 = X(1);
	box = getBoundingBox(I);
	shiftY = 300 - floor(box(2) + (box(4) / 2));
	box(2) = box(2) + shiftY;
	shiftX = 450 - x2;
	I = 255 - I;
	I = circshift(I, [shiftY, shiftX]); %shift the image
	I = 255 - I;
	
	handles.slices{handles.imageNumber}.box = box;
	handles.images(:,:,handles.imageNumber) = I;
	set(handles.recalculateAlignment, 'Enable', 'off');
	guidata(hObject, handles);
    showCurrentImage(handles);



% --- Executes on button press in showSliceLinesCheck.
function showSliceLinesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to showSliceLinesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showSliceLinesCheck
	if get(hObject,'Value') == 1
		set(handles.verticalLine, 'Visible', 'on');
		set(handles.horizontalLine, 'Visible', 'on');
	else
		set(handles.verticalLine, 'Visible', 'off');
		set(handles.horizontalLine, 'Visible', 'off');
	end


% --- Executes on button press in skip.
function skip_Callback(hObject, eventdata, handles)
% hObject    handle to skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.manualPanel, 'Visible', 'on');
guidata(hObject, handles);


% --- Executes on button press in findFeaturePoints.
function findFeaturePoints_Callback(hObject, eventdata, handles)
% hObject    handle to findFeaturePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = getCurrentImage(handles);
	box = getBoundingBox(I);
	handles.slices{handles.imageNumber}.box = box;
	setPosition(handles.box, box);

	[x1, y1] = findVentriclePoint(I);% ventricle point
	[x2, y2] = findVPoint(I);% V point
	setPosition(handles.rotationLine, [x1, x2], [y1, y2]);
	set(handles.recalculateAlignment, 'Enable', 'on');
	guidata(hObject, handles);


% --- Executes on button press in distanceTool.
function distanceTool_Callback(hObject, eventdata, handles)
% hObject    handle to distanceTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of distanceTool
	if get(hObject,'Value') == 0
		delete(handles.ruler);
		set(hObject, 'String', 'Length');
		set(handles.distanceLabel, 'String', num2str(0));
	else
		handles.ruler = imline('PositionConstraintFcn', @ruler_Callback);
		setColor(handles.ruler, 'red');
		set(hObject, 'String', 'Clear');
	end
	guidata(hObject, handles);


function pos = ruler_Callback(pos)
	handles = guidata(gca);
	distance = sqrt((pos(1,1) - pos(2,1))^2 + (pos(1,2) - pos(2,2))^2);
	distance = distance / handles.pixels_per_mm; 
	set(handles.distanceLabel, 'String', [num2str(distance, 4) ' mm']);
	guidata(gca, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if gca == handles.coronalView
		activePanel = handles.uipanelCoronal;
	elseif gca == handles.axialView
		activePanel = handles.uipanelAxial;
	elseif gca == handles.sagittalView
		activePanel = handles.uipanelSagittal;
	elseif gca == handles.atlasView
		activePanel = handles.uipanelAtlas;
	end
	set(handles.uipanelCoronal, 'ForegroundColor', 'Black');
	set(handles.uipanelAxial, 'ForegroundColor', 'Black');
	set(handles.uipanelSagittal, 'ForegroundColor', 'Black');
	set(handles.uipanelAtlas, 'ForegroundColor', 'Black');
	set(activePanel, 'ForegroundColor', 'Red');


% --- Executes on button press in areaTool.
function areaTool_Callback(hObject, eventdata, handles)
% hObject    handle to areaTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if get(hObject,'Value') == 0
		if isfield(handles, 'polyLine')
			delete(handles.polyLine);
		end
		set(hObject, 'String', 'Area');
		set(handles.areaLabel, 'String', num2str(0));
	else
		set(hObject, 'String', 'Clear');
		handles.polyLine = impoly;
		setColor(handles.polyLine, 'green');
		position = getPosition(handles.polyLine);
		x = position(:,1);
		y = position(:,2);
		A = polyarea(x,y);
		A = A / handles.pixels_per_mm^2;
		set(handles.areaLabel, 'String', [num2str(A,4) ' mm^2']);
	end
	guidata(hObject, handles);



% --- Executes on selection change in imageChooserBox.
function imageChooserBox_Callback(hObject, eventdata, handles)
% hObject    handle to imageChooserBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	showCurrentImage(handles);

% --- Executes during object creation, after setting all properties.
function imageChooserBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageChooserBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
	set(hObject, 'String', {'Current', ''});
	set(hObject, 'Visible', 'off');


% --- Executes on button press in showGridLinesCheck.
function showGridLinesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to showGridLinesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showGridLinesCheck
	if get(hObject,'Value') == 1
		vis = 'on';
	else
		vis = 'off';
	end
	for i = 1:length(handles.gridlines);
		l = handles.gridlines(i);
		set(l, 'Visible', vis);
	end


% --- Executes on button press in exportAll.
function exportAll_Callback(hObject, eventdata, handles)
% hObject    handle to exportAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = getCurrentImage(handles);
	if ~exist([handles.directory 'output'], 'dir')
		mkdir(handles.directory, 'output');
	end
	for i=1:handles.numImages
		imwrite(handles.images(:,:,i), [handles.directory 'output/' num2str(i,'%0.2d') '.tiff'], 'tiff');
	end


% --- Executes on button press in exportCurrentImage.
function exportCurrentImage_Callback(hObject, eventdata, handles)
% hObject    handle to exportCurrentImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	I = getCurrentImage(handles);
	if ~exist([handles.directory 'output'], 'dir')
		mkdir(handles.directory, 'output');
	end
	imwrite(I, [handles.directory 'output/' int2str(handles.imageNumber) '.tiff'], 'tiff');



% --- Executes on button press in interpolateCheck.
function interpolateCheck_Callback(hObject, eventdata, handles)
% hObject    handle to interpolateCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	showAxialSlice(handles);
	showSagittalSlice(handles);



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% Executes on any Key Press. Adjusts the image postion using arrow keys
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
	shiftX = 0; 
	shiftY = 0;
	if strcmp(eventdata.Key, 'leftarrow')
		shiftX = -2;
	elseif strcmp(eventdata.Key, 'rightarrow')
		shiftX = 2;
	elseif strcmp(eventdata.Key, 'uparrow')
		shiftY = -2;
	elseif strcmp(eventdata.Key, 'downarrow')
		shiftY = 2;
	end
	I = getCurrentImage(handles);
	I = circshift(I, [shiftY, shiftX]);
	handles.images(:,:,handles.imageNumber) = I;
	guidata(hObject, handles);
	showCurrentImage(handles);

