function varargout = GigE_Record(varargin)
% GIGE_RECORD MATLAB code for GigE_Record.fig
%      GIGE_RECORD, by itself, creates a new GIGE_RECORD or raises the existing
%      singleton*.
%
%      H = GIGE_RECORD returns the handle to a new GIGE_RECORD or the handle to
%      the existing singleton*.
%
%      GIGE_RECORD('CALLBACK',hObject,eventData,`handles,...) calls the local
%      function named CALLBACK in GIGE_RECORD.M with the given input arguments.
%
%      GIGE_RECORD('Property','Value',...) creates a new GIGE_RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GigE_Record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GigE_Record_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GigE_Record

% Last Modified by GUIDE v2.5 08-Jan-2019 11:36:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GigE_Record_OpeningFcn, ...
    'gui_OutputFcn',  @GigE_Record_OutputFcn, ...
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


% --- Executes just before GigE_Record is made visible.
function GigE_Record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GigE_Record (see VARARGIN)

% Choose default command line output for GigE_Record
handles.output = hObject;


% Reset hardware:
%%%%%%%%%%%%%%%%%
daqreset;
handles.filename='file1';
delete(imaqfind);

% Camera static IP addresses:
handles.IPAddress{1}='192.168.1.100';

% Init Daq:
handles.s = daq.createSession('ni');
addDigitalChannel(handles.s,'dev1','Port0/Line0','InputOnly');

%%% DEBUGGING CODE
% addAnalogInputChannel(handles.s,'dev1','ai0','Voltage');
% handles.s.Rate=100;
% handles.s.IsContinuous = true;
% handles.s.NotifyWhenDataAvailableExceeds=50;
% lh = addlistener(handles.s,'DataAvailable',@(src, event) GetDaq(src, event, hObject));

handles.SaveFlag=0;
handles.colorScale =0.7;
handles.imageTosave=0;
handles.TTL=1;
handles.TTLon=1;
handles.TTLonTime=0;
handles.TTLoffTime=0;
% handles.DaqHistory=zeros(2,5*handles.s.Rate); % 5 seconds at 100 Hertz 
handles.fps=25;
handles.LogQuality=100;

% paralellAcquire=parfeval(@acquireData,1,hObject);
% paralellLog=parfeval(@logData,1,hObject);
%
% handles.CameraTimer = timer('timerfcn',paralellAcquire,'Period',0.001,...
%     'BusyMode','drop',...%queue
%     'ExecutionMode', 'fixedspacing', ...
%     'TasksToExecute', Inf);
%
% handles.DaqTimer = timer('timerfcn',{@GetDaq,hObject},'Period',0.1,...
%     'BusyMode','queue',...%queue
%     'ExecutionMode', 'fixedRate',...
%     'TasksToExecute', Inf);


handles.CameraTimer = timer('timerfcn',{@acquireData,hObject},'Period',0.001,...
    'BusyMode','drop',...%queue
    'ExecutionMode', 'fixedspacing', ...
    'TasksToExecute', Inf);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GigE_Record_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fname_Callback(hObject, eventdata, handles)
% hObject    handle to fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fname as text
%        str2double(get(hObject,'String')) returns contents of fname as a double
handles.filename=get(handles.fname,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function fname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SaveFlag=get(hObject,'Value');
guidata(hObject,handles);

if handles.SaveFlag==1
    set(hObject,'BackgroundColor',[0.94,0.1,0.1])
    %     start(handles.LogTimer)
else
    %     stop(handles.LogTimer)
    stop(handles.CameraTimer)
    stop(handles.s)
    
    delete(imaqfind);
    fclose(handles.fileID);
    close all
    %     set(hObject,'BackgroundColor',[0.5,0.5,0.5])
end


% --- Executes on button press in Init.
function Init_Callback(hObject, eventdata, handles)
% hObject    handle to Init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize Camera Settings
handles.camera =  videoinput('gige',1, 'BayerBG8'); %Mono8
handles.src = getselectedsource(handles.camera);
handles.camera.LoggingMode='memory';
handles.camera.FramesPerTrigger=Inf;
handles.src.AcquisitionFrameRateEnable ='True';
handles.src.AcquisitionFrameRateAbs = handles.fps;
triggerconfig(handles.camera, 'manual');
handles.src.PacketSize = 9000;
delay=CalculatePacketDelay(handles.camera,handles.fps);
handles.src.PacketDelay = delay;

handles.color_width = handles.src.AutoFunctionAOIWidth;
handles.color_height = handles.src.AutoFunctionAOIHeight;

% Initialize filename
fnameTTL=[handles.MoviePath,handles.filename,datestr(now,'yyyymmmdd'),'TTL.bin'];
fnameColor=[handles.MoviePath,handles.filename,datestr(now,'yyyymmmdd'),'color.mp4'];

if exist(fnameTTL,'file') || exist(fnameColor,'file')
    
    choice = questdlg('File already exist, Overwrite?');
    
    % Handle response
    switch choice
        case 'Yes'
            handles.fileID = fopen(fnameTTL,'w');
        case 'No'
            return
        case 'Cancel'
            return
    end
else
    handles.fileID = fopen(fnameTTL,'w');
end


% Color image is to big, let's scale it down
% Create matrices for the images
handles.color = zeros(handles.color_height*handles.colorScale,handles.color_width*handles.colorScale,3,'uint8');
axes(handles.Coloraxes)
handles.ColorImage=imshow(handles.color,[]);


handles.vwColor = VideoWriter([handles.MoviePath,handles.filename,datestr(now,'yyyymmmdd'),'color'],'MPEG-4');
handles.vwColor.FrameRate = handles.fps;
handles.vwColor.Quality=handles.LogQuality;
open(handles.vwColor)
start(handles.camera)
trigger(handles.camera)
guidata(hObject,handles);
% startBackground(handles.s)
% pause(.5)

start(handles.CameraTimer)
% startBackground(handles.s)
% start(handles.DaqTimer)

% % % function GetDaq(~,event,hObject)
% % % 
% % % handles = guidata(hObject);
% % % % handles.TTL = inputSingleScan(handles.s);
% % % data=event.Data(:,2)';
% % % % if handles.TTL && ~handles.TTLon  %TTL switched to 1
% % % %     handles.TTLon=1;
% % % %     handles.TTLonTime=event.Data.time;
% % % % elseif ~handles.TTL && handles.TTLon %TTL switched to 0
% % % %     handles.TTLon=0;
% % % %     handles.TTLoffTime=event.Data.time;
% % % % end
% % % time_aux=datenum(event.TimeStamps+event.TriggerTime);
% % % size_aux=length(time_aux);
% % % handles.DaqHistory(1,:)=[handles.DaqHistory(2,size_aux+1:end),data];
% % % handles.DaqHistory(2,:)=[handles.DaqHistory(1,size_aux+1:end),time_aux'];
% % % guidata(hObject,handles)


function acquireData(~,event,hObject)
handles = guidata(hObject);
[handles.TTL,triggerTime] = inputSingleScan(handles.s);
if handles.TTL && ~handles.TTLon  %TTL switched to 1
    handles.TTLon=1;
%     handles.TTLonTime=event.Data.time;
elseif ~handles.TTL && handles.TTLon %TTL switched to 0
    handles.TTLon=0;
%     handles.TTLoffTime=event.Data.time;
end
triggerTime=datevec(triggerTime);
triggerTime=triggerTime(4:6);
[data,timestamp,MetaData] = getdata(handles.camera, handles.camera.FramesAvailable);

if ~isempty(data)
    time_aux=event.Data.time;
    handles.time=time_aux(4:end);
    %     handles.color = handles.k2.getColor;
    handles.color = data(:,:,:,end);
    handles.imageTosave=1;
    num_of_frames=size(data,4);
    %     tic
    for i=1:num_of_frames
        handles.color=squeeze(data(:,:,:,i));
        %         handles.color=fliplr(handles.color);
        frame_time=datenum(MetaData(i).AbsTime);
        handles.color = insertText(handles.color,[10,handles.color_height*0.93], ...
            sprintf('Frame %d\nTime %02d:%02d:%02.03f',MetaData(i).FrameNumber,MetaData(i).AbsTime(4),MetaData(i).AbsTime(5),MetaData(i).AbsTime(6)),'FontSize',25);
        %     toc
        % update color figure
        if handles.TTLon
            handles.color(1:150,1:150,:)=0;
        end
        data(:,:,:,i)=handles.color;
        handles.color = imresize(handles.color,handles.colorScale,'nearest');
    end
    
    if handles.SaveFlag && handles.imageTosave
        writeVideo(handles.vwColor,data);
        for i=1:num_of_frames
            fwrite(handles.fileID,[handles.TTL,triggerTime, MetaData(i).FrameNumber MetaData(i).AbsTime(4),MetaData(i).AbsTime(5),MetaData(i).AbsTime(6)],'single');
        end
        handles.imageTosave=0;
    end
    set(handles.ColorImage,'CData',handles.color);
    
    
    %     drawnow;
    %     if handles.SaveFlag
    %         writeVideo(handles.vwColor,color);
    %     end
end
guidata(hObject,handles)
%
% function logData(~,event,hObject)
%
% handles = guidata(hObject);
% toc
% tic
% if handles.imageTosave
%     writeVideo(handles.vwColor,handles.color);
%     fwrite(handles.fileID,[handles.TTL handles.time],'single');
%     handles.imageTosave=0;
% end
% guidata(hObject,handles)

%



% --- Executes on button press in Change_path.
function Change_path_Callback(hObject, eventdata, handles)
% hObject    handle to Change_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Current_Path=get(handles.file_path,'String');
handles.MoviePath=[uigetdir(Current_Path),'\'];
set(handles.file_path,'String',handles.MoviePath)
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function file_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
defaultFolder='C:\GigE Record\Videos\Temp';
% set(hObject,'String',pwd);
set(hObject,'String',defaultFolder);
handles.MoviePath=[defaultFolder,'\'];
% handles.MoviePath=get(handles.file_path,'String');
guidata(hObject,handles)

%% Read bin data:
% ff=fopen('C:\GigE Record\Videos\Temp\file12019Jan09TTL.bin','r')
% data=fread(ff,[8,inf],'single');
% fclose(ff)
% First line: TTL - 1 for pressing
% Lines 2:4 - TTL grabbing time : hour,minute,seconds (once every few frames)
% Line 5 : frame number
% lines 6-8 - Time: hour,minute,seconds