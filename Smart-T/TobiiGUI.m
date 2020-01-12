function TobiiGUI
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

%MO: below: used for testing on slower machines.
%Screen('Preference', 'SkipSyncTests', 1); warndlg('Set SkipSyncTests to 0 for running expts', 'SkipSyncTests');
%MO: comment out the one above and un-comment the one below for actual
%running of expts
Screen('Preference', 'SkipSyncTests', 0);

% ---------------------
% set global parameters
% ---------------------
global smarttVersion debug connTobii connNIRS SerialOTNum NIRSMACHINE scr mask obswin loom sound randomSet img path structure phase gui movie
%MO: connNIRS SerialOTNum NIRSMACHINE added above

SetDefualtPara();

% set gui
set(0,'Units','characters');
scrSize = get(0,'ScreenSize');
%[left, bottom, width, height]
Position = [round(scrSize(3)/2-50) 30 128 29];
addRemoveSound = false;
addRemoveLoom = false;
addRemoveRandomSet = false;

%% Create the GUI

% Index of panels
SCREEN_PANEL = 1;
MASK_PANEL = 2;
LOOM_PANEL = 3;
IMAGE_PANEL = 4;
MOVIE_PANEL = 5;
SOUND_PANEL = 6;
RANDOMSET_PANEL = 7;
OBSWIN_PANEL = 8;
PATH_PANEL = 9;
EFFECT_PANEL = 10;
STRUCTURE_PANEL = 11;
PHASE_PANEL = 12;
STRUCT_ATTRIBUTE_PANEL = 13;
QUIT_PHASE_PANEL = 14;

% default constant
NONE = 0;
TOTAL_LOOK = 1;
FIRST_LOOK = 2;
TTEST = 3;
AND = 1;
OR = 2;

%% SPLASH SCREEN _ MO
try
    PositionSpl = [round(scrSize(3)/2-54) round(scrSize(4)/2-10) 120 19.5];
    gui1.mainsmspl = figure(...
        'HandleVisibility','on',...
        'IntegerHandle','off',...
        'Menubar','none',...
        'NumberTitle','off',...
        'Name','',...
        'Tag','smspl',...
        'Color',get(0,'DefaultUicontrolBackgroundcolor'),...
        'Units','characters',...
        'Position',PositionSpl,...
        'Resize','off');
    haxis=axes('units','characters','position',[0 0 120 19.5]);
    if exist('smartt_col_badge.png')
        im=imread('smartt_col_badge.png');
        image(im)
        axis image
    else
        text(0.1,0.7,'System for Monitoring Anticipations in Real Time with the TOBII','FontSize',16)
        text(0.2,0.4,'Developed at the Aslin Lab, University of Rochester','FontSize',14)
    end
    axis off
    pause(0.1);
    mo_dum_var=GetSecs;
    while GetSecs-mo_dum_var<=3
        [mo_var_1,mo_var_3,mo_var_3]=GetMouse();
        if any(mo_var_3);break;end
    end
    delete(gui1.mainsmspl);
catch
    close all
end
%%%%%%%%%%%%%%%%%%%%%%

gui.main = figure(...
    'HandleVisibility','on',...
    'IntegerHandle','off',...
    'Menubar','none',...
    'NumberTitle','off',...
    'Name','Tobii Experiment',...
    'Tag','TobiiMainGui',...
    'Color',get(0,'DefaultUicontrolBackgroundcolor'),...
    'Units','characters',...
    'Position',Position,...
    'Resize','off',...
    'Closerequestfcn',{@ExitTobiiGUI});

uicontrol(gui.main,'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','Load experiment parameter file:','Position',[2 Position(4)-2 50 1.7]);

gui.inputParaFile = uicontrol(gui.main,...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String','',...
    'Position',[2 Position(4)-4 100 1.7]);

gui.browseParaFile = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Browse',...
    'Position',[105 Position(4)-4 20 1.7],...
    'Callback',{@BrowseParaFile});

uicontrol(gui.main,'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','Setup Parameter:','Position',[105 Position(4)-7 50 1.7]);

gui.paraListBox = uicontrol( gui.main,...
    'Style','listbox',...
    'FontSize',10,...
    'Units','characters',...
    'Max', 100, 'Min', 0,...
    'UserData', 1,...
    'String', {'Screen' 'Mask' 'Loom' 'Image' 'Movie' 'Sound' 'Random Set' 'Observe Win' 'Path' 'Effect' 'Structure' 'Phase' 'Struct Attribute' 'Quit Phase'}, ...
    'Position',[105 Position(4)-20.8 21 14],...
    'Callback',{@SetupParaListBox});

gui.applyParaButton = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Apply',...
    'Position',[105 Position(4)-23 20 1.7],...
    'Callback',{@ApplyPara});

gui.debugCheckbox = uicontrol( gui.main,...
    'Style','checkbox',...
    'Value', debug,...
    'FontSize',10,...
    'Units','characters',...
    'String','Debug',...
    'Tag','Debug', ...
    'Position',[1 Position(4)-26 20 1.7],...
    'Callback',{@DebugMode});

gui.connTobiiCheckbox = uicontrol( gui.main,...
    'Style','checkbox',...
    'Value', connTobii,...
    'FontSize',10,...
    'Units','characters',...
    'String','Connect Tobii',...
    'Position',[14 Position(4)-26 20 1.7],...
    'Callback',{@ConnTobii});

%MO: added NIRS connect box below
gui.connNIRSCheckbox = uicontrol( gui.main,...
    'Style','checkbox',...
    'Value', connNIRS,...
    'FontSize',10,...
    'Units','characters',...
    'String','Connect NIRS',...
    'Position',[35 Position(4)-26 21 1.7],...
    'Callback',{@ConnNIRS});

%MO: added SerialOTNum gui element below
gui.SerialOTNumeditBox = uicontrol(gui.main,...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','center',...
    'Units','characters',...
    'String',num2str(SerialOTNum),...
    'BackgroundColor', [1 1 1],...
    'Position',[55 Position(4)-26 4 1.7],...
    'Callback',{@GetSerialOTNum});

gui.SaveAsButton = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Save Parameter',...
    'Position',[105 Position(4)-26 20 1.7],...
    'Callback',{@SaveParaFile});

%MO: added aboutbutton
gui.AboutButton = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'FontAngle','italic',...
    'BackgroundColor',[0.8 0.8 1],...
    'Units','characters',...
    'String','About ',...
    'Position',[111 Position(4)-28 7 1.6],...
    'Callback',{@AboutStuff});

%MO: added version number
gui.SMARTTVersion = uicontrol( gui.main,...
    'Style','text',...
    'FontSize',10,...
    'Units','characters',...
    'String',['V. ' num2str(smarttVersion,'%.1f')],...
    'Position',[119 Position(4)-28 6 1.3],...
    'Callback',{@AboutStuff});

gui.showScreenButton = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Show Screen',...
    'Position',[84 Position(4)-26 18 1.7],...
    'Callback',{@ShowScreen});

gui.showScreenButton = uicontrol( gui.main,...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Close Screen',...
    'Position',[65 Position(4)-26 18 1.7],...
    'Callback',{@CloseScreen});

uicontrol(gui.main,'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','ForegroundColor',[0.5 0 0],'String','Key s => Start and Stop moving object;   Key Esc => Kill stimulation window.','Position',[2 Position(4)-29 100 1.7]);

%% Screen Parameter Panel
gui.paraPanel(SCREEN_PANEL) = uipanel('Parent',gui.main,'Title','Edit Screen Parameters','FontSize',10,...
    'Units','characters',...
    'Position',[2 Position(4)-23 100 18]);

gui.screen.textBox(1) = uicontrol(gui.paraPanel(SCREEN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Width (pixel)','Position',[0 14 40 1.7]);

gui.screen.editBox(1) = uicontrol(gui.paraPanel(SCREEN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(scr.width),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 14.2 40 1.7]);

gui.screen.textBox(2) = uicontrol(gui.paraPanel(SCREEN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Height (pixel)','Position',[0 12 40 1.7]);

gui.screen.editBox(2) = uicontrol(gui.paraPanel(SCREEN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(scr.height),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 40 1.7]);

gui.screen.textBox(3) = uicontrol(gui.paraPanel(SCREEN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Background Color (RGB 0-255)','Position',[0 10 40 1.7]);

gui.screen.editBox(3) = uicontrol(gui.paraPanel(SCREEN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',[num2str(scr.bgcolor(1)) ' ' num2str(scr.bgcolor(2)) ' ' num2str(scr.bgcolor(3))],...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 40 1.7]);

gui.screen.bgcolorButton = uicontrol( gui.paraPanel(SCREEN_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','color',...
    'Position',[84 10.2 10 1.7],...
    'Callback',{@SelectBgcolor});

gui.screen.textBox(4) = uicontrol(gui.paraPanel(SCREEN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Tobii IP address','Position',[0 6 40 1.7]);

gui.screen.editBox(4) = uicontrol(gui.paraPanel(SCREEN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',scr.TobiiIPaddress,...
    'BackgroundColor', [1 1 1],...
    'Position',[42 6.2 40 1.7]);

gui.screen.textBox(5) = uicontrol(gui.paraPanel(SCREEN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Tobii port#','Position',[0 4 40 1.7]);

gui.screen.editBox(5) = uicontrol(gui.paraPanel(SCREEN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',scr.TobiiPortNum,...
    'BackgroundColor', [1 1 1],...
    'Position',[42 4.2 40 1.7]);

%% Mask Parameter Panel
gui.paraPanel(MASK_PANEL) = uipanel('Parent',gui.main,'Title','Edit Mask Parameters','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.mask.textBox(5) = uicontrol(gui.paraPanel(MASK_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Polygon Mask #','Position',[0 14 22 1.7]);

gui.mask.popupmenu = uicontrol(gui.paraPanel(MASK_PANEL),'Style', 'popupmenu',...
    'String', GetString('mask'),...
    'Units','characters',...
    'UserData',1,...
    'Position', [24 14.2 40 1.7],...
    'Callback', {@SelectMask});

gui.mask.textBox(1) = uicontrol(gui.paraPanel(MASK_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','X-coord (pixel)','Position',[0 12 22 1.7]);

gui.mask.editBox(1) = uicontrol(gui.paraPanel(MASK_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(mask(1).x, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 12.2 73 1.7]);

gui.mask.textBox(2) = uicontrol(gui.paraPanel(MASK_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Y-coord (pixel)','Position',[0 10 22 1.7]);

gui.mask.editBox(2) = uicontrol(gui.paraPanel(MASK_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(mask(1).y, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 10.2 73 1.7]);

gui.mask.textBox(3) = uicontrol(gui.paraPanel(MASK_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Color (RGB 0-255)','Position',[0 8 22 1.7]);

gui.mask.editBox(3) = uicontrol(gui.paraPanel(MASK_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',[num2str(mask(1).color(1)) ' ' num2str(mask(1).color(2)) ' ' num2str(mask(1).color(3))],...
    'BackgroundColor', [1 1 1],...
    'Position',[24 8.2 40 1.7]);

gui.mask.colorButton = uicontrol( gui.paraPanel(MASK_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','color',...
    'Position',[66 8.2 10 1.7],...
    'Callback',{@SelectBgcolor});

gui.mask.addMask = uicontrol( gui.paraPanel(MASK_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Mask',...
    'Position',[70 1 27 1.7],...
    'Callback',{@AddMask});

gui.mask.removeMask = uicontrol( gui.paraPanel(MASK_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Mask',...
    'Position',[41 1 27 1.7],...
    'Callback',{@RemoveMask});


%% Loom Effect Parameter Panel
gui.paraPanel(LOOM_PANEL) = uipanel('Parent',gui.main,'Title','Edit Loom Effect Parameters','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.loom.textBox(1) = uicontrol(gui.paraPanel(LOOM_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Grow in size (%)','Position',[0 12 40 1.7]);

gui.loom.editBox(1) = uicontrol(gui.paraPanel(LOOM_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(loom(1).growSize),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 40 1.7]);

gui.loom.textBox(2) = uicontrol(gui.paraPanel(LOOM_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Duration (seconds)','Position',[0 10 40 1.7]);

gui.loom.editBox(2) = uicontrol(gui.paraPanel(LOOM_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(loom(1).duration),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 40 1.7]);

gui.loom.textBox(3) = uicontrol(gui.paraPanel(LOOM_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Loom Effect #','Position',[0 14 40 1.7]);

gui.loom.popupmenu = uicontrol(gui.paraPanel(LOOM_PANEL),'Style', 'popupmenu',...
    'String', GetString('loom'),...
    'Units','characters',...
    'UserData',1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectLoomEffect});

gui.loom.addObswin = uicontrol( gui.paraPanel(LOOM_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Loom',...
    'Position',[70 1 27 1.7],...
    'Callback',{@AddLoomEffect});

gui.loom.removeObswin = uicontrol( gui.paraPanel(LOOM_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Loom',...
    'Position',[41 1 27 1.7],...
    'Callback',{@RemoveLoomEffect});


%% Object Image Parameter Panel
gui.paraPanel(IMAGE_PANEL) = uipanel('Parent',gui.main,'Title','Edit Object Image Files','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.object.imgListBox = uicontrol( gui.paraPanel(IMAGE_PANEL),...
    'Style','listbox',...
    'FontSize',10,...
    'Units','characters',...
    'Max', 100, 'Min', 0,...
    'String', GetString('imgFile'), ...
    'Position',[2 4 95 12],...
    'BackgroundColor', [1 1 1]);

gui.object.addImgFile = uicontrol( gui.paraPanel(IMAGE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Image File',...
    'Position',[72 1 25 1.7],...
    'Callback',{@AddImgFile});

gui.object.removeImgFile = uicontrol( gui.paraPanel(IMAGE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Image File',...
    'Position',[45 1 25 1.7],...
    'Callback',{@RemoveImgFile});

%% Object Image Parameter Panel
gui.paraPanel(MOVIE_PANEL) = uipanel('Parent',gui.main,'Title','Edit Movie Files','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.movie.listBox = uicontrol( gui.paraPanel(MOVIE_PANEL),...
    'Style','listbox',...
    'FontSize',10,...
    'Units','characters',...
    'Max', 100, 'Min', 0,...
    'String', GetString('movieFile'), ...
    'Position',[2 4 95 12],...
    'BackgroundColor', [1 1 1]);

gui.movie.addFile = uicontrol( gui.paraPanel(MOVIE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Movie File',...
    'Position',[72 1 25 1.7],...
    'Callback',{@AddMovieFile});

gui.movie.removeFile = uicontrol( gui.paraPanel(MOVIE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Movie File',...
    'Position',[45 1 25 1.7],...
    'Callback',{@RemoveMovieFile});

%% Sound Parameter Panel
gui.paraPanel(SOUND_PANEL) = uipanel('Parent',gui.main,'Title','Edit Sound Files','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.sound.ListBox = uicontrol( gui.paraPanel(SOUND_PANEL),...
    'Style','listbox',...
    'FontSize',10,...
    'Units','characters',...
    'Max', 100, 'Min', 0,...
    'String', GetString('soundFile'), ...
    'Position',[2 4 95 12],...
    'BackgroundColor', [1 1 1]);

gui.sound.addFile = uicontrol( gui.paraPanel(SOUND_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Sound File',...
    'Position',[72 1 25 1.7],...
    'Callback',{@AddSoundFile});

gui.sound.removeFile = uicontrol( gui.paraPanel(SOUND_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Sound File',...
    'Position',[45 1 25 1.7],...
    'Callback',{@RemoveSoundFile});

%% Observation Windows Parameter Panel
gui.paraPanel(OBSWIN_PANEL) = uipanel('Parent',gui.main,'Title','Edit Observation Windows Parameters','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.obswin.textBox(1) = uicontrol(gui.paraPanel(OBSWIN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Width (pixel)','Position',[0 12 40 1.7]);

gui.obswin.editBox(1) = uicontrol(gui.paraPanel(OBSWIN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(obswin(1).width),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 40 1.7]);

gui.obswin.textBox(2) = uicontrol(gui.paraPanel(OBSWIN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Height (pixel)','Position',[0 10 40 1.7]);

gui.obswin.editBox(2) = uicontrol(gui.paraPanel(OBSWIN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(obswin(1).height),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 40 1.7]);

gui.obswin.textBox(3) = uicontrol(gui.paraPanel(OBSWIN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Upper Left Corner (x,y)','Position',[0 8 40 1.7]);

gui.obswin.editBox(3) = uicontrol(gui.paraPanel(OBSWIN_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',[num2str(obswin(1).upperLeftCorner(1)) ' ' num2str(obswin(1).upperLeftCorner(2))],...
    'BackgroundColor', [1 1 1],...
    'Position',[42 8.2 40 1.7]);

gui.obswin.textBox(4) = uicontrol(gui.paraPanel(OBSWIN_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Observation Window #','Position',[0 14 40 1.7]);

gui.obswin.popupmenu = uicontrol(gui.paraPanel(OBSWIN_PANEL),'Style', 'popupmenu',...
    'String', GetString('obswin'),...
    'Units','characters',...
    'UserData',1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectObswin});

gui.obswin.addObswin = uicontrol( gui.paraPanel(OBSWIN_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Observe Win',...
    'Position',[70 1 27 1.7],...
    'Callback',{@AddObswin});

gui.obswin.removeObswin = uicontrol( gui.paraPanel(OBSWIN_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Observe Win',...
    'Position',[41 1 27 1.7],...
    'Callback',{@RemoveObswin});

%% Object Path Parameter Panel
gui.paraPanel(PATH_PANEL) = uipanel('Parent',gui.main,'Title','Edit Object Path Parameters','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.path.textBox(1) = uicontrol(gui.paraPanel(PATH_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','X-coord (pixel)','Position',[0 12 40 1.7]);

gui.path.editBox(1) = uicontrol(gui.paraPanel(PATH_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(path(1).x),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 40 1.7]);

gui.path.textBox(2) = uicontrol(gui.paraPanel(PATH_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Y-coord (pixel)','Position',[0 10 40 1.7]);

gui.path.editBox(2) = uicontrol(gui.paraPanel(PATH_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(path(1).y),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 40 1.7]);

gui.path.textBox(3) = uicontrol(gui.paraPanel(PATH_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Object(Image) Size Ratio','Position',[0 8 40 1.7]);

gui.path.editBox(3) = uicontrol(gui.paraPanel(PATH_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(path(1).objSizeRatio,'%g '),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 8.2 40 1.7]);

gui.path.textBox(4) = uicontrol(gui.paraPanel(PATH_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Object(Image) Speed Ratio','Position',[0 6 40 1.7]);

gui.path.editBox(4) = uicontrol(gui.paraPanel(PATH_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(path(1).objSpeedRatio,'%g '),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 6.2 40 1.7]);

gui.path.textBox(5) = uicontrol(gui.paraPanel(PATH_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Path #','Position',[0 14 40 1.7]);

gui.path.popupmenu = uicontrol(gui.paraPanel(PATH_PANEL),'Style', 'popupmenu',...
    'String', GetString('path'),...
    'Units','characters',...
    'UserData', 1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectPath});

gui.path.addPath = uicontrol( gui.paraPanel(PATH_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Path',...
    'Position',[70 1 27 1.7],...
    'Callback',{@AddPath});

gui.path.removePath = uicontrol( gui.paraPanel(PATH_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Path',...
    'Position',[41 1 27 1.7],...
    'Callback',{@RemovePath});

%% Setup Effect on Path's nodes
gui.paraPanel(EFFECT_PANEL) = uipanel('Parent',gui.main,'Title','Edit Effect on Nodes of Path','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.effect.textBox(1) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Path #','Position',[0 14 40 1.7]);

gui.effect.popupmenu(1) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', GetString('path'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectEffectPath});

gui.effect.textBox(2) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Node #','Position',[0 12 40 1.7]);

nodeStr = [];
for i = 1:length(path(1).x)
    nodeStr{i} = [num2str(i) '. (' num2str(path(1).x(i)) ', ' num2str(path(1).y(i)) ')'];
end
gui.effect.popupmenu(2) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', nodeStr,...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [42 12.2 40 1.7],...
    'Callback', {@SelectEffectNode});

gui.effect.textBox(3) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Sound Effect','Position',[0 10 40 1.7]);

soundStr = GetString('sound');
gui.effect.popupmenu(3) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', soundStr,...
    'Units','characters',...
    'UserData', length(soundStr),...
    'Value', length(soundStr),...
    'Position', [42 10.2 40 1.7],...
    'Callback', {@SelectEffectSound});

gui.effect.textBox(4) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Loom Effect','Position',[0 8 40 1.7]);

loomStr = GetString('loomEffect');
gui.effect.popupmenu(4) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', loomStr,...
    'Units','characters',...
    'UserData', length(loomStr),...
    'Value', length(loomStr),...
    'Position', [42 8.2 40 1.7],...
    'Callback', {@SelectEffectLoom});

gui.effect.textBox(5) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Sound Random Set #','Position',[0 6 40 1.7]);

randomSetStr = GetString('randomSet');
gui.effect.popupmenu(5) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', randomSetStr,...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [42 6.2 40 1.7],...
    'Callback', {@SelectEffectRandomSet});

gui.effect.textBox(6) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Attention(observation) Win #','Position',[0 4 40 1.7]);

randomSetStr = GetString('obswin');
gui.effect.popupmenu(6) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style', 'popupmenu',...
    'String', randomSetStr,...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [42 4.2 18 1.7],...
    'Callback', {@SelectEffectObsWin});

gui.effect.CheckboxWaitAttention = uicontrol( gui.paraPanel(EFFECT_PANEL),...
    'Style','checkbox',...
    'Value', path(1).waitAttention(1),...
    'FontSize',10,...
    'Units','characters',...
    'String','Wait Attention',...
    'Position',[62 4.2 25 1.7],...
    'Callback', {@SelectEffectWaitAttention});

gui.effect.textBox(7) = uicontrol(gui.paraPanel(EFFECT_PANEL),'Style','text','FontSize',10,'ForegroundColor',[0.5 0 0],'HorizontalAlign','left','Units','characters','String','Press key ‘g’ to quit the Wait Attention anytime.','Position',[2 0 80 1.7]);

%% Construct structures for experiment
gui.paraPanel(STRUCTURE_PANEL) = uipanel('Parent',gui.main,'Title','Construct Structures','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.struct.textBox(3) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Structure #','Position',[0 14 22 1.7]);

gui.struct.popupmenu(1) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('struct'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [24 14.2 40 1.7],...
    'Callback', {@SelectStructure});

gui.struct.textBox(4) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Path #','Position',[0 12 22 1.7]);

gui.struct.popupmenu(2) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('path'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [24 12.2 12 1.7]);

gui.struct.textBox(5) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Mask #','Position',[37 12 15 1.7]);

gui.struct.popupmenu(3) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('mask'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [54 12.2 10 1.7]);

gui.struct.textBox(6) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Image','Position',[0 10 22 1.7]);

gui.struct.popupmenu(4) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('img'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [24 10.2 40 1.7]);

gui.struct.textBox(7) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Image:  Shape','Position',[0 8 22 1.7]);

gui.struct.popupmenu(5) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',{'Circle' 'Square'},...
    'Value', structure(1).imgShape,...
    'Position',[24 8.2 12 1.7]);

gui.struct.textBox(1) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Diameter','Position',[37 8 16 1.7]);

gui.struct.editBox(1) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).imgSize),...
    'BackgroundColor', [1 1 1],...
    'Position',[54 8.2 10 1.7]);

gui.struct.textBox(2) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Speed (pix/s)','Position',[68 8 15 1.7]);

gui.struct.editBox(2) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).imgMoveSpeed),...
    'BackgroundColor', [1 1 1],...
    'Position',[85 8.2 10 1.7]);

gui.struct.popupmenuFGImg = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('FBimg'),...
    'Units','characters',...
    'UserData', structure(1).foregroundImgNum,...
    'Value', structure(1).foregroundImgNum,...
    'Position', [24 6.2 23 1.7]);

gui.struct.checkboxFGImg = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style', 'checkbox',...
    'FontSize',10,...
    'Units','characters',...
    'String','Use Front Img',...
    'Value', structure(1).useForegroundImg,...
    'Position', [1 6.2 22 1.7]);

gui.struct.popupmenuBGImg = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('FBimg'),...
    'Units','characters',...
    'UserData', structure(1).backgroundImgNum,...
    'Value', structure(1).backgroundImgNum,...
    'Position', [72 6.2 23 1.7]);

gui.struct.checkboxBGImg = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style', 'checkbox',...
    'FontSize',10,...
    'Units','characters',...
    'String','Use BG Img',...
    'Value', structure(1).useBackgroundImg,...
    'Position', [53 6.2 18 1.7]);

% Reward Movie stuff
gui.struct.checkboxUseRewardMovie = uicontrol( gui.paraPanel(STRUCTURE_PANEL),...
    'Style','checkbox',...
    'Value', structure(1).useRewardMovie,...
    'FontSize',10,...
    'Units','characters',...
    'String','Use Reward mv',...
    'Position',[1 4.2 22 1.7]);
gui.struct.popupmenuMovieFile = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style', 'popupmenu',...
    'String', GetString('movieFile'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [24 4.2 23 1.7]);
gui.struct.textBox(8) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','with Shape','Position', [47 4 13 1.7]);
gui.struct.popupmenuMovieShape = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',{'Circle' 'Square'},...
    'Value', structure(1).movieShape,...
    'Position',[61 4.2 12 1.7]);
gui.struct.textBox(8) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Delay(s)','Position', [73 4 10 1.7]);
gui.struct.editBoxMovieDelay = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).movieDelay),...
    'BackgroundColor', [1 1 1],...
    'Position',[85 4.2 10 1.7]);
gui.struct.textBox(8) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Movie: center(x,y)','Position', [0 2 22 1.7]);
gui.struct.editBoxMovieCenter = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).movieCenter, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 2.2 15 1.7]);
gui.struct.textBox(8) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Width','Position',[42 2 10 1.7]);
gui.struct.editBoxMovieWidth = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(i).movieWidth),...
    'BackgroundColor', [1 1 1],...
    'Position',[54 2.2 10 1.7]);
gui.struct.textBox(8) = uicontrol(gui.paraPanel(STRUCTURE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Duration(s)','Position',[68 2 15 1.7]);
gui.struct.editBoxMovieDuration = uicontrol(gui.paraPanel(STRUCTURE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).movieDuration),...
    'BackgroundColor', [1 1 1],...
    'Position',[85 2.2 10 1.7]);

gui.struct.addStruct = uicontrol( gui.paraPanel(STRUCTURE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Struct',...
    'Position',[70 0.2 27 1.7],...
    'Callback',{@AddStructure});

gui.struct.removeStruct = uicontrol( gui.paraPanel(STRUCTURE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Struct',...
    'Position',[41 0.2 27 1.7],...
    'Callback',{@RemoveStructure});

%% Experiment Phase Panel
gui.paraPanel(PHASE_PANEL) = uipanel('Parent',gui.main,'Title','Edit Experiment Phase','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.phase.textBox(1) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Struct# in order','Position',[0 12 22 1.7]);

gui.phase.editBox(1) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).structNum, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 12.2 40 1.7]);

gui.phase.checkBox = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','checkbox',...
    'Units','characters',...
    'FontSize',10,...
    'String', 'Random',...
    'Value', phase(1).random,...
    'UserData', phase(1).random,...
    'Position',[66 12.2 15 1.7]);

gui.phase.textBox(2) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Total trials #','Position',[0 8 22 1.7]);

gui.phase.editBox(2) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).trialNum),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 8.2 40 1.7]);

gui.phase.textBox(3) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Max Time (s)','Position',[0 4 22 1.7]);

gui.phase.editBox(3) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).maxTime),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 4.2 40 1.7]);


gui.phase.textBox(4) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Opaque:  Start%','Position',[0 2 22 1.7]);

gui.phase.editBox(4) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).maskOpaqueStart),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 2.2 10 1.7]);

gui.phase.textBox(5) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Inc Step%','Position',[37 2 15 1.7]);

gui.phase.editBox(5) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).maskOpaqueIncStep),...
    'BackgroundColor', [1 1 1],...
    'Position',[54 2.2 10 1.7]);

gui.phase.textBox(6) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','End%','Position',[68 2 15 1.7]);

gui.phase.editBox(6) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).maskOpaqueEnd),...
    'BackgroundColor', [1 1 1],...
    'Position',[85 2.2 10 1.7]);

gui.phase.textBox(7) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Wait between(s)','Position',[0 6 22 1.7]);

gui.phase.editBox(7) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str([phase(1).waitTime1 phase(1).waitTime2]),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 6.2 40 1.7]);

gui.phase.textBox(8) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Struct Weight','Position',[0 10 22 1.7]);

gui.phase.editBox(8) = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).structWeight, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 10.2 40 1.7]);

gui.phase.checkBox2 = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','checkbox',...
    'Units','characters',...
    'FontSize',10,...
    'String', 'Fix',...
    'Value', phase(1).fixPercentage,...
    'UserData', phase(1).fixPercentage,...
    'Position',[66 10.2 25 1.7]);

%MO: This checkbox added to control background
gui.phase.checkBox3 = uicontrol(gui.paraPanel(PHASE_PANEL),...
    'Style','checkbox',...
    'Units','characters',...
    'FontSize',10,...
    'String', 'Blank ISI',...
    'Value', phase(1).blankISI,...
    'UserData', phase(1).blankISI,...
    'Position',[66 6.2 15 1.7]);

gui.phase.textBox(9) = uicontrol(gui.paraPanel(PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Phase #','Position',[0 14 22 1.7]);

gui.phase.popupmenu = uicontrol(gui.paraPanel(PHASE_PANEL),'Style', 'popupmenu',...
    'String', GetString('phase'),...
    'Units','characters',...
    'UserData', 1,...
    'Position', [24 14.2 40 1.7],...
    'Callback', {@SelectPhase});

gui.phase.addPath = uicontrol( gui.paraPanel(PHASE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Phase',...
    'Position',[70 0.2 27 1.7],...
    'Callback',{@AddPhase});

gui.phase.removePath = uicontrol( gui.paraPanel(PHASE_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Phase',...
    'Position',[41 0.2 27 1.7],...
    'Callback',{@RemovePhase});

%% Random set of sounds' Panel
gui.paraPanel(RANDOMSET_PANEL) = uipanel('Parent',gui.main,'Title','Edit Random Set of Sound Files','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.randomSet.textBox(1) = uicontrol(gui.paraPanel(RANDOMSET_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Random Set of Sound Files','Position',[0 12 40 1.7]);

gui.randomSet.editBox(1) = uicontrol(gui.paraPanel(RANDOMSET_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(randomSet(1).soundFiles),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 40 1.7]);

gui.randomSet.textBox(2) = uicontrol(gui.paraPanel(RANDOMSET_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Random Set #','Position',[0 14 40 1.7]);

gui.randomSet.popupmenu = uicontrol(gui.paraPanel(RANDOMSET_PANEL),'Style', 'popupmenu',...
    'String', GetString('randomSet'),...
    'Units','characters',...
    'UserData', 1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectRandomSet});

gui.randomSet.addRandomSet = uicontrol( gui.paraPanel(RANDOMSET_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Add Set',...
    'Position',[70 1 27 1.7],...
    'Callback',{@AddRandomSet});

gui.randomSet.removeRandomSet = uicontrol( gui.paraPanel(RANDOMSET_PANEL),...
    'Style','push',...
    'FontSize',10,...
    'Units','characters',...
    'String','Remove Set',...
    'Position',[41 1 27 1.7],...
    'Callback',{@RemoveRandomSet});

%% This panel will set structure attribute
gui.paraPanel(STRUCT_ATTRIBUTE_PANEL) = uipanel('Parent',gui.main,'Title','Edit Structures Attribute (Define good trial)','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Structure #','Position',[0 14 40 1.7]);

gui.structAttribute.popupmenuStruct = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style', 'popupmenu',...
    'String', GetString('struct'),...
    'Units','characters',...
    'UserData', 1,...
    'Value', 1,...
    'Position', [42 14.2 40 1.7],...
    'Callback', {@SelectStructureAttribute});

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Correct ObsWins','Position',[0 10 40 1.7]);

gui.structAttribute.editBoxCorrObsWins = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).correctObsWins,'%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 40 1.7]);

gui.structAttribute.textBoxCorrObsWins = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',['(1-' num2str(length(obswin)) ')'],'Position',[83 10 10 1.7]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Incorrect ObsWins','Position',[0 8 40 1.7]);

gui.structAttribute.editBoxIncorrObsWins = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).incorrectObsWins,'%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 8.2 40 1.7]);

gui.structAttribute.textBoxIncorrObsWins = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',['(1-' num2str(length(obswin)) ')'],'Position',[83 8 10 1.7]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Above Wins: Require Looking%','Position',[0 6 40 1.7]);

gui.structAttribute.editBoxRequireLooking = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).requireLooking),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 6.2 40 1.7]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Look at Screen Time (ms)','Position',[0 4 40 1.7]);

gui.structAttribute.editBoxLookScrTime = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).lookScrTime),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 4.2 40 1.7]);

gui.structAttribute.textBoxMaxTime = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',['(' num2str(FindMaxTime(1)*1000,'%.0f') 'ms)'],'Position',[83 4 12 1.7]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Validity Level (0-4)','Position',[0 2 40 1.7]);

gui.structAttribute.editBoxValidityLevel = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(structure(1).validityLevel),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 2.2 40 1.7]);

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Interesting Node: Start','Position',[0 12 40 1.7]);

tmpstr = num2str(1:length(path(structure(1).pathNum).x), '%d|');
gui.structAttribute.popupmenuNodeStart = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr(1:end-1),...
    'Value', structure(1).interestNodes(1),...
    'Position',[42 12.2 12 1.7],...
    'Callback', {@SelectInterestNode});

gui.structAttribute.textBox = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','End','Position',[60 12 8 1.7]);

gui.structAttribute.popupmenuNodeEnd = uicontrol(gui.paraPanel(STRUCT_ATTRIBUTE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr(1:end-1),...
    'Value', structure(1).interestNodes(2),...
    'Position',[70 12.2 12 1.7],...
    'Callback', {@SelectInterestNode});

%% This panel will set quitting phase conditions
gui.paraPanel(QUIT_PHASE_PANEL) = uipanel('Parent',gui.main,'Title','Edit Phase Quitting Conditions','FontSize',10,...
    'Units','characters','Visible','off',...
    'Position',[2 Position(4)-23 100 18]);

gui.quitPhase.CheckboxUseQuitCond = uicontrol( gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','checkbox',...
    'Value', phase(1).useQuittingCond,...
    'FontSize',10,...
    'Units','characters',...
    'String','Use Condition',...
    'Tag','Debug', ...
    'Position',[2 0.2 20 1.7]);

gui.quitPhase.CheckboxUseTotalTrialsCond = uicontrol( gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','checkbox',...
    'Value', phase(1).useTotalTrials,...
    'FontSize',10,...
    'Units','characters',...
    'String','Use Total trials',...
    'Tag','Debug', ...
    'Position',[30 0.2 22 1.7]);

gui.quitPhase.textBoxTotalTrial = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',['(' num2str(phase(1).trialNum) ')'],'Position',[52 0 10 1.7]);

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Phase #','Position',[0 14 40 1.7]);

gui.quitPhase.popupmenuPhaseNum = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style', 'popupmenu',...
    'String', GetString('phase'),...
    'Units','characters',...
    'UserData', 1,...
    'Position', [42 14.2 30 1.7],...
    'Callback', {@SelectQuitPhase});

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Interesting Structs #','Position',[0 12 40 1.7]);

gui.quitPhase.editBoxInterestStruct = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).interestStructs, '%d '),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 12.2 30 1.7]);

gui.quitPhase.textBoxAllStruct = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',['(' num2str(phase(1).structNum, '%d ') ')'],'Position',[73 12 22 1.7]);

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','Total Looking:','Position',[2 10 18 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Correct Look%','Position',[20 10 20 1.7]);
gui.quitPhase.editBoxTotalLookPercentage = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).totalLook.lookPercentage),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 10.2 15 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Last n trails','Position',[60 10 18 1.7]);
gui.quitPhase.editBoxTotalLookLastNtrail = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).numOfLastTrial(TOTAL_LOOK)),...
    'BackgroundColor', [1 1 1],...
    'Position',[80 10.2 15 1.7]);

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','First Looking:','Position',[2 8 18 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Correct Look#','Position',[20 8 20 1.7]);
gui.quitPhase.editBoxFirstLookNum = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).firstLook.numOfCorrLook),...
    'BackgroundColor', [1 1 1],...
    'Position',[42 8.2 15 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Last n trails','Position',[60 8 18 1.7]);
gui.quitPhase.editBoxFirstLookLastNtrail = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).numOfLastTrial(FIRST_LOOK)),...
    'BackgroundColor', [1 1 1],...
    'Position',[80 8.2 15 1.7]);

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','Ttest:     mean%','Position',[2 6 20 1.7]);
gui.quitPhase.editBoxTtestMean = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).ttest.mean),...
    'BackgroundColor', [1 1 1],...
    'Position',[24 6.2 10 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','alpha','Position',[35 6 10 1.7]);
gui.quitPhase.editBoxTtestAlpha = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).ttest.alpha),...
    'BackgroundColor', [1 1 1],...
    'Position',[47 6.2 10 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','right','Units','characters','String','Last n trails','Position',[60 6 18 1.7]);
gui.quitPhase.editBoxTtestLastNtrail = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','edit',...
    'FontSize',10,...
    'HorizontalAlign','left',...
    'Units','characters',...
    'String',num2str(phase(1).numOfLastTrial(TTEST)),...
    'BackgroundColor', [1 1 1],...
    'Position',[80 6.2 15 1.7]);

gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String','Logic:   (','Position',[2 4 11 1.7]);
tmpstr1 = {'Total Looking', 'First Looking', 'Ttest'};
gui.quitPhase.popupmenuTtestLogicA = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr1,...
    'Value', phase(1).conditions(1),...
    'Position',[14 4.2 18 1.7]);
tmpstr2 = {'And','Or','None'};
gui.quitPhase.popupmenuTtestLogicAndOr1 = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr2,...
    'Value', phase(1).logics(1),...
    'Position',[34 4.2 10 1.7]);
tmpstr1 = {'Total Looking', 'First Looking', 'Ttest', 'None'};
gui.quitPhase.popupmenuTtestLogicB = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr1,...
    'Value', phase(1).conditions(2),...
    'Position',[46 4.2 18 1.7]);
gui.quitPhase.textBox = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),'Style','text','FontSize',10,'HorizontalAlign','left','Units','characters','String',')','Position',[65 4 2 1.7]);
gui.quitPhase.popupmenuTtestLogicAndOr2 = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr2,...
    'Value', phase(1).logics(2),...
    'Position',[68 4.2 10 1.7]);
gui.quitPhase.popupmenuTtestLogicC = uicontrol(gui.paraPanel(QUIT_PHASE_PANEL),...
    'Style','popupmenu',...
    'Units','characters',...
    'String',tmpstr1,...
    'Value', phase(1).conditions(3),...
    'Position',[80 4.2 18 1.7]);

%% Callback function
%% Select Background color
    function SelectBgcolor(Object, eventdata, handles)
        if Object == gui.screen.bgcolorButton
            scr.bgcolor = uisetcolor(scr.bgcolor/255)*255;
            set(gui.screen.editBox(3), 'String', [num2str(scr.bgcolor(1)) ' ' num2str(scr.bgcolor(2)) ' ' num2str(scr.bgcolor(3))]);
        elseif Object == gui.mask.colorButton
            v = get(gui.mask.popupmenu,'Value');
            mask(v).color(1:3) = uisetcolor(mask(v).color(1:3)/255)*255;
            set(gui.mask.editBox(3), 'String', [num2str(mask(v).color(1)) ' ' num2str(mask(v).color(2)) ' ' num2str(mask(v).color(3))]);
        end
        ApplyPara([],[],[]);
    end

%% Show Screen
    function ShowScreen(Object, eventdata, handles)
        ApplyPara([],[],[]);
        InitPara;
        InitTobii;
        InitSoundEffect();
        vbl = CreateStimulationWin();
        DoExperiment(vbl);
        %TobiiScreen;
    end

%% MO: Added this function - 
    function AboutStuff(Object, eventdata, handles)
        aboutmesg=[{'SMART-T: System for Monitoring Anticipations in Real Time with the TOBII'};...
            {'Developed at the Aslin Lab, University of Rochester'};...
            {'Designed, developed & coded by Mo & Johnny'};...
            {['Current Version: ' num2str(smarttVersion,'%.1f')]};...
            {'Contact: mshukla@bcs.rochester.edu'};...
            {'Thanks to aslin@bcs, kwhite@bcs and Babylab'}];
        if exist('smartt_icon.png')
            mo_var=imread('smartt_icon.png');
            mo_var_h = msgbox(aboutmesg,'About','custom',mo_var);
        else
            mo_var_h = msgbox(aboutmesg,'About','help');
        end
    end

%% Close Screen
    function CloseScreen(Object, eventdata, handles)
        CloseOpenAL;
        Screen('CloseAll');
        ShowCursor;
        Priority(0);
        scr.winPrt = [];
    end

%% reset parameter of path
    function SelectPath(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.path.popupmenu, 'UserData');
                set(gui.path.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.path.popupmenu, 'Value');
        set(gui.path.popupmenu, 'UserData', v);
        set(gui.path.editBox(1),'String',num2str(path(v).x));
        set(gui.path.editBox(2),'String',num2str(path(v).y));
        set(gui.path.editBox(3),'String',num2str(path(v).objSizeRatio, '%g '));
        set(gui.path.editBox(4),'String',num2str(path(v).objSpeedRatio, '%g '));
    end

%% Add path
    function AddPath(Object, eventdata, handles)
        ApplyPara([],[],[]);

        pathNum = length(path);
        v = get(gui.path.popupmenu, 'Value');
        path(pathNum+1) = path(v);
        path(pathNum+1).soundEffect(1:length(path(pathNum+1).x)) = (length(sound)+2)*ones(1,length(path(pathNum+1).x));
        path(pathNum+1).loomEffect(1:length(path(pathNum+1).x)) = (length(loom)+2)*ones(1,length(path(pathNum+1).x));
        path(pathNum+1).soundRandomSetIndex(1:length(path(pathNum+1).x)) = ones(1,length(path(pathNum+1).x)); % default 1st set
        path(pathNum+1).waitAttention(1:length(path(pathNum+1).x)) = zeros(1,length(path(pathNum+1).x)); % default not wait for attention
        path(pathNum+1).attentionWin(1:length(path(pathNum+1).x)) = ones(1,length(path(pathNum+1).x)); % default 1st observation window
        path(pathNum+1).objSizeRatio = ones(1,length(path(pathNum+1).x)); % default ratio = 1
        path(pathNum+1).objSpeedRatio = ones(1,length(path(pathNum+1).x)-1); % default ratio = 1

        set(gui.path.popupmenu, 'String', GetString('path'), 'Value',pathNum+1, 'UserData',pathNum+1);
        SelectPath([], [], []);

        UpdateStructGUI('path', 'add', v);
    end

%% Remove Path
    function RemovePath(Object, eventdata, handles)
        if length(path) <= 1
            warndlg('Last path cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.path.popupmenu,'Value');
        path(v) = [];

        set(gui.path.popupmenu, 'String', GetString('path'), 'Value', 1, 'UserData', 1);
        SelectPath([], [], []);

        UpdateStructGUI('path', 'remove', v);
    end

%% reset parameter of random set
    function SelectRandomSet(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.randomSet.popupmenu, 'UserData');
                set(gui.randomSet.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.randomSet.popupmenu, 'Value');
        set(gui.randomSet.popupmenu, 'UserData', v);
        set(gui.randomSet.editBox(1),'String',num2str(randomSet(v).soundFiles));
    end

%% Add random set
    function AddRandomSet(Object, eventdata, handles)
        ApplyPara([],[],[]);

        setNum = length(randomSet);
        randomSet(setNum+1).soundFiles = [1:length(sound)];

        set(gui.randomSet.popupmenu, 'String', GetString('randomSet'), 'Value',setNum+1, 'UserData',setNum+1);
        SelectRandomSet([],[],[]);
    end

%% Remove random set
    function RemoveRandomSet(Object, eventdata, handles)
        if length(randomSet) <= 1
            warndlg('Last random set cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.randomSet.popupmenu,'Value');
        randomSet(v) = [];

        set(gui.randomSet.popupmenu, 'String', GetString('randomSet'), 'Value', 1, 'UserData', 1);
        SelectRandomSet([],[],[]);

        UpdateEffectGUI('randomSet', 'remove', v);
        addRemoveRandomSet = true;
    end

%% reset parameter of observation windows
    function SelectObswin(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.obswin.popupmenu, 'UserData');
                set(gui.obswin.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.obswin.popupmenu, 'Value');
        set(gui.obswin.popupmenu, 'UserData', v);
        set(gui.obswin.editBox(1),'String',num2str(obswin(v).width));
        set(gui.obswin.editBox(2),'String',num2str(obswin(v).height));
        set(gui.obswin.editBox(3),'String',[num2str(obswin(v).upperLeftCorner(1)) ' ' num2str(obswin(v).upperLeftCorner(2))]);
    end

%% reset parameter of loom effect
    function SelectLoomEffect(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.loom.popupmenu, 'UserData');
                set(gui.loom.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.loom.popupmenu, 'Value');
        set(gui.loom.popupmenu, 'UserData', v);
        set(gui.loom.editBox(1),'String',num2str(loom(v).growSize));
        set(gui.loom.editBox(2),'String',num2str(loom(v).duration));
    end

%% reset parameter of mask
    function SelectMask(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.mask.popupmenu, 'UserData');
                set(gui.mask.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.mask.popupmenu, 'Value');
        set(gui.mask.popupmenu, 'UserData', v);
        set(gui.mask.editBox(1),'String',num2str(mask(v).x, '%d '));
        set(gui.mask.editBox(2),'String',num2str(mask(v).y, '%d '));
        set(gui.mask.editBox(3),'String',[num2str(mask(v).color(1)) ' ' num2str(mask(v).color(2)) ' ' num2str(mask(v).color(3))]);
    end

%% reset the edit panel of parameter
    function SetupParaListBox(Object, eventdata, handles)
        s = get(gui.paraListBox, 'String');
        v = get(gui.paraListBox, 'UserData');
        error = CheckInput(s, v);

        if error
            set(gui.paraListBox,'Value',v);
            return;
        end

        if strcmp(s(v),'Sound') && addRemoveSound
            warndlg('If you add or remove any sound files, please modify the Effect and Random Set!' , '!! Warning !!');
            addRemoveSound = false;
        elseif strcmp(s(v),'Loom') && addRemoveLoom
            warndlg('If you add or remove any loom, please modify the Effect!' , '!! Warning !!');
            addRemoveLoom = false;
        elseif strcmp(s(v),'Random Set')&& addRemoveRandomSet
            warndlg('If you add or remove any random set, please modify the Effect!' , '!! Warning !!');
            addRemoveRandomSet = false;
        end

        v = get(gui.paraListBox, 'Value');
        if length(v) ~= 1
            v = v(1);
            set(gui.paraListBox,'Value',v);
        end
        set(gui.paraListBox,'UserData',v);

        for i = 1:length(gui.paraPanel)
            set(gui.paraPanel(i),'Visible','off');
        end
        set(gui.paraPanel(v),'Visible','on');

        if strcmp(s(v),'Effect')
            set(gui.effect.popupmenu(1), 'String', GetString('path'), 'UserData', 1, 'Value', 1);
            SelectEffectPath([],[],[]);
        elseif strcmp(s(v),'Struct Attribute')
            SelectStructureAttribute([],[],[]);
        elseif strcmp(s(v),'Quit Phase')
            SelectQuitPhase([],[],[]);
        end

    end

%% add image files
    function AddImgFile(Object, eventdata, handles)
        [filename, pathname, FilterIndex] = uigetfile('*.jpg','Select .jpg file', 'MultiSelect', 'on');
        if FilterIndex == 0
            return
        end

        if ~iscell(filename)
            filename = cellstr(filename);
        end

        imgNum = length(img);

        for i = 1:length(filename)
            img(imgNum+i).filename = [pathname filename{i}];
        end

        set(gui.object.imgListBox, 'String', GetString('imgFile'));
        set(gui.struct.popupmenuFGImg, 'String', GetString('imgFile'));
        set(gui.struct.popupmenuBGImg, 'String', GetString('imgFile'));

        UpdateStructGUI('image', 'add', []);
    end

%% remove mult image files
    function RemoveImgFile(Object, eventdata, handles)
        s = get(gui.object.imgListBox, 'String');
        v = get(gui.object.imgListBox, 'Value');

        if isempty(s) || isempty(v)
            return;
        end
        img(v) = [];

        set(gui.object.imgListBox, 'String', GetString('imgFile'), 'Value', 1);
        set(gui.struct.popupmenuFGImg, 'String', GetString('imgFile'), 'Value', 1);
        set(gui.struct.popupmenuBGImg, 'String', GetString('imgFile'), 'Value', 1);

        UpdateStructGUI('image', 'remove', v);
    end

%% add movie files
    function AddMovieFile(Object, eventdata, handles)
        [filename, pathname, FilterIndex] = uigetfile('*.mov','Select .mov file', 'MultiSelect', 'on');
        if FilterIndex == 0
            return
        end

        if ~iscell(filename)
            filename = cellstr(filename);
        end

        movieNum = length(movie);

        for i = 1:length(filename)
            movie(movieNum+i).filename = [pathname filename{i}];
        end

        set(gui.movie.listBox, 'String', GetString('movieFile'));

        UpdateStructGUI('movie', 'add', []);
    end

%% remove mult movie files
    function RemoveMovieFile(Object, eventdata, handles)
        s = get(gui.movie.listBox, 'String');
        v = get(gui.movie.listBox, 'Value');

        if isempty(s) || isempty(v)
            return;
        end
        movie(v) = [];

        set(gui.movie.listBox, 'String', GetString('movieFile'), 'Value', 1);

        UpdateStructGUI('movie', 'remove', v);
    end


%% add sound files
    function AddSoundFile(Object, eventdata, handles)
        [filename, pathname, FilterIndex] = uigetfile('*.wav','Select .wav file', 'MultiSelect', 'on');
        if FilterIndex == 0
            return
        end

        if ~iscell(filename)
            filename = cellstr(filename);
        end

        soundNum = length(sound);

        for i = 1:length(filename)
            sound(soundNum+i).filename = [pathname filename{i}];
        end

        set(gui.sound.ListBox, 'String', GetString('soundFile'));

        UpdateEffectGUI('sound', 'add', []);

        addRemoveSound = true;
    end

%% remove mult sound files
    function RemoveSoundFile(Object, eventdata, handles)
        s = get(gui.sound.ListBox, 'String');
        v = get(gui.sound.ListBox, 'Value');

        if isempty(s) || isempty(v)
            return;
        end
        sound(v) = [];

        set(gui.sound.ListBox, 'String', GetString('soundFile'), 'Value', 1);

        UpdateEffectGUI('sound', 'remove', v);

        addRemoveSound = true;
    end

%% Add Loom Effect
    function AddLoomEffect(Object, eventdata, handles)
        ApplyPara([],[],[]);

        loomNum = length(loom);
        v = get(gui.loom.popupmenu, 'Value');
        loom(loomNum+1) = loom(v);

        set(gui.loom.popupmenu, 'String', GetString('loom'), 'Value',loomNum+1,'UserData', loomNum+1);
        SelectLoomEffect([], [], []);

        UpdateEffectGUI('loom', 'add', []);

        addRemoveLoom = true;
    end

%% Remove Loom Effect
    function RemoveLoomEffect(Object, eventdata, handles)
        if length(loom) <= 1
            warndlg('Last loom effect cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.loom.popupmenu,'Value');
        loom(v) = [];

        set(gui.loom.popupmenu, 'String', GetString('loom'), 'Value', 1, 'UserData', 1);
        SelectLoomEffect([], [], []);

        UpdateEffectGUI('loom', 'remove', v);

        addRemoveLoom = true;
    end

%% Add observation windows
    function AddObswin(Object, eventdata, handles)
        ApplyPara([],[],[]);

        winNum = length(obswin);
        v = get(gui.obswin.popupmenu, 'Value');
        obswin(winNum+1) = obswin(v);

        set(gui.obswin.popupmenu, 'String', GetString('obswin'), 'Value',winNum+1,'UserData', winNum+1);
        SelectObswin([], [], []);
    end

%% Remove observation window
    function RemoveObswin(Object, eventdata, handles)
        if length(obswin) <= 1
            warndlg('Last observation window cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.obswin.popupmenu,'Value');
        obswin(v) = [];

        set(gui.obswin.popupmenu, 'String', GetString('obswin'), 'Value', 1, 'UserData', 1);
        SelectObswin([], [], []);

        str = [];
        for si=1:length(structure)
            I = find(structure(si).correctObsWins > length(obswin));
            if ~isempty(I)
                str = sprintf('%s\nStructure# %d will remove ObsWins# %s in Correct ObsWins!',str, si, num2str(structure(si).correctObsWins(I),'%d ') );
                structure(si).correctObsWins(I) = [];
                if isempty(structure(si).correctObsWins)
                    structure(si).correctObsWins = 1;
                end
            end
            I = find(structure(si).incorrectObsWins > length(obswin));
            if ~isempty(I)
                str = sprintf('%s\nStructure# %d will remove ObsWins# %s in Incorrect ObsWins!',str, si, num2str(structure(si).incorrectObsWins(I),'%d ') );
                structure(si).incorrectObsWins(I) = [];
                if isempty(structure(si).incorrectObsWins)
                    structure(si).incorrectObsWins = 1;
                end
            end
        end

        if ~isempty(str)
            warndlg(str, '!! Warning !!');
            disp(str);
        end
    end

%% Add Mask
    function AddMask(Object, eventdata, handles)
        ApplyPara([],[],[]);

        maskNum = length(mask);
        v = get(gui.mask.popupmenu, 'Value');
        mask(maskNum+1) = mask(v);
        set(gui.mask.popupmenu, 'String', GetString('mask'), 'Value',maskNum+1, 'UserData', maskNum+1);
        SelectMask([], [], []);

        UpdateStructGUI('mask', 'add', v);
    end

%% Remove Mask
    function RemoveMask(Object, eventdata, handles)
        if length(mask) <= 1
            warndlg('Last mask cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.mask.popupmenu,'Value');
        mask(v) = [];

        set(gui.mask.popupmenu, 'String', GetString('mask'), 'Value', 1, 'UserData', 1);
        SelectMask([], [], []);

        UpdateStructGUI('mask', 'remove', v);
    end

%%  get input parameter file
    function BrowseParaFile(Object, eventdata, handles)
        [filename, pathname] = uigetfile('*.txt','Select the text file');
        if filename~=0
            set(gui.inputParaFile, 'String', [pathname filename]);
        else
            return;
        end

        ReadParaFile([pathname filename]);
        ResetGUI;
    end

%% save parameter file
    function SaveParaFile(Object, eventdata, handles)
        ApplyPara([],[],[]);

        [filename, pathname] = uiputfile('*.txt','Save as');
        if filename~=0
            set(gui.inputParaFile, 'String', [pathname filename]);
        else
            return;
        end

        % discard existing contents if file already exist
        fid = fopen([pathname filename], 'w');
        
        fprintf(fid, 'Version %.1f ''SMART-T version''\n',smarttVersion); %MO: SMARTT version - set by hand
        fprintf(fid, 'Debug %d ''1/0=On/Off''\n',debug);
        fprintf(fid, 'ConnTobii %d ''1/0=On/Off''\n',connTobii);
        fprintf(fid, 'ConnNIRS %d ''1/0=On/Off''\n',connNIRS);
        fprintf(fid, 'SerialOTNum %d ''1/0=On/Off''\n',SerialOTNum);%MO: was str2num(SerialOTNUm)
        fprintf(fid, 'TobiiIPaddress %s ''Tobii IP address''\n',scr.TobiiIPaddress);
        fprintf(fid, 'TobiiPortNum %s ''Tobii port number''\n',scr.TobiiPortNum);
        fprintf(fid, 'ScreenWidth %d ''screen width (pixel)''\n',scr.width);
        fprintf(fid, 'ScreenHeight %d ''screen height (pixel)''\n',scr.height);
        fprintf(fid, 'ScreenBGColor %f %f %f ''screen background color (RGB) (range:0-255)''\n',scr.bgcolor(1),scr.bgcolor(2),scr.bgcolor(3));

        for i=1:length(mask)
            fprintf(fid, 'MaskX %d', i);
            for j=1:length(mask(i).x)
                fprintf(fid, ' %d',mask(i).x(j));
            end
            fprintf(fid, ' ''mask polygon # & x coords (pixel)''\n');

            fprintf(fid, 'MaskY %d', i);
            for j=1:length(mask(i).y)
                fprintf(fid, ' %d',mask(i).y(j));
            end
            fprintf(fid, ' ''mask polygon # & y coords (pixel)''\n');

            fprintf(fid, 'MaskColor %d %f %f %f ''mask color (RGB) (range:0-255)''\n', i, mask(i).color(1:3));
        end

        for i=1:length(loom)
            fprintf(fid, 'Loom %d %f %f ''loom #, grow in size(%%) & duration(s)''\n', i, loom(i).growSize, loom(i).duration);
        end

        for i=1:length(img)
            fprintf(fid, 'ImgFile %d %s ''image file # & name''\n',i,img(i).filename);
        end

        for i=1:length(movie)
            fprintf(fid, 'MovieFile %d %s ''movie file # & name''\n',i,movie(i).filename);
        end

        for i=1:length(sound)
            fprintf(fid, 'SoundFile %d %s ''sound file # & name''\n',i,sound(i).filename);
        end

        for i=1:length(randomSet)
            fprintf(fid, 'RandomSet %d',i);
            for j=1:length(randomSet(i).soundFiles)
                fprintf(fid, ' %d',randomSet(i).soundFiles(j));
            end
            fprintf(fid, ' ''random set # & random set of sound files''\n');
        end

        for i=1:length(obswin)
            fprintf(fid, 'ObswinWidth %d %d ''observation window # & width (pixel)''\n',i,obswin(i).width);
            fprintf(fid, 'ObswinHeight %d %d ''observation window # & height (pixel)''\n',i,obswin(i).height);
            fprintf(fid, 'ObswinUpperLeftCorner %d %d %d ''observation window # & upper left corner (x,y) (pixel)''\n',i,obswin(i).upperLeftCorner(1),obswin(i).upperLeftCorner(2));
        end

        for i=1:length(path)
            fprintf(fid, 'PathX %d',i);
            for j=1:length(path(i).x)
                fprintf(fid, ' %d',path(i).x(j));
            end
            fprintf(fid, ' ''path # & x coords (pixel)''\n');

            fprintf(fid, 'PathY %d',i);
            for j=1:length(path(i).y)
                fprintf(fid, ' %d',path(i).y(j));
            end
            fprintf(fid, ' ''path # & y coords (pixel)''\n');

            fprintf(fid, 'PathSoundEffect %d',i);
            for j=1:length(path(i).soundEffect)
                fprintf(fid, ' %d',path(i).soundEffect(j));
            end
            fprintf(fid, ' ''path # & sound file index (n+1=random; n+2=none)''\n');

            fprintf(fid, 'PathLoomEffect %d',i);
            for j=1:length(path(i).loomEffect)
                fprintf(fid, ' %d',path(i).loomEffect(j));
            end
            fprintf(fid, ' ''path # & loom index (n+1=random; n+2=none)''\n');

            fprintf(fid, 'PathSoundRandomSetIndex %d',i);
            for j=1:length(path(i).soundRandomSetIndex)
                fprintf(fid, ' %d',path(i).soundRandomSetIndex(j));
            end
            fprintf(fid, ' ''path # & random set index''\n');

            fprintf(fid, 'PathWaitAttention %d %s ''path# & wait attention (1/0=T/F)''\n', i, num2str(path(i).waitAttention,'%d '));
            fprintf(fid, 'PathAttentionWin %d %s ''path# & attention(observation) win#''\n', i, num2str(path(i).attentionWin,'%d '));
            fprintf(fid, 'PathObjSizeRatio %d %s ''path# & object size ratios''\n', i, num2str(path(i).objSizeRatio,'%g '));
            fprintf(fid, 'PathObjSpeedRatio %d %s ''path# & object speed ratios''\n', i, num2str(path(i).objSpeedRatio,'%g '));
        end

        for i=1:length(structure)
            fprintf(fid, 'Struct %d %d %d %d %d %d %f ''struct#, path#, mask#, (img# or random=n+1), (1=circle, 2=square), imgSize(pix) & speed(pix/s)''\n',i,...
                structure(i).pathNum, structure(i).maskNum, structure(i).imgNum,...
                structure(i).imgShape, structure(i).imgSize, structure(i).imgMoveSpeed );
            fprintf(fid, 'StructFBImg %d %d %d %d %d ''struct#, foregroundImg#, useForegroundImg(1/0=T/F), backgroundImg#, useBackgroundImg(1/0=T/F)''\n',i,...
                structure(i).foregroundImgNum, structure(i).useForegroundImg,...
                structure(i).backgroundImgNum, structure(i).useBackgroundImg );
            fprintf(fid, 'StructMovie %d %d %d %d %g %g %g %g %g ''struct#, useRewardMovie(1/0=T/F), movieNum#, movieShape(1=circle, 2=square), movieCenter(x,y)(pix), movieWidth(pix), movieDuration(s), movieDelay(s)''\n',i,...
                structure(i).useRewardMovie, structure(i).movieNum, structure(i).movieShape,...
                structure(i).movieCenter(1), structure(i).movieCenter(2), structure(i).movieWidth,...
                structure(i).movieDuration, structure(i).movieDelay );
        end

        for i=1:length(phase)
            fprintf(fid, 'PhaseStruct %d', i);
            for j=1:length(phase(i).structNum)
                fprintf(fid, ' %d', phase(i).structNum(j));
            end
            fprintf(fid, ' ''phase# & struct# in order''\n');

            fprintf(fid, 'PhaseStructPerc %d', i);
            for j=1:length(phase(i).structWeight)
                fprintf(fid, ' %d', phase(i).structWeight(j));
            end
            fprintf(fid, ' ''phase# & struct weight in order''\n');
        end

        for i=1:length(phase)
            %MO: added description, extra %.3f and waitTime1/2 below
            %MO: also added blankISI
            fprintf(fid, 'Phase %d %d %d %d %d %.3f %.3f %.3f %.3f %.3f %.3f ''phase#, random struct(1/0=T/F), fix percentage(1/0=T/F), max trial#, blank ISI, wait between1(s), wait between2(s), max time(s), opaque(start:inc:end)%%''\n',i,...
                phase(i).random, phase(i).fixPercentage, phase(i).trialNum, phase(i).blankISI, phase(i).waitTime1, phase(i).waitTime2, phase(i).maxTime,...
                phase(i).maskOpaqueStart, phase(i).maskOpaqueIncStep, phase(i).maskOpaqueEnd );
        end

        % structure quitting condition
        for i=1:length(structure)
            fprintf(fid, 'StructInterestNodes %d %s ''struct#, Interest Nodes:start# & end#''\n', i, num2str(structure(i).interestNodes,'%g '));
            fprintf(fid, 'StructCorrObsWins %d %s ''struct#, Correct Observation Windows#''\n', i, num2str(structure(i).correctObsWins,'%g '));
            fprintf(fid, 'StructIncorrObsWins %d %s ''struct#, Incorrect Observation Windows#''\n', i, num2str(structure(i).incorrectObsWins,'%g '));
            fprintf(fid, 'StructGoodTrialConds %d %g %g %g ''struct#, require looking %%, look at screen time(ms), validity level(0-4)''\n', i,...
                structure(i).requireLooking, structure(i).lookScrTime,structure(i).validityLevel);
        end

        % phase quitting condition
        for i=1:length(phase)
            fprintf(fid, 'UseQuittingCond %d %d ''phase#, use quitting condition (1/0=T/F)''\n',i,phase(i).useQuittingCond);
            fprintf(fid, 'UseTotalTrials %d %d ''phase#, use Total trials (1/0=T/F)''\n',i,phase(i).useTotalTrials);
            fprintf(fid, 'InterestStructs %d %s ''phase#, interesting structs# for quitting''\n',i,num2str(phase(i).interestStructs,'%d '));
            fprintf(fid, 'TotalLookPercentage %d %g %d ''phase#, total look percentage, last n trials''\n',i,phase(i).totalLook.lookPercentage,phase(i).numOfLastTrial(TOTAL_LOOK));
            fprintf(fid, 'FirstLookPercentage %d %d %d ''phase#, first correct look#, last n trials''\n',i,phase(i).firstLook.numOfCorrLook,phase(i).numOfLastTrial(FIRST_LOOK));
            fprintf(fid, 'Ttest %d %g %g %d ''phase#, ttest: mean%%, alpha, last n trials''\n',i, phase(i).ttest.mean, phase(i).ttest.alpha, phase(i).numOfLastTrial(TTEST));
            fprintf(fid, 'QuittingConditions %d %s ''phase#, 3 conditions->(1,2,3,0)=(TotalLook,FirstLook,Ttest,None)''\n',i,num2str(phase(i).conditions,'%d '));
            fprintf(fid, 'QuittingLogic %d %s ''phase#, 2 logics->(1,2,0)=(And,Or,None)''\n',i,num2str(phase(i).logics,'%d '));
        end

        fclose(fid);
    end



%% User edit and apply parameter
    function ApplyPara(Object, eventdata, handles)
        s = get(gui.paraListBox, 'String');
        v = get(gui.paraListBox, 'Value');
        error = CheckInput(s, v);
    end

%% Check user input value
    function error = CheckInput(s, v)
        error = false;
        switch s{v}
            case 'Screen'
                width = str2num(get(gui.screen.editBox(1),'String'));
                if isempty(width) || length(width)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.screen.textBox(1),'String'),get(gui.screen.editBox(1),'String')) , '!! Warning !!');
                    set(gui.screen.editBox(1),'String',num2str(scr.width));
                    error = true;
                else
                    scr.width = width;
                end
                height = str2num(get(gui.screen.editBox(2),'String'));
                if isempty(height) || length(height)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.screen.textBox(2),'String'),get(gui.screen.editBox(2),'String')) , '!! Warning !!');
                    set(gui.screen.editBox(2),'String',num2str(scr.height));
                    error = true;
                else
                    scr.height = height;
                end
                bgcolor = str2num(get(gui.screen.editBox(3),'String'));
                if isempty(bgcolor) || length(bgcolor)~=3
                    warndlg(sprintf('Input Error: %s = %s',get(gui.screen.textBox(3),'String'),get(gui.screen.editBox(3),'String')) , '!! Warning !!');
                    set(gui.screen.editBox(3),'String',[num2str(scr.bgcolor(1)) ' ' num2str(scr.bgcolor(2)) ' ' num2str(scr.bgcolor(3))]);
                    error = true;
                else
                    scr.bgcolor = bgcolor;
                end
                TobiiIPaddress = get(gui.screen.editBox(4),'String');
                IP = [];
                try
                    IP = strread(TobiiIPaddress, '%d', 'delimiter','.');
                catch
                    error = true;
                end
                if length(IP)~=4
                    warndlg(sprintf('Input Error: %s = %s',get(gui.screen.textBox(4),'String'),get(gui.screen.editBox(4),'String')) , '!! Warning !!');
                    set(gui.screen.editBox(4),'String',scr.TobiiIPaddress);
                    error = true;
                else
                    scr.TobiiIPaddress = TobiiIPaddress;
                end
                TobiiPortNum = get(gui.screen.editBox(5),'String');
                if isempty(str2num(TobiiPortNum))
                    warndlg(sprintf('Input Error: %s = %s',get(gui.screen.textBox(5),'String'),get(gui.screen.editBox(5),'String')) , '!! Warning !!');
                    set(gui.screen.editBox(5),'String',scr.TobiiPortNum);
                    error = true;
                else
                    scr.TobiiPortNum = TobiiPortNum;
                end
            case 'Mask'
                u = get(gui.mask.popupmenu, 'UserData');
                x = str2num(get(gui.mask.editBox(1),'String'));
                if isempty(x)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.mask.textBox(1),'String'),get(gui.mask.editBox(1),'String')) , '!! Warning !!');
                    set(gui.mask.editBox(1),'String',num2str(mask(u).x, '%d '));
                    error = true;
                else
                    mask(u).x = x;
                end
                y = str2num(get(gui.mask.editBox(2),'String'));
                if isempty(y)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.mask.textBox(2),'String'),get(gui.mask.editBox(2),'String')) , '!! Warning !!');
                    set(gui.mask.editBox(2),'String',num2str(mask(u).y, '%d '));
                    error = true;
                else
                    mask(u).y = y;
                end
                if length(mask(u).x)~=length(mask(u).y)
                    warndlg(sprintf('Input Error: length of x and y = %d and %d is not match and truncat to short length!',length(mask(u).x),length(mask(u).y)) , '!! Warning !!');
                    if length(mask(u).x)>length(mask(u).y)
                        mask(u).x = mask(u).x(1:length(mask(u).y));
                        set(gui.mask.editBox(1),'String',num2str(mask(u).x, '%d '));
                    else
                        mask(u).y = mask(u).y(1:length(mask(u).x));
                        set(gui.mask.editBox(2),'String',num2str(mask(u).y, '%d '));
                    end
                    error = true;
                end
                color = str2num(get(gui.mask.editBox(3),'String'));
                if isempty(color) || length(color)~=3
                    warndlg(sprintf('Input Error: %s = %s',get(gui.mask.textBox(3),'String'),get(gui.mask.editBox(3),'String')) , '!! Warning !!');
                    set(gui.mask.editBox(3),'String',[num2str(mask(u).color(1)) ' ' num2str(mask(u).color(2)) ' ' num2str(mask(u).color(3))]);
                    error = true;
                else
                    mask(u).color = color;
                end
            case 'Loom'
                u = get(gui.loom.popupmenu, 'UserData');
                growSize = str2num(get(gui.loom.editBox(1),'String'));
                if isempty(growSize) || length(growSize)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.loom.textBox(1),'String'),get(gui.loom.editBox(1),'String')) , '!! Warning !!');
                    set(gui.loom.editBox(1),'String',num2str(loom(u).growSize));
                    error = true;
                else
                    loom(u).growSize = growSize;
                end
                duration = str2num(get(gui.loom.editBox(2),'String'));
                if isempty(duration) || length(duration)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.loom.textBox(2),'String'),get(gui.loom.editBox(2),'String')) , '!! Warning !!');
                    set(gui.loom.editBox(2),'String',num2str(loom(u).duration));
                    error = true;
                else
                    loom(u).duration = duration;
                end

            case 'Object'
                moveObj.type = get(gui.object.popupmenu,'Value');
                objsize = str2num(get(gui.object.editBox(2),'String'));
                if isempty(objsize) || length(objsize)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.object.textBox(2),'String'),get(gui.object.editBox(2),'String')) , '!! Warning !!');
                    set(gui.object.editBox(2),'String',num2str(moveObj.size));
                    error = true;
                else
                    moveObj.size = objsize;
                end
                speed = str2num(get(gui.object.editBox(3),'String'));
                if isempty(speed) || length(speed)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.object.textBox(3),'String'),get(gui.object.editBox(3),'String')) , '!! Warning !!');
                    set(gui.object.editBox(3),'String',num2str(moveObj.speed));
                    error = true;
                else
                    moveObj.speed = speed;
                end
            case 'Image' %do nothing
            case 'Movie' %do nothing
            case 'Sound' %do nothing
            case 'Random Set'
                u = get(gui.randomSet.popupmenu, 'UserData');
                soundFiles = str2num(get(gui.randomSet.editBox(1),'String'));
                if isempty(soundFiles) || ~isempty(find(soundFiles<=0)) || ~isempty(find(soundFiles>length(sound)))
                    warndlg(sprintf('Input Error: %s = %s',get(gui.randomSet.textBox(1),'String'),get(gui.randomSet.editBox(1),'String')) , '!! Warning !!');
                    set(gui.randomSet.editBox(1),'String',num2str(randomSet(u).soundFiles));
                    error = true;
                else
                    randomSet(u).soundFiles = soundFiles;
                end
            case 'Effect' %do nothing
            case 'Observe Win'
                u = get(gui.obswin.popupmenu, 'UserData');
                width = str2num(get(gui.obswin.editBox(1),'String'));
                if isempty(width) || length(width)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.obswin.textBox(1),'String'),get(gui.obswin.editBox(1),'String')) , '!! Warning !!');
                    set(gui.obswin.editBox(1),'String',num2str(obswin(u).width));
                    error = true;
                else
                    obswin(u).width = width;
                end
                height = str2num(get(gui.obswin.editBox(2),'String'));
                if isempty(height) || length(height)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.obswin.textBox(2),'String'),get(gui.obswin.editBox(2),'String')) , '!! Warning !!');
                    set(gui.obswin.editBox(2),'String',num2str(obswin(u).height));
                    error = true;
                else
                    obswin(u).height = height;
                end
                upperLeftCorner = str2num(get(gui.obswin.editBox(3),'String'));
                if isempty(upperLeftCorner) || length(upperLeftCorner)~=2
                    warndlg(sprintf('Input Error: %s = %s',get(gui.obswin.textBox(3),'String'),get(gui.obswin.editBox(3),'String')) , '!! Warning !!');
                    set(gui.obswin.editBox(3),'String',[num2str(obswin(u).upperLeftCorner(1)) ' ' num2str(obswin(u).upperLeftCorner(2))]);
                    error = true;
                else
                    obswin(u).upperLeftCorner = upperLeftCorner;
                end
                if ~error
                    SelectStructureAttribute([], [], []);
                end
            case 'Path'
                modified = false;
                u = get(gui.path.popupmenu, 'UserData');
                x = str2num(get(gui.path.editBox(1),'String'));
                if isempty(x)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.path.textBox(1),'String'),get(gui.path.editBox(1),'String')) , '!! Warning !!');
                    set(gui.path.editBox(1),'String',num2str(path(u).x));
                    error = true;
                else
                    if length(path(u).x)~= length(x)
                        modified = true;
                    end
                    path(u).x = x;
                end
                y = str2num(get(gui.path.editBox(2),'String'));
                if isempty(y)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.path.textBox(2),'String'),get(gui.path.editBox(2),'String')) , '!! Warning !!');
                    set(gui.path.editBox(2),'String',num2str(path(u).y));
                    error = true;
                else
                    if length(path(u).y) ~= length(y)
                        modified = true;
                    end
                    path(u).y = y;
                end
                if length(path(u).x)~=length(path(u).y)
                    warndlg(sprintf('Input Error: length of x and y = %d and %d is not match and truncat to short length!',length(x),length(y)) , '!! Warning !!');
                    if length(path(u).x)>length(path(u).y)
                        path(u).x = path(u).x(1:length(path(u).y));
                        set(gui.path.editBox(1),'String',num2str(path(u).x));
                    else
                        path(u).y = path(u).y(1:length(path(u).x));
                        set(gui.path.editBox(2),'String',num2str(path(u).y));
                    end
                    error = true;
                    modified = true;
                end
                objSizeRatio = str2num(get(gui.path.editBox(3),'String'));
                if isempty(objSizeRatio)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.path.textBox(3),'String'),get(gui.path.editBox(3),'String')) , '!! Warning !!');
                    set(gui.path.editBox(3),'String',num2str(path(u).objSizeRatio,'%g '));
                    error = true;
                elseif any(objSizeRatio < 0)
                    warndlg(sprintf('Input Error: Ratio (%s) must greater than 0!',get(gui.path.editBox(3),'String')) , '!! Warning !!');
                    set(gui.path.editBox(3),'String',num2str(path(u).objSizeRatio,'%g '));
                    error = true;
                else
                    path(u).objSizeRatio = objSizeRatio;
                end
                if length(path(u).x)~=length(path(u).objSizeRatio)
                    warndlg(sprintf('Input Error: length of Obj Size Ratio (%d) is not match to the length of path (%d) and truncat or set ratio=1!',length(objSizeRatio),length(x)) , '!! Warning !!');
                    if length(path(u).objSizeRatio)>length(path(u).x)
                        path(u).objSizeRatio = path(u).objSizeRatio(1:length(path(u).x));
                    else
                        path(u).objSizeRatio = [objSizeRatio ones(1, length(path(u).x) - length(path(u).objSizeRatio))];
                    end
                    set(gui.path.editBox(3),'String',num2str(path(u).objSizeRatio,'%g '));
                    error = true;
                end
                objSpeedRatio = str2num(get(gui.path.editBox(4),'String'));
                if isempty(objSpeedRatio)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.path.textBox(4),'String'),get(gui.path.editBox(4),'String')) , '!! Warning !!');
                    set(gui.path.editBox(4),'String',num2str(path(u).objSpeedRatio,'%g '));
                    error = true;
                elseif any(objSpeedRatio <= 0)
                    warndlg(sprintf('Input Error: Ratio (%s) must greater than 0!',get(gui.path.editBox(4),'String')) , '!! Warning !!');
                    set(gui.path.editBox(4),'String',num2str(path(u).objSpeedRatio,'%g '));
                    error = true;
                else
                    path(u).objSpeedRatio = objSpeedRatio;
                end
                if length(path(u).x)~=length(path(u).objSpeedRatio)+1
                    warndlg(sprintf('Input Error: length of Obj Speed Ratio (%d + 1) is not match to the length of path (%d) and truncat or set ratio=1!',length(objSpeedRatio),length(x)) , '!! Warning !!');
                    if length(path(u).objSpeedRatio)+1>length(path(u).x)
                        path(u).objSpeedRatio = path(u).objSpeedRatio(1:length(path(u).x)-1);
                    else
                        path(u).objSpeedRatio = [objSpeedRatio ones(1, length(path(u).x) - length(path(u).objSpeedRatio) - 1)];
                    end
                    set(gui.path.editBox(4),'String',num2str(path(u).objSpeedRatio,'%g '));
                    error = true;
                end

                if modified
                    % clear all effect
                    path(u).soundEffect = (length(sound)+2)*ones(1,length(path(u).x));
                    path(u).loomEffect = (length(loom)+2)*ones(1,length(path(u).x));
                    path(u).soundRandomSetIndex = ones(1,length(path(u).x)); % default 1st set
                    path(u).waitAttention = zeros(1,length(path(u).x)); % default not wait for attention
                    path(u).attentionWin = ones(1,length(path(u).x)); % default 1st observation window

                    % modify Interesting Nodes of Structures Attribute
                    for si=1:length(structure)
                        if structure(si).pathNum == u
                            structure(si).interestNodes = [1 length(path(u).x)];
                        end
                    end

                    warndlg('Warning: If you modified Path, please modify the Effect and Structures Attribute!' , '!! Warning !!');
                    disp('Warning: If you modified Path, please modify the Effect and Structures Attribute!');
                end
            case 'Structure'
                u = get(gui.struct.popupmenu(1), 'UserData');
                structure(u).pathNum = get(gui.struct.popupmenu(2),'Value');
                structure(u).maskNum = get(gui.struct.popupmenu(3),'Value');
                structure(u).imgNum = get(gui.struct.popupmenu(4),'Value');
                structure(u).imgShape = get(gui.struct.popupmenu(5),'Value');
                structure(u).foregroundImgNum = get(gui.struct.popupmenuFGImg,'Value');
                structure(u).backgroundImgNum = get(gui.struct.popupmenuBGImg,'Value');
                structure(u).useForegroundImg = get(gui.struct.checkboxFGImg,'Value');
                structure(u).useBackgroundImg = get(gui.struct.checkboxBGImg,'Value');
                structure(u).useRewardMovie = get(gui.struct.checkboxUseRewardMovie,'Value');
                structure(u).movieNum = get(gui.struct.popupmenuMovieFile,'Value');
                structure(u).movieShape = get(gui.struct.popupmenuMovieShape, 'Value');
                imgSize = str2num(get(gui.struct.editBox(1),'String'));
                if isempty(imgSize) || length(imgSize)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.struct.textBox(1),'String'),get(gui.struct.editBox(1),'String')) , '!! Warning !!');
                    set(gui.struct.editBox(1),'String',num2str(structure(u).imgSize));
                    error = true;
                else
                    structure(u).imgSize = imgSize;
                end
                imgMoveSpeed = str2num(get(gui.struct.editBox(2),'String'));
                if isempty(imgMoveSpeed) || length(imgMoveSpeed)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.struct.textBox(2),'String'),get(gui.struct.editBox(2),'String')) , '!! Warning !!');
                    set(gui.struct.editBox(2),'String',num2str(structure(u).imgMoveSpeed));
                    error = true;
                else
                    structure(u).imgMoveSpeed = imgMoveSpeed;
                end
                movieDelay = str2num(get(gui.struct.editBoxMovieDelay, 'String'));
                if isempty(movieDelay) || length(movieDelay)~=1 || movieDelay < 0
                    warndlg(sprintf('Input Error: Delay of movie = %s',get(gui.struct.editBoxMovieDelay,'String')) , '!! Warning !!');
                    set(gui.struct.editBoxMovieDelay,'String',num2str(structure(u).movieDelay));
                    error = true;
                else
                    structure(u).movieDelay = movieDelay;
                end
                movieCenter = str2num(get(gui.struct.editBoxMovieCenter, 'String'));
                if isempty(movieCenter) || length(movieCenter)~=2
                    warndlg(sprintf('Input Error: Movie center (x y) = (%s)',get(gui.struct.editBoxMovieCenter,'String')) , '!! Warning !!');
                    set(gui.struct.editBoxMovieCenter,'String',num2str(structure(u).movieCenter));
                    error = true;
                else
                    structure(u).movieCenter = movieCenter;
                end
                movieWidth = str2num(get(gui.struct.editBoxMovieWidth, 'String'));
                if isempty(movieWidth) || length(movieWidth)~=1 || movieWidth < 0
                    warndlg(sprintf('Input Error: Movie width = %s',get(gui.struct.editBoxMovieWidth,'String')) , '!! Warning !!');
                    set(gui.struct.editBoxMovieWidth,'String',num2str(structure(u).movieWidth));
                    error = true;
                else
                    structure(u).movieWidth = movieWidth;
                end
                movieDuration = str2num(get(gui.struct.editBoxMovieDuration, 'String'));
                if isempty(movieDuration) || length(movieDuration)~=1 || movieDuration < 0
                    warndlg(sprintf('Input Error: Movie duration = %s',get(gui.struct.editBoxMovieDuration,'String')) , '!! Warning !!');
                    set(gui.struct.editBoxMovieDuration,'String',num2str(structure(u).movieDuration));
                    error = true;
                else
                    structure(u).movieDuration = movieDuration;
                end
                if ~error
                    SelectQuitPhase([], [], []);
                end
            case 'Phase'
                u = get(gui.phase.popupmenu, 'UserData');
                phase(u).random = get(gui.phase.checkBox,'Value');
                phase(u).fixPercentage = get(gui.phase.checkBox2,'Value');
                phase(u).blankISI = get(gui.phase.checkBox3,'Value');
                structNum = str2num(get(gui.phase.editBox(1),'String'));
                if isempty(structNum)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(1),'String'),get(gui.phase.editBox(1),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(1),'String',num2str(phase(u).structNum,'%d '));
                    error = true;
                end
                I = find(structNum<1 | structNum>length(structure));
                if ~isempty(I)
                    warndlg(sprintf('Input Error: struct# %s not between [1 %d]',num2str(structNum(I),'%d '), length(structure)) , '!! Warning !!');
                    structNum(I) = [];
                    set(gui.phase.editBox(1),'String',num2str(structNum,'%d '));
                    error = true;
                end
                if ~error
                    phase(u).structNum = structNum;
                end
                structWeight = str2num(get(gui.phase.editBox(8),'String'));
                if isempty(structWeight)
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(8),'String'),get(gui.phase.editBox(8),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(8),'String',num2str(phase(u).structWeight,'%d '));
                    error = true;
                else
                    phase(u).structWeight = structWeight;
                end
                trialNum = str2num(get(gui.phase.editBox(2),'String'));
                if isempty(trialNum) || length(trialNum)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(2),'String'),get(gui.phase.editBox(2),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(2),'String',num2str(phase(u).trialNum));
                    error = true;
                else
                    phase(u).trialNum = trialNum;
                end
                maxTime = str2num(get(gui.phase.editBox(3),'String'));
                if isempty(maxTime) || length(maxTime)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(3),'String'),get(gui.phase.editBox(3),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(3),'String',num2str(phase(u).maxTime));
                    error = true;
                else
                    phase(u).maxTime = maxTime;
                end
                maskOpaqueStart = str2num(get(gui.phase.editBox(4),'String'));
                if isempty(maskOpaqueStart) || length(maskOpaqueStart)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(4),'String'),get(gui.phase.editBox(4),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(4),'String',num2str(phase(u).maskOpaqueStart));
                    error = true;
                else
                    phase(u).maskOpaqueStart = maskOpaqueStart;
                end
                maskOpaqueIncStep = str2num(get(gui.phase.editBox(5),'String'));
                if isempty(maskOpaqueIncStep) || length(maskOpaqueIncStep)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(5),'String'),get(gui.phase.editBox(5),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(5),'String',num2str(phase(u).maskOpaqueIncStep));
                    error = true;
                else
                    phase(u).maskOpaqueIncStep = maskOpaqueIncStep;
                end
                maskOpaqueEnd = str2num(get(gui.phase.editBox(6),'String'));
                if isempty(maskOpaqueEnd) || length(maskOpaqueEnd)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(6),'String'),get(gui.phase.editBox(6),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(6),'String',num2str(phase(u).maskOpaqueEnd));
                    error = true;
                else
                    phase(u).maskOpaqueEnd = maskOpaqueEnd;
                end
                waitTime = str2num(get(gui.phase.editBox(7),'String'));
                if isempty(waitTime)  || length(waitTime)~=2 %MO: WAS: || length(waitTime)~=1
                    warndlg(sprintf('Input Error: %s = %s',get(gui.phase.textBox(7),'String'),get(gui.phase.editBox(7),'String')) , '!! Warning !!');
                    set(gui.phase.editBox(7),'String',num2str([phase(u).waitTime1 phase(u).waitTime2]));%MO: fixed
                    error = true;
                else
                    phase(u).waitTime1 = waitTime(1); %MO: was = waitTime
                    if numel(waitTime)>1 %MO: this if added
                        phase(u).waitTime2 = waitTime(2);
                    else
                        phase(u).waitTime2=waitTime(1);
                    end
                end
            case 'Struct Attribute'
                u = get(gui.structAttribute.popupmenuStruct, 'UserData');
                interestNodes = [get(gui.structAttribute.popupmenuNodeStart,'Value') get(gui.structAttribute.popupmenuNodeEnd,'Value')];
                if interestNodes(1) >= interestNodes(2)
                    warndlg('Input Error: Interesting Start Node >= End Node!', '!! Warning !!');
                    set(gui.structAttribute.popupmenuNodeStart, 'Value', structure(u).interestNodes(1));
                    set(gui.structAttribute.popupmenuNodeEnd, 'Value', structure(u).interestNodes(2));
                    error = true;
                else
                    structure(u).interestNodes = interestNodes;
                end
                correctObsWins = str2num(get(gui.structAttribute.editBoxCorrObsWins,'String'));
                if isempty(correctObsWins) || ~isempty(find(correctObsWins <= 0 | correctObsWins > length(obswin)))
                    warndlg(sprintf('Input Error: Correct ObsWins = %s',get(gui.structAttribute.editBoxCorrObsWins,'String')) , '!! Warning !!');
                    error = true;
                else
                    structure(u).correctObsWins = unique(correctObsWins);
                end
                incorrectObsWins = str2num(get(gui.structAttribute.editBoxIncorrObsWins,'String'));
                if isempty(incorrectObsWins) || ~isempty(find(incorrectObsWins <= 0 | incorrectObsWins > length(obswin)))
                    warndlg(sprintf('Input Error: Correct ObsWins = %s',get(gui.structAttribute.editBoxIncorrObsWins,'String')) , '!! Warning !!');
                    error = true;
                else
                    structure(u).incorrectObsWins = unique(incorrectObsWins);
                end
                if ~isempty(intersect(correctObsWins,incorrectObsWins))
                    warndlg(sprintf('Input Error: Find same ObsWins# %s in both Correct/Incorrect ObsWins.', num2str(intersect(correctObsWins,incorrectObsWins), '%d ')), '!! Warning !!');
                    error = true;
                end
                requireLooking = str2num(get(gui.structAttribute.editBoxRequireLooking,'String'));
                if length(requireLooking) ~= 1 || requireLooking < 0 || requireLooking > 100
                    warndlg(sprintf('Input Error: Require Looking% = %s',get(gui.structAttribute.editBoxRequireLooking,'String')) , '!! Warning !!');
                    error = true;
                else
                    structure(u).requireLooking = requireLooking;
                end
                lookScrTime = str2num(get(gui.structAttribute.editBoxLookScrTime,'String'));
                if length(lookScrTime) ~= 1
                    warndlg(sprintf('Input Error: Look at Screen Time = %s',get(gui.structAttribute.editBoxLookScrTime,'String')) , '!! Warning !!');
                    error = true;
                else
                    structure(u).lookScrTime = lookScrTime;
                end
                validityLevel = str2num(get(gui.structAttribute.editBoxValidityLevel,'String'));
                if length(validityLevel) ~= 1 || validityLevel < 0 || validityLevel > 4
                    warndlg(sprintf('Input Error: Validity Level = %s',get(gui.structAttribute.editBoxValidityLevel,'String')) , '!! Warning !!');
                    error = true;
                else
                    structure(u).validityLevel = validityLevel;
                end
            case 'Quit Phase'
                u = get(gui.quitPhase.popupmenuPhaseNum, 'UserData');
                phase(u).useQuittingCond = get(gui.quitPhase.CheckboxUseQuitCond,'Value');
                phase(u).useTotalTrials = get(gui.quitPhase.CheckboxUseTotalTrialsCond,'Value');
                interestStructs = str2num(get(gui.quitPhase.editBoxInterestStruct,'String'));
                if isempty(interestStructs)
                    warndlg(sprintf('Input Error: Interesting Structs = %s',get(gui.quitPhase.editBoxInterestStruct,'String')) , '!! Warning !!');
                    error = true;
                else
                    tmp = ismember(interestStructs,phase(u).structNum);
                    if sum(tmp) ~= length(interestStructs)
                        warndlg(sprintf('Input Error: Part of Interesting Structs (%s) is not available!',get(gui.quitPhase.editBoxInterestStruct,'String')) , '!! Warning !!');
                        error = true;
                    else
                        phase(u).interestStructs = interestStructs;
                    end
                end
                lookPercentage = str2num(get(gui.quitPhase.editBoxTotalLookPercentage,'String'));
                if length(lookPercentage) ~= 1 || lookPercentage < 0 || lookPercentage > 100
                    warndlg(sprintf('Input Error: Total Looking: Correct Look%% = %s',get(gui.quitPhase.editBoxTotalLookPercentage,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).totalLook.lookPercentage = lookPercentage;
                end
                numOfLastTrial = str2num(get(gui.quitPhase.editBoxTotalLookLastNtrail,'String'));
                if length(numOfLastTrial) ~= 1 || numOfLastTrial < 1
                    warndlg(sprintf('Input Error: Total Looking: Last n trials = %s',get(gui.quitPhase.editBoxTotalLookLastNtrail,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).numOfLastTrial(TOTAL_LOOK) = numOfLastTrial;
                end
                numOfCorrLook = str2num(get(gui.quitPhase.editBoxFirstLookNum,'String'));
                if length(numOfCorrLook) ~= 1 || numOfCorrLook < 0
                    warndlg(sprintf('Input Error: First Looking: Correct Look# = %s',get(gui.quitPhase.editBoxFirstLookNum,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).firstLook.numOfCorrLook = numOfCorrLook;
                end
                numOfLastTrial = str2num(get(gui.quitPhase.editBoxFirstLookLastNtrail ,'String'));
                if length(numOfLastTrial) ~= 1 || numOfLastTrial < 1
                    warndlg(sprintf('Input Error: First Looking: Last n trials = %s',get(gui.quitPhase.editBoxFirstLookLastNtrail ,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).numOfLastTrial(FIRST_LOOK) = numOfLastTrial;
                end
                if numOfCorrLook > numOfLastTrial
                    warndlg('Input Error: First Looking: Correct look# > Last n trail!' , '!! Warning !!');
                    error = true;
                end
                ttestMean = str2num(get(gui.quitPhase.editBoxTtestMean ,'String'));
                if length(ttestMean) ~= 1 || ttestMean < 0 || ttestMean > 100
                    warndlg(sprintf('Input Error: Ttest: mean%% = %s',get(gui.quitPhase.editBoxTtestMean,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).ttest.mean = ttestMean;
                end
                ttestAlpha = str2num(get(gui.quitPhase.editBoxTtestAlpha,'String'));
                if length(ttestAlpha) ~= 1 || ttestAlpha < 0 || ttestAlpha > 1
                    warndlg(sprintf('Input Error: Ttest: alpha = %s',get(gui.quitPhase.editBoxTtestAlpha,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).ttest.alpha = ttestAlpha;
                end
                numOfLastTrial = str2num(get(gui.quitPhase.editBoxTtestLastNtrail,'String'));
                if length(numOfLastTrial) ~= 1 || numOfLastTrial < 1
                    warndlg(sprintf('Input Error: Ttest: Last n trials = %s',get(gui.quitPhase.editBoxTtestLastNtrail ,'String')) , '!! Warning !!');
                    error = true;
                else
                    phase(u).numOfLastTrial(TTEST) = numOfLastTrial;
                end
                conditions = [ get(gui.quitPhase.popupmenuTtestLogicA,'Value') get(gui.quitPhase.popupmenuTtestLogicB,'Value') get(gui.quitPhase.popupmenuTtestLogicC,'Value')];
                logics = [get(gui.quitPhase.popupmenuTtestLogicAndOr1,'Value') get(gui.quitPhase.popupmenuTtestLogicAndOr2,'Value')];
                I = find(conditions == 4);
                if ~isempty(I)
                    conditions(I) = 0; % None
                end
                I = find(logics == 3);
                if ~isempty(I)
                    logics(I) = 0; % None
                end
                if logics(1) == NONE && conditions(2) ~= NONE
                    warndlg('Logic Error: If 1st logic is None, 2nd condition should be None!', '!! Warning !!');
                    error = true;
                elseif logics(2) == NONE && conditions(3) ~= NONE
                    warndlg('Logic Error: If 2nd logic is None, 3rd condition should be None!', '!! Warning !!');
                    error = true;
                else
                    phase(u).conditions = conditions;
                    phase(u).logics = logics;
                end
            otherwise
                %error = true;
        end
    end
%% Set debug mood
    function DebugMode(Object, eventdata, handles)
        debug = get(gui.debugCheckbox,'Value');
    end

%% Set connection of Tobii mood
    function ConnTobii(Object, eventdata, handles)
        connTobii = get(gui.connTobiiCheckbox,'Value');
    end

%% Set connection to NIRS machine
%MO: this section added
    function ConnNIRS(Object, eventdata, handles)
        connNIRS = get(gui.connNIRSCheckbox,'Value');
    end

%% Set serial port NIRS machine
%MO: this section added
    function GetSerialOTNum(Object, eventdata, handles)
        SerialOTNum = num2str(get(gui.SerialOTNumeditBox,'String'));
    end

%% When exit the main gui, close all the windows and clear global variable
    function ExitTobiiGUI(Object, eventdata, handles)
        CloseScreen([],[],[]);
        try
            delete(gui.main);
        catch
            close all
        end
        clear global smarttVersion debug connTobii connNIRS SerialOTNum NIRSMACHINE scr mask obswin loom moveObj sound randomSet img path structure phase gui movie
        %MO: added connNIRS, SerialOTNum, NIRSMACHINE above
    end

%% Change the sound effect
    function SelectEffectSound(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        path(pv).soundEffect(nv) = get(gui.effect.popupmenu(3), 'Value');
    end

%% Change the loom effect
    function SelectEffectLoom(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        path(pv).loomEffect(nv) = get(gui.effect.popupmenu(4), 'Value');
    end

%% Change the effect random set
    function SelectEffectRandomSet(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        path(pv).soundRandomSetIndex(nv) = get(gui.effect.popupmenu(5), 'Value');
    end

%% Change the attention win
    function SelectEffectObsWin(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        path(pv).attentionWin(nv) = get(gui.effect.popupmenu(6), 'Value');
    end

%% Change the attention win
    function SelectEffectWaitAttention(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        path(pv).waitAttention(nv) = get(gui.effect.CheckboxWaitAttention, 'Value');
    end

%% Change the node effect
    function SelectEffectNode(Object, eventdata, handles)
        pv = get(gui.effect.popupmenu(1), 'Value');
        nv = get(gui.effect.popupmenu(2), 'Value');
        set(gui.effect.popupmenu(3), 'Value', path(pv).soundEffect(nv),'UserData',path(pv).soundEffect(nv));
        set(gui.effect.popupmenu(4), 'Value', path(pv).loomEffect(nv),'UserData',path(pv).loomEffect(nv));
        set(gui.effect.popupmenu(5), 'Value', path(pv).soundRandomSetIndex(nv),'UserData',path(pv).soundRandomSetIndex(nv));
        set(gui.effect.popupmenu(6), 'Value', path(pv).attentionWin(nv));
        set(gui.effect.CheckboxWaitAttention, 'Value', path(pv).waitAttention(nv));
    end

%% Change the path select in effect panel
    function SelectEffectPath(Object, eventdata, handles)
        % Reset gui
        pv = get(gui.effect.popupmenu(1), 'Value');
        set(gui.effect.popupmenu(1), 'UserData', pv);
        nodeStr = [];
        for i = 1:length(path(pv).x)
            nodeStr{i} = [num2str(i) '. (' num2str(path(pv).x(i)) ', ' num2str(path(pv).y(i)) ')'];
        end
        set(gui.effect.popupmenu(2),'String', nodeStr, 'Value',1,'UserData',1);
        set(gui.effect.popupmenu(3),'String',GetString('sound'), 'Value', path(pv).soundEffect(1));
        set(gui.effect.popupmenu(4), 'String',GetString('loomEffect'),'Value', path(pv).loomEffect(1));
        set(gui.effect.popupmenu(5),'String',GetString('randomSet'), 'Value', path(pv).soundRandomSetIndex(1));
        set(gui.effect.popupmenu(6),'String',GetString('obswin'), 'Value', path(pv).attentionWin(1));
        set(gui.effect.CheckboxWaitAttention, 'Value', path(pv).waitAttention(1));
    end

%% Undate Effect GUI after modify Path, Node, Sound and Loom
    function UpdateEffectGUI(modifyPara, action, index)
        switch modifyPara
            case 'sound'
                if strcmp(action, 'remove')
                    randomSet = [];
                    randomSet(1).soundFiles = 1:length(sound);
                    set(gui.randomSet.popupmenu, 'String', GetString('randomSet'), 'Value', 1, 'UserData', 1);
                    SelectRandomSet([], [], []);
                end
                for i = 1:length(path) % set all for none effect
                    %path(i).soundEffect = [];
                    path(i).soundEffect(1:length(path(i).x)) = (length(sound)+2)*ones(1,length(path(i).x));
                    if strcmp(action, 'remove')
                        path(i).soundRandomSetIndex(1:length(path(i).x)) = ones(1,length(path(i).x)); % default 1st set
                    end
                end
            case 'loom'
                for i = 1:length(path) % set all for none effect
                    %path(i).loomEffect = [];
                    path(i).loomEffect(1:length(path(i).x)) = (length(loom)+2)*ones(1,length(path(i).x));
                end
            case 'randomSet'
                if strcmp(action, 'remove')
                    for i = 1:length(path) % set all for none effect
                        path(i).soundRandomSetIndex(1:length(path(i).x)) = ones(1,length(path(i).x)); % default 1st set
                    end
                end
        end
        SelectEffectPath([],[],[]);
    end

%% Select diff Structure
    function SelectStructure(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.struct.popupmenu(1), 'UserData');
                set(gui.struct.popupmenu(1),'Value',v);
                return;
            end
        end

        v = get(gui.struct.popupmenu(1), 'Value');
        set(gui.struct.popupmenu(1), 'UserData', v);
        set(gui.struct.popupmenu(2),'String',GetString('path'),'UserData', structure(v).pathNum,'Value', structure(v).pathNum);
        set(gui.struct.popupmenu(3),'String',GetString('mask'),'UserData', structure(v).maskNum,'Value', structure(v).maskNum);
        set(gui.struct.popupmenu(4),'String',GetString('img'),'UserData', structure(v).imgNum,'Value', structure(v).imgNum);
        set(gui.struct.popupmenu(5),'UserData', structure(v).imgShape,'Value', structure(v).imgShape);
        set(gui.struct.editBox(1) ,'String',num2str(structure(v).imgSize));
        set(gui.struct.editBox(2) ,'String',num2str(structure(v).imgMoveSpeed));
        set(gui.struct.popupmenuFGImg,'String',GetString('FBimg'),'UserData', structure(v).foregroundImgNum,'Value', structure(v).foregroundImgNum);
        set(gui.struct.checkboxFGImg, 'Value', structure(v).useForegroundImg);
        set(gui.struct.popupmenuBGImg,'String',GetString('FBimg'),'UserData', structure(v).backgroundImgNum,'Value', structure(v).backgroundImgNum);
        set(gui.struct.checkboxBGImg, 'Value', structure(v).useBackgroundImg);
        set(gui.struct.checkboxUseRewardMovie, 'value', structure(v).useRewardMovie);
        set(gui.struct.popupmenuMovieFile, 'String', GetString('movieFile'), 'value', structure(v).movieNum);
        set(gui.struct.popupmenuMovieShape, 'Value', structure(v).movieShape);
        set(gui.struct.editBoxMovieDelay, 'String',num2str(structure(v).movieDelay))
        set(gui.struct.editBoxMovieCenter, 'String',num2str(structure(v).movieCenter, '%d '));
        set(gui.struct.editBoxMovieWidth, 'String',num2str(structure(v).movieWidth));
        set(gui.struct.editBoxMovieDuration, 'String',num2str(structure(v).movieDuration));
    end

%% Add Structure
    function AddStructure(Object, eventdata, handles)
        ApplyPara([],[],[]);

        structNum = length(structure);
        v = get(gui.struct.popupmenu(1), 'Value');
        structure(structNum+1) = structure(v);

        set(gui.struct.popupmenu(1), 'String', GetString('struct'), 'Value',structNum+1);
        SelectStructure([], [], []);

        set(gui.structAttribute.popupmenuStruct,'String', GetString('struct'));
    end

%% Remove Structure
    function RemoveStructure(Object, eventdata, handles)
        if length(structure) <= 1
            warndlg('Last Structure cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.struct.popupmenu(1),'Value');
        structure(v) = [];

        set(gui.struct.popupmenu(1), 'String', GetString('struct'), 'Value', 1, 'UserData', 1);
        SelectStructure([], [], []);

        % setup Phase parameter and gui
        str = [];
        for i = 1:length(phase)
            if(phase(i).structNum == v)
                phase(i).structNum = 1;
                str = sprintf('%s\nStruct# %d was used by Phase# %d. Please modify the Phase!',str,v,i);
            end

            I = find(phase(i).structNum<1 | phase(i).structNum>length(structure));
            if ~isempty(I)
                str = sprintf('%s\nPhase# %d: Struct# %s will be removed in Struct# in order.',str,i,num2str(phase(i).structNum(I),'%d '));
                phase(i).structNum(I) = [];
                if isempty(phase(i).structNum)
                    phase(i).structNum(I) = 1;
                end
            end

            I = find(ismember(phase(i).interestStructs, phase(i).structNum) == 0);
            if ~isempty(I)
                str = sprintf('%s\nPhase# %d: Struct# %s will be removed in Interesting Structs#.',str,i,num2str(phase(i).interestStructs(I),'%d '));
                phase(i).interestStructs = intersect(phase(i).interestStructs, phase(i).structNum);
                if isempty(phase(i).interestStructs)
                    phase(i).interestStructs = 1;
                end
            end
        end
        if ~isempty(str)
            warndlg(str, '!! Warning !!');
            disp(str);
        end
        SelectPhase([],[],[]);

        set(gui.structAttribute.popupmenuStruct,'String', GetString('struct'), 'Value', 1, 'UserData', 1);
        SelectStructureAttribute([], [], []);
    end

%% Select diff Structure attrubute
    function SelectStructureAttribute(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.structAttribute.popupmenuStruct, 'UserData');
                set(gui.structAttribute.popupmenuStruct,'Value',v);
                return;
            end
        end

        v = get(gui.structAttribute.popupmenuStruct, 'Value');
        set(gui.structAttribute.popupmenuStruct, 'UserData', v);
        set(gui.structAttribute.editBoxCorrObsWins, 'String', num2str(structure(v).correctObsWins,'%d '));
        set(gui.structAttribute.textBoxCorrObsWins, 'String', ['(1-' num2str(length(obswin)) ')']);
        set(gui.structAttribute.editBoxIncorrObsWins, 'String', num2str(structure(v).incorrectObsWins,'%d '));
        set(gui.structAttribute.textBoxIncorrObsWins, 'String', ['(1-' num2str(length(obswin)) ')']);
        set(gui.structAttribute.editBoxRequireLooking, 'String', num2str(structure(v).requireLooking));
        set(gui.structAttribute.editBoxLookScrTime, 'String', num2str(structure(v).lookScrTime));
        set(gui.structAttribute.textBoxMaxTime, 'String', ['(' num2str(FindMaxTime(v)*1000,'%.0f') 'ms)']);
        set(gui.structAttribute.editBoxValidityLevel, 'String', num2str(structure(v).validityLevel));
        tmpstr = num2str(1:length(path(structure(v).pathNum).x), '%d|');
        set(gui.structAttribute.popupmenuNodeStart, 'String', tmpstr(1:end-1),'Value',structure(v).interestNodes(1));
        set(gui.structAttribute.popupmenuNodeEnd, 'String', tmpstr(1:end-1),'Value',structure(v).interestNodes(2));
    end

%% Undate Structure after modify Path, Mask and Image
    function UpdateStructGUI(modifyPara, action, index)
        switch modifyPara
            case 'path'
                if strcmp(action, 'add')
                    set(gui.struct.popupmenu(2),'String',GetString('path'));
                elseif strcmp(action, 'remove')
                    for i = 1:length(structure)
                        if (structure(i).pathNum == index)
                            structure(i).pathNum = 1;
                            warndlg(sprintf('Path# %d was used by Structure# %d. Please modify the Structure and its Attrubute!',index,i) , '!! Warning !!');
                        end
                    end
                    for i = 1:length(structure)
                        if(structure(i).pathNum > index)
                            structure(i).pathNum = structure(i).pathNum - 1;
                        end
                        if(structure(i).pathNum >= index)
                            structure(i).interestNodes = [1 length(path(structure(i).pathNum).x)];
                        end
                    end
                    SelectStructureAttribute([], [], []);
                end
            case 'mask'
                if strcmp(action, 'add')
                    set(gui.struct.popupmenu(3),'String',GetString('mask'));
                elseif strcmp(action, 'remove')
                    for i = 1:length(structure)
                        if (structure(i).maskNum == index)
                            structure(i).maskNum = 1;
                            warndlg(sprintf('Mask# %d was used by Structure# %d. Please modify the Structure!',index,i) , '!! Warning !!');
                        end
                    end
                    for i = 1:length(structure)
                        if(structure(i).maskNum > index)
                            structure(i).maskNum = structure(i).maskNum - 1;
                        end
                    end
                end
            case 'image'
                if strcmp(action, 'add')
                    set(gui.struct.popupmenu(4),'String',GetString('img'));
                    set(gui.struct.popupmenuFGImg,'String',GetString('FBimg'));
                    set(gui.struct.popupmenuBGImg,'String',GetString('FBimg'));
                elseif strcmp(action, 'remove')
                    warndlg('If you remove any image, please modify the Structure!' , '!! Warning !!');
                    for i = 1:length(structure)
                        structure(i).imgNum = 1;
                        structure(i).foregroundImgNum = 1;
                        structure(i).backgroundImgNum = 1;
                    end
                end
            case 'movie'
                if strcmp(action, 'add')
                    set(gui.struct.popupmenuMovieFile, 'string', GetString('movieFile'));
                elseif strcmp(action, 'remove')
                    disp('If you remove any movie, please modify the Structure!'); beep;
                    for i=1:length(structure)
                        structure(i).useRewardMovie = false;
                        structure(i).movieNum = 1;
                    end
                end
        end
        SelectStructure([],[],[]);
    end

%% Select diff Phase
    function SelectPhase(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.phase.popupmenu, 'UserData');
                set(gui.phase.popupmenu,'Value',v);
                return;
            end
        end

        v = get(gui.phase.popupmenu, 'Value');
        set(gui.phase.popupmenu, 'UserData', v);
        set(gui.phase.editBox(1),'String',num2str(phase(v).structNum,'%d '));
        set(gui.phase.checkBox,'Value', phase(v).random);
        set(gui.phase.editBox(8),'String',num2str(phase(v).structWeight,'%d '));
        set(gui.phase.checkBox2,'Value', phase(v).fixPercentage);
        set(gui.phase.checkBox3,'Value', phase(v).blankISI);
        set(gui.phase.editBox(2) ,'String',num2str(phase(v).trialNum));
        set(gui.phase.editBox(3) ,'String',num2str(phase(v).maxTime));
        set(gui.phase.editBox(4) ,'String',num2str(phase(v).maskOpaqueStart));
        set(gui.phase.editBox(5) ,'String',num2str(phase(v).maskOpaqueIncStep));
        set(gui.phase.editBox(6) ,'String',num2str(phase(v).maskOpaqueEnd));
        set(gui.phase.editBox(7) ,'String',num2str([phase(v).waitTime1 phase(v).waitTime2]));%MO: this modified
    end

%% Add Phase
    function AddPhase(Object, eventdata, handles)
        ApplyPara([],[],[]);

        phaseNum = length(phase);
        v = get(gui.phase.popupmenu, 'Value');
        phase(phaseNum+1) = phase(v);

        set(gui.phase.popupmenu, 'String', GetString('phase'), 'Value',phaseNum+1,'UserData',phaseNum+1);
        SelectPhase([], [], []);

        set(gui.quitPhase.popupmenuPhaseNum,'String', GetString('phase'));
    end

%% Remove Phase
    function RemovePhase(Object, eventdata, handles)
        if length(phase) <= 1
            warndlg('Last Phase cannot remove!' , '!! Warning !!');
            return;
        end

        v = get(gui.phase.popupmenu,'Value');
        phase(v) = [];

        set(gui.phase.popupmenu, 'String', GetString('phase'), 'Value', 1, 'UserData', 1);
        SelectPhase([], [], []);

        set(gui.quitPhase.popupmenuPhaseNum, 'String', GetString('phase'), 'Value', 1, 'UserData', 1);
        SelectQuitPhase([], [], []);
    end

%% Select Quit Phase
    function SelectQuitPhase(Object, eventdata, handles)
        if ~isempty(Object)
            s = get(gui.paraListBox, 'String');
            v = get(gui.paraListBox, 'UserData');
            error = CheckInput(s, v);

            if error
                v = get(gui.quitPhase.popupmenuPhaseNum, 'UserData');
                set(gui.quitPhase.popupmenuPhaseNum,'Value',v);
                return;
            end
        end

        v = get(gui.quitPhase.popupmenuPhaseNum, 'Value');
        set(gui.quitPhase.popupmenuPhaseNum, 'UserData', v);
        set(gui.quitPhase.CheckboxUseQuitCond,'Value', phase(v).useQuittingCond);
        set(gui.quitPhase.CheckboxUseTotalTrialsCond,'Value', phase(v).useTotalTrials);
        set(gui.quitPhase.editBoxInterestStruct ,'String',num2str(phase(v).interestStructs, '%d '));
        set(gui.quitPhase.textBoxAllStruct,'String',['(' num2str(phase(v).structNum, '%d ') ')']);
        set(gui.quitPhase.editBoxTotalLookPercentage,'String',num2str(phase(v).totalLook.lookPercentage));
        set(gui.quitPhase.editBoxTotalLookLastNtrail,'String',num2str(phase(v).numOfLastTrial(TOTAL_LOOK)));
        set(gui.quitPhase.editBoxFirstLookNum,'String',num2str(phase(v).firstLook.numOfCorrLook));
        set(gui.quitPhase.editBoxFirstLookLastNtrail,'String',num2str(phase(v).numOfLastTrial(FIRST_LOOK)));
        set(gui.quitPhase.editBoxTtestMean,'String',num2str(phase(v).ttest.mean));
        set(gui.quitPhase.editBoxTtestAlpha,'String',num2str(phase(v).ttest.alpha));
        set(gui.quitPhase.editBoxTtestLastNtrail,'String',num2str(phase(v).numOfLastTrial(TTEST)));
        conditions = phase(v).conditions;
        I = find(conditions == 0);
        if ~isempty(I)
            conditions(I) = 4;
        end
        set(gui.quitPhase.popupmenuTtestLogicA,'Value',conditions(1));
        set(gui.quitPhase.popupmenuTtestLogicB,'Value',conditions(2));
        set(gui.quitPhase.popupmenuTtestLogicC,'Value',conditions(3));
        logics = phase(v).logics;
        I = find(logics == 0);
        if ~isempty(I)
            logics(I) = 3;
        end
        set(gui.quitPhase.popupmenuTtestLogicAndOr1,'Value',logics(1));
        set(gui.quitPhase.popupmenuTtestLogicAndOr2,'Value',logics(2));
        set(gui.quitPhase.textBoxTotalTrial, 'String', ['(' num2str(phase(v).trialNum) ')'])
    end

%% setup the string in gui
    function str = GetString(parameter)
        str = [];
        switch parameter
            case 'mask'
                for i = 1:length(mask)
                    str{i} = num2str(i);
                end
            case 'loom'
                for i = 1:length(loom)
                    str{i} = num2str(i);
                end
            case 'loomEffect'
                for i = 1:length(loom)
                    str{i} = [num2str(i) '. (size=' num2str(loom(i).growSize) ', duration=' num2str(loom(i).duration) ')'];
                end
                str{length(loom)+1} = 'Random';
                str{length(loom)+2} = 'None';
            case 'img'
                for i = 1:length(img)
                    str{i} = [num2str(i) '. ' img(i).filename];
                end
                str{length(img)+1} = 'Random';
            case 'FBimg'
                for i = 1:length(img)
                    str{i} = [num2str(i) '. ' img(i).filename];
                end
            case 'imgFile'
                for i = 1:length(img)
                    str{i} = img(i).filename;
                end
            case 'movieFile'
                for i = 1:length(movie)
                    str{i} = [num2str(i) '. ' movie(i).filename];
                end
            case 'sound'
                for i = 1:length(sound)
                    str{i} = [num2str(i) '. ' sound(i).filename];
                end
                str{length(sound)+1} = 'Random';
                str{length(sound)+2} = 'None';
            case 'soundFile'
                for i = 1:length(sound)
                    str{i} = sound(i).filename;
                end
            case 'obswin'
                for i = 1:length(obswin)
                    str{i} = num2str(i);
                end
            case 'path'
                for i = 1:length(path)
                    str{i} = num2str(i);
                end
            case 'struct'
                for i = 1:length(structure)
                    str{i} = num2str(i);
                end
            case 'phase'
                for i = 1:length(phase)
                    str{i} = num2str(i);
                end
            case 'randomSet'
                for i = 1:length(randomSet)
                    str{i} = num2str(i);
                end
        end
    end

%% ResetGUI
    function ResetGUI()
        %set(gui.paraListBox, 'Value', 1, 'UserData', 1);
        set(gui.SMARTTVersion, 'String', ['V. ' num2str(smarttVersion,'%.1f')]); %MO: added
        set(gui.debugCheckbox, 'Value', debug);
        set(gui.connTobiiCheckbox, 'Value', connTobii);
        set(gui.connNIRSCheckbox, 'Value', connNIRS);
        set(gui.SerialOTNumeditBox,'String', num2str(SerialOTNum));
        %MO: above 2 lines added
        set(gui.screen.editBox(1), 'String',num2str(scr.width));
        set(gui.screen.editBox(2), 'String',num2str(scr.height));
        set(gui.screen.editBox(3), 'String',[num2str(scr.bgcolor(1)) ' ' num2str(scr.bgcolor(2)) ' ' num2str(scr.bgcolor(3))]);
        set(gui.screen.editBox(4), 'String',scr.TobiiIPaddress);
        set(gui.screen.editBox(5), 'String',scr.TobiiPortNum);
        set(gui.mask.popupmenu, 'String', GetString('mask'), 'Value', 1, 'UserData', 1);
        SelectMask([], [], []);
        set(gui.loom.popupmenu, 'String', GetString('loom'), 'Value',1,'UserData', 1);
        SelectLoomEffect([], [], []);
        set(gui.object.imgListBox, 'String', GetString('imgFile'));
        set(gui.sound.ListBox, 'String', GetString('soundFile'));
        set(gui.obswin.popupmenu, 'String', GetString('obswin'), 'Value', 1,'UserData', 1);
        SelectObswin([], [], []);
        set(gui.path.popupmenu, 'String', GetString('path'), 'Value', 1, 'UserData', 1);
        SelectPath([], [], []);
        set(gui.effect.popupmenu(1), 'Value',1);
        SelectEffectPath([], [], []);
        set(gui.struct.popupmenu(1), 'String', GetString('struct'), 'Value', 1, 'UserData', 1);
        SelectStructure([], [], []);
        set(gui.phase.popupmenu, 'String', GetString('phase'), 'Value', 1, 'UserData', 1);
        SelectPhase([], [], []);
        set(gui.randomSet.popupmenu, 'String', GetString('randomSet'), 'Value', 1, 'UserData', 1);
        SelectRandomSet([], [], []);
        set(gui.structAttribute.popupmenuStruct, 'Value', 1, 'UserData', 1);
        SelectStructureAttribute([], [], []);
        set(gui.quitPhase.popupmenuPhaseNum, 'Value', 1, 'UserData', 1);
        SelectQuitPhase([], [], []);
    end

%% Find max time duration for image moving througth interesting nodes of structure (sec)
    function maxTime = FindMaxTime(si)
        pathX = path(structure(si).pathNum).x(structure(si).interestNodes(1):structure(si).interestNodes(2));
        pathY = path(structure(si).pathNum).y(structure(si).interestNodes(1):structure(si).interestNodes(2));
        pathDistance = sqrt(diff(pathX).*diff(pathX) + diff(pathY).*diff(pathY));
        maxTime = sum(pathDistance)/structure(1).imgMoveSpeed; %sec
    end

%% Select interesting node in Structures Attribute
    function SelectInterestNode(Object, eventdata, handles)
        s = get(gui.paraListBox, 'String');
        v = get(gui.paraListBox, 'Value');
        error = CheckInput(s, v);
        if ~error
            u = get(gui.structAttribute.popupmenuStruct, 'UserData');
            set(gui.structAttribute.textBoxMaxTime, 'String', ['(' num2str(FindMaxTime(u)*1000,'%.0f') 'ms)']);
        end

    end
end

