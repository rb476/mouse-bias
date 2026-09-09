function varargout = bias_identityCorrectorGUI(varargin)
% BIAS_IDENTITYCORRECTORGUI MATLAB code for bias_identityCorrectorGUI.fig
%      BIAS_IDENTITYCORRECTORGUI, by itself, creates a new BIAS_IDENTITYCORRECTORGUI or raises the existing
%      singleton*.
%
%      H = BIAS_IDENTITYCORRECTORGUI returns the handle to a new BIAS_IDENTITYCORRECTORGUI or the handle to
%      the existing singleton*.
%
%      BIAS_IDENTITYCORRECTORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIAS_IDENTITYCORRECTORGUI.M with the given input arguments.
%
%      BIAS_IDENTITYCORRECTORGUI('Property','Value',...) creates a new BIAS_IDENTITYCORRECTORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bias_identityCorrectorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bias_identityCorrectorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bias_identityCorrectorGUI

% Last Modified by GUIDE v2.5 14-Oct-2016 09:10:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bias_identityCorrectorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @bias_identityCorrectorGUI_OutputFcn, ...
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


% --- Executes just before bias_identityCorrectorGUI is made visible.
function bias_identityCorrectorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bias_identityCorrectorGUI (see VARARGIN)

% Choose default command line output for bias_identityCorrectorGUI
handles.output = hObject;
handles.correctThisMouse = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bias_identityCorrectorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bias_identityCorrectorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonPast.
function pushbuttonPast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trial = handles.trial-1;
if handles.trial == 0 
    handles.trial = 1;
else
    handles.frame = randi(100)+100;
    handles.miceOrder = 1:3;
    loadTrial(handles)
end    

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trial = handles.trial+1;
maxTrial = max(handles.trialsAndBlocks(handles.trialsAndBlocks(:,2)==handles.block,1));
if handles.trial > maxTrial; 
    handles.trial = maxTrial;
else
%     handles.frame = randi(50);%+100; 
    handles.frame = 175;
    handles.miceOrder = 1:3;
    guidata(gcbo, handles)
    loadTrial(handles)
end 

% --- Executes on button press in pushbuttonRandomFrame.
function pushbuttonRandomFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRandomFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.frame = randi(handles.videoFrames);
handles.sliderFrameNo.Value = handles.frame;
% Update handles structure
guidata(handles.textSessionBlock, handles);

showVideoStill(handles)

% --- Executes on button press in pushbuttonLoadSession.
function pushbuttonLoadSession_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.xls*', 'Select worksheet containing data for session of interest');
[numbers, text] = xlsread(strcat(PATHNAME,FILENAME),'data');
% Mice IDs
m1 = find(strcmp(text(1,:),'Mice 1'));
m2 = find(strcmp(text(1,:),'Mice 2'));
m3 = find(strcmp(text(1,:),'Mice 3'));
if isempty(m1),
    m1 = find(strcmp(text(1,:),'Mouse 1'));
    m2 = find(strcmp(text(1,:),'Mouse 2'));
    m3 = find(strcmp(text(1,:),'Mouse 3'));
end

% if both m2 and m3 are NAN, then numbers matrix is smaller than m3 column
if size(numbers,2)>=m3,
    miceIDs = numbers(:, [m1 m2 m3]);
else
    miceIDs = numbers(:, m1);
    miceIDs = [miceIDs, NaN(length(miceIDs),2)];
end

handles.blockMice = miceIDs(numbers(:,1)==1,:); % mice ID on first trial of each block

handles.trialsAndBlocks = numbers(:,1:2);

handles.session = FILENAME(1:4); % first 4 characters are numbers indicating the session number
handles.block = 1;
handles.trial = 1;
handles.frame = randi(100)+100;
handles.sessionPath = PATHNAME;

handles.editBlockNo.String = num2str(handles.block);
handles.editFrameNo.String = num2str(handles.frame);

% Update handles structure
guidata(gcbo, handles);
loadTrial(handles)

function loadTrial(handles)
if ~strcmpi(handles.uibuttongroup1.SelectedObject.Tag,'radiobutton123'),
    handles.uibuttongroup1.SelectedObject = handles.radiobutton123;
    handles.miceOrder = 1:3;
    handles = guidata(gcbo);
end

updateSessionText(handles)
readVideo(handles)
handles = guidata(gcbo);
loadTracks(handles)
handles = guidata(gcbo);
showVideoStill(handles)

% prepare the steps of the slider
handles.sliderFrameNo.Max = handles.videoFrames;
handles.sliderFrameNo.Value = handles.frame;
handles.sliderFrameNo.SliderStep = [1 10]./handles.videoFrames;

function updateSessionText(handles)
% Update session text
S = sprintf('Session %s Block %d', handles.session, handles.block);
handles.textSessionBlock.String = S;
% update Mouse IDs text
mid = handles.blockMice(handles.block,:);
smid = sort(mid);
Sm = sprintf('Worksheet. A=%d   B=%d    C=%d\n', mid(1),mid(2),mid(3));
Sm2 = sprintf('%sMOTR.  A=%d    B=%d    C=%d', Sm, smid(1), smid(2), smid(3));
handles.textMiceIDs.String = Sm2;
% show images of each mice, ordered for MOTR!
% lookHere = 'Z:\Raymundo\Documents\MGH\Mice bias\Mouse ID\';
% lookHere = 'C:\Users\Raymundo\Documents\MGH\Mice bias\Mouse ID\';
backslashes = strfind(handles.sessionPath,'\');
lookHere = [handles.sessionPath(1:(backslashes(end-1))), 'Mouse ID\'];
imshow(sprintf('%s%d snap.png', lookHere, smid(1)),'Parent',handles.axes2)
if ~isnan(smid(2))
    imshow(sprintf('%s%d snap.png', lookHere, smid(2)),'Parent',handles.axes3)
    imshow(sprintf('%s%d snap.png', lookHere, smid(3)),'Parent',handles.axes4)
end


% Update handles structure
guidata(handles.textSessionBlock, handles);

function readVideo(handles)
% locate video. 
thisFolder = sprintf('%sMovies\\Block %d\\',handles.sessionPath,handles.block);
D = dir([thisFolder,'*.avi']);
if isempty(D),
    D = dir([thisFolder,'*.mp4']);
    handles.prefix = str2double(D(1).name(1:3));
    handles.videoName = sprintf('%d_%s_Block_%d_Trial_%02d.mp4', handles.prefix, handles.session,...
        handles.block,handles.trial);
else
%     handles.prefix = str2double(D(1).name(1:3));
%     handles.videoName = sprintf('%d_%s_Block_%d_Trial_%02d.avi', handles.prefix, handles.session,...
%         handles.block,handles.trial);
    backslashes = strfind(handles.sessionPath,'\');
    handles.prefix = handles.sessionPath(backslashes(end-1)+1:end-1);
    handles.videoName = sprintf('%s_Block_%d_Trial_%02d.avi', handles.prefix,...
        handles.block,handles.trial);
end
% Read video
thisVideo = strcat(thisFolder,handles.videoName);
handles.readerObj = VideoReader(thisVideo);
handles.videoFrames = fix(handles.readerObj.Duration*handles.readerObj.FrameRate);

% Indicate which file has been read
handles.textFileName.String = handles.videoName;

% Update handles structure
guidata(handles.axes1, handles);

function loadTracks(handles)
% Locate and load current tracks
thisFolder = sprintf('%sProcessed_%d\\Results\\Tracks\\',handles.sessionPath,handles.block);
handles.trackFileName = strcat(thisFolder, [handles.videoName(1:end-4),'_tracks.mat']);
handles.tracks = load(handles.trackFileName);

% Update handles structure
guidata(handles.axes1, handles);

function showVideoStill(handles)
% Show video still
currentFrame = read(handles.readerObj, handles.frame);
imshow(currentFrame,'Parent',handles.axes1)

% Show animal's position as estimated by motr.
letters = {'A','B','C'};
hold(handles.axes1,'on')

if length(handles.tracks.astrctTrackers)==1,
    % only 1 mouse
    X = double(handles.tracks.astrctTrackers.m_afX);
    Y = double(handles.tracks.astrctTrackers.m_afY);
    scatter(X(handles.frame), Y(handles.frame), 100,'filled','Parent',handles.axes1)
    T = text(X(handles.frame)+20,Y(handles.frame),letters(1),'Parent',handles.axes1);
    T.FontSize = 16;  
else
    
%     handles.miceOrder = 1:(length(handles.tracks.astrctTrackers));
    if ~isfield(handles,'miceOrder')
        handles.miceOrder = 1:3;
    end
    count = 0;
    for i = handles.miceOrder,
        X = double(handles.tracks.astrctTrackers(i).m_afX);
        Y = double(handles.tracks.astrctTrackers(i).m_afY);
    %     plot(X, Y)
        scatter(X(handles.frame), Y(handles.frame), 100,'filled','Parent',handles.axes1)
        count = count+1;
        T = text(X(handles.frame)+20,Y(handles.frame),letters(count),'Parent',handles.axes1);
        T.FontSize = 16;
    end
end
hold(handles.axes1,'off')
title(sprintf('Block %d Trial %d Frame %d', handles.block, ...
    handles.trial,handles.frame),'Parent',handles.axes1)

% update slider position and edit frame # box
handles.editFrameNo.String = num2str(handles.frame);
handles.sliderFrameNo.Value = handles.frame;


% --- Executes on button press in pushbuttonCommitChange.
function pushbuttonCommitChange_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCommitChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:length(handles.tracks.astrctTrackers),
    astrctTrackers(i) = handles.tracks.astrctTrackers(handles.miceOrder(i));
end
strMovieFileName = handles.tracks.strMovieFileName;
% save file
save(handles.trackFileName,'astrctTrackers','strMovieFileName')

function editBlockNo_Callback(hObject, eventdata, handles)
% hObject    handle to editBlockNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBlockNo as text
b =  str2double(get(hObject,'String'));% returns contents of editBlockNo as a double
if b<=max(handles.trialsAndBlocks(:,2)),
    handles.block = b;
    handles.trial = 1;
    handles.miceOrder = 1:3;   
    guidata(handles.axes1,handles)
    loadTrial(handles)
end

% --- Executes during object creation, after setting all properties.
function editBlockNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBlockNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFrameNo_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameNo as text
f = str2double(get(hObject,'String'));% returns contents of editFrame as a double
if f<=handles.videoFrames
    handles.frame = f;    
    handles.sliderFrameNo.Value = handles.frame;
    % Update handles structure
    guidata(handles.textSessionBlock, handles);

    showVideoStill(handles)
    guidata(handles.axes1,handles)
end
  
% --- Executes during object creation, after setting all properties.
function editFrameNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newOrder(1) = str2double(hObject.Tag(end-2));
newOrder(2) = str2double(hObject.Tag(end-1));
newOrder(3) = str2double(hObject.Tag(end));
handles.miceOrder = newOrder;
guidata(handles.axes1,handles)

updateSessionText(handles)
readVideo(handles)
handles = guidata(gcbo);
loadTracks(handles)
handles = guidata(gcbo);
showVideoStill(handles)


% --- Executes on slider movement.
function sliderFrameNo_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFrameNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
f = fix(get(hObject,'Value'));
if f==0,
   f = 1;
end
handles.frame = f;
guidata(handles.axes1,handles)

% loadTrial(handles)
showVideoStill(handles)


% --- Executes during object creation, after setting all properties.
function sliderFrameNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFrameNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in checkbox_correct.
function checkbox_correct_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value'),
    correctPosition(handles)
end

% --- Executes when selected object is changed in uibuttongroup_correct.
function uibuttongroup_correct_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_correct 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.correctThisMouse = str2double(hObject.Tag(end));
guidata(gcbo,handles)

function correctPosition(handles)

% G input to signal current position
[x,y] = ginput(1);
if isempty(x),
    % interrupted capture by pressing carriagereturn (enter)
    handles.checkbox_correct.Value = 0;
    guidata(gcbo, handles);
    checkbox_correct_Callback(handles.checkbox_correct,[],handles)
else
    handles.tracks.astrctTrackers(handles.correctThisMouse).m_afX(handles.frame) = x;
    handles.tracks.astrctTrackers(handles.correctThisMouse).m_afY(handles.frame) = y;

    % move one frame forward, show it, call correctPosition again
    if handles.frame < handles.videoFrames,
        handles.frame = handles.frame+1;
        guidata(gcbo,handles)
        showVideoStill(handles)
        correctPosition(handles)
    end
end

function editTrialNo_Callback(hObject, eventdata, handles)
% hObject    handle to editTrialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTrialNo as text
%         returns contents of editTrialNo as a double
handles.trial = str2double(get(hObject,'String'));
guidata(gcbo, handles)
loadTrial(handles)

% --- Executes during object creation, after setting all properties.
function editTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTrialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAnimate.
function pushbuttonAnimate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAnimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show every 10th frame every 100 ms
tf = 100:10:300;
for i = 1:length(tf)
    handles.frame = tf(i);
    handles.sliderFrameNo.Value = handles.frame;
    % Update handles structure
    guidata(handles.textSessionBlock, handles);
    showVideoStill(handles)
    pause(0.15)
end
