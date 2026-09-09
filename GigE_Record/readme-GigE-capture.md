This code is provided without any warranty and is covered by an MIT license.

GigE_Record uses Matlab installed on a windows PC with a National Instruments (NI) data acquisition card and a Basler GigE camera (we used ace acA1300-60gc: https://www.baslerweb.com/de-de/shop/aca1300-60gc/)
to record overhead videos and create a record of triggers captured through the NI card. 
You will need MATLAB with Image Acquisition Toolbox (GigE), Data Acquisition Toolbox (NI), plus the camera and NI DAQ hardware.
The program will create a black square when the TTL is high and overlay the video with the frame # and time text.

Operation:
        While in theory any DAQ could be used to receive a single digital input, we used a NI DAQ and we only read from line 0 of port 0: 
    handles.s = daq.createSession('ni');
    addDigitalChannel(handles.s,'dev1','Port0/Line0','InputOnly'); 
    Change this on GigE_Record.m.

    While we attempted to package the function as an app, it's not warranteed that it will work. Easier to call the figure on the command window >>GigE_Record

    Change the default path from "defaultFolder='C:\GigE Record\Videos\Temp';" to whatever works for you.

    Three files are required:

    GigE_Record.m — main GUIDE app code
    GigE_Record.fig — UI layout 
    CalculatePacketDelay.m — called during Initialize to set GigE packet delay

    Workflow: set path/name → Initialize → Save on to record → Save off to   stop/finalize.

    Save workflow —  Save is a toggle: Init starts preview; Save on starts writing to disk; Save off stops the timer, closes the .bin/video, and closes the GUI. If Save stays off, nothing is written.

    To load the .bin file type `data = fread(fopen('...TTL.bin','r'),[8,inf],'single');`
    Jumbo frames — PacketSize = 9000 needs them enabled on the NIC.
    Defaults — 25 fps, BayerBG8 
    Path — Can also be changed in the GUI (Change_path), not only via defaultFolder.

Output:
    GigE_Record creates two files, one video in mp4 format and one binary file with the extension .bin.
    Output files are: 
    {filename}{date}TTL.bin  (e.g. file120190109color.mp4)
    {filename}{date}color.mp4 (e.g. file120190109TTL.bin).

    The 'bin' file has the following values per frame:
    1: TTL - 1 for pressing
    2:4 - TTL grabbing time : hour,minute,seconds (once every few frames)
    5 : frame number
    6-8 - Time: hour,minute,seconds

