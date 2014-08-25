classdef ObjectInspector < handle
    properties
        Enable_ToolTips = false;
        ParamNameWidth = 158;
        ParamValueWidth = 141;
        logging = false;
        handles
    end
    properties (Hidden = true)
        listenerHandles = [];
        progressbar_handle = [];
        tooltips
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           
           %% Single Entry
           handle = Ycbcr2RGB_ColourGamut('Y',0.6);
           obj = ObjectInspector(handle);
           
           %% Multiple Entries        
           csp = RB_Norm_ColourSpaceGen(   'method',                   'direct', ...
                                           'ImageSize',                 256, ...
                                           'ValueSacrifice_Enable',     true, ...
                                           'LumTarget',                 256, ...
                                           'RemoveClipped',             true);
           obj = ObjectInspector(csp);
        end
        function obj = ObjectInspector(varargin)
           %% Vars
           ObjHandle1 = varargin{1};
           varargin = varargin(2:end);
           x = size(varargin,2);
           for i = 1:2:x
               obj.(varargin{i}) = varargin{i+1};
           end
           
           persistent ObjHandle 
           ObjHandle = ObjHandle1;
           obj.handles.ObjHandle = ObjHandle;
            
           %%
           Params = obj.GetParamList();
           VisibleMethods = obj.GetMethodList();
           ClassName = class(ObjHandle);
           Spacing = 22;
           
           %%
           try
           load(ClassName);
           obj.tooltips = tooltips;
           NoToolTip = false;  
           catch
           NoToolTip = true;    
           end
           
           %%
           FigureHeight = (size(Params,1)+size(VisibleMethods,1)+1)*Spacing+2;
           figureWidth = 350 + obj.ParamValueWidth - 141 + obj.ParamNameWidth - 158;
           obj.GenerateFigure(FigureHeight,figureWidth,ClassName); %78 old value
           MaxControls = Inf;
           
           handles = obj.AddAllControls(MaxControls,FigureHeight,Spacing,Params);
           obj.handles.control = handles;
                   
           
           %%
           
           x = size(Params,1);
           StartHeight = Spacing*(x+1);
           handles_method = obj.AddAllMethodControls(MaxControls,FigureHeight,StartHeight,Spacing,VisibleMethods);
           
           set(obj.handles.figure,'Visible','on');
           
           
           %%
           if obj.Enable_ToolTips == true
               x = size(Params,1);
               for i = 1:x
                   paramName = Params{i};
                   obj.AddToolTip(handles(i).ParamName, paramName, NoToolTip);
               end

               %%
               x = size(VisibleMethods,1);
               for i = 1:x
                   paramName = VisibleMethods{i};
                   obj.AddToolTip(handles_method(i).ParamName, paramName, NoToolTip);
               end
           end
           
           %%
           if NoToolTip == true  
                   files = which('ObjectInspector');
                   [path,~,~] = fileparts(files);
                   PATH = fullfile(path,'Help');
                   mkdir(PATH);
                   tooltips = obj.tooltips;
                   save(fullfile(PATH,ClassName),'tooltips');
           end
           
           %%
           temp.ObjHandle = ObjHandle;
           obj.handles = temp;
           
        end
    end
    methods %Support
        function handles = AddAllMethodControls(obj,MaxControls,FigureHeight,StartHeight,Spacing,Methods)
            x = size(Methods,1);
            if x > MaxControls
                x = MaxControls;
            end
            for i = 1:x
                handles(i) = obj.addMethodBox(Methods{i},FigureHeight-StartHeight,      obj.ParamValueWidth,	obj.ParamNameWidth, Spacing*(i-1));
            end           
        end
        function RemoveAllControls(obj,handles)
            %% Remove Slithers
            x = size(handles,2);
            for i = 1:x
                obj.deleteEditBox(handles(i));
            end            
        end
        function handles = AddAllControls(obj,MaxControls,FigureHeight,Spacing,Params)
            %% Add all slithers 
            x = size(Params,1);
            if x > MaxControls
                x = MaxControls;
            end
            for i = 1:x
                Param = Params{i};
                CLASSTYPE = obj.ClassTypeDetection(Param);
                switch lower(CLASSTYPE)
                    case 'editbox'
                        handles(i) = obj.addEditBox(                Param, FigureHeight, obj.ParamValueWidth,   obj.ParamNameWidth, Spacing*(i));
                    case 'spectrum'
                        handles(i) = obj.addSpectrum(                Param, FigureHeight, obj.ParamValueWidth,   obj.ParamNameWidth, Spacing*(i));
                    case 'progress'
                        obj.addProgressBar(            Param, FigureHeight, obj.ParamValueWidth,   obj.ParamNameWidth, Spacing*(i));
                    case 'struct'
                        error('not currently supported')
                    case 'image'
                        handles(i) = obj.addImageBox(               Param, FigureHeight, Spacing*(i))
                    case 'array'
                        handles(i) = obj.addDataSetTableView(       Param, FigureHeight, Spacing*(i));
                    case 'logical'
                        handles(i) = obj.addLogicalBox(             Param, FigureHeight, obj.ParamValueWidth,   obj.ParamNameWidth, Spacing*(i));
                    case 'object'
                        handles(i) = obj.addObjectBox(              Param, FigureHeight, Spacing*(i));
                    case 'matrix2by1'
                        handles(i) = obj.addMatrix2by1Box(          Param, FigureHeight, Spacing*(i));
                    case 'matrix3by1'
                        handles(i) = obj.addMatrix3by1Box(          Param, FigureHeight, Spacing*(i));
                    case 'multitext'
                        handles(i) = obj.addMultiTextBox(           Param, FigureHeight, obj.ParamValueWidth,    obj.ParamNameWidth,  Spacing*(i));
                    case 'multitextselection'
                        handles(i) = obj.addMultiTextSelectionBox(  Param, FigureHeight, obj.ParamValueWidth,    obj.ParamNameWidth, Spacing*(i));
                    case 'dataset'
                        handles(i) = obj.addDataSetTableView(       Param, FigureHeight, obj.ParamValueWidth,    obj.ParamNameWidth, Spacing*(i));
                    case 'dirselection'
                        handles(i) = obj.addDirSelection(           Param, FigureHeight, obj.ParamValueWidth,    obj.ParamNameWidth,  Spacing*(i));
                    case 'fileselection'
                        handles(i) = obj.addFileSelection(          Param, FigureHeight, obj.ParamValueWidth,    obj.ParamNameWidth,  Spacing*(i));
                    otherwise
                end
            end
            if not(exist('handles'))
                handles = [];
            end
        end
        function CLASSTYPE = ClassTypeDetection(obj,Param)   
            CLASSTYPE = 'object';
            CLASS = class(obj.handles.ObjHandle.(Param));
            if not(ischar(obj.handles.ObjHandle.(Param)))
                [x,y,z] = size(obj.handles.ObjHandle.(Param));
            else
                y = 1;
                z = 1;
                x = 1;
            end
            if strcmpi(CLASS,'cell')
                CLASSTYPE = 'multiText';
            end
            if strcmpi(CLASS,'dataset')
                CLASSTYPE = 'dataset';
            end
            if strcmpi(CLASS,'imageCLASS')
                CLASSTYPE = 'image';
            end
            if strcmpi(CLASS,'struct')
                NAMES = fieldnames(obj.handles.ObjHandle.(Param));
                n = strcmpi(NAMES,'image');
                if not(isempty(n))
                    CLASSTYPE = 'image';
                else
                    CLASSTYPE = 'struct';
                end
            end
            if not(or(x > 1, y > 1))      
                switch lower(CLASS)
                    case 'char'
                        try
                            obj.handles.ObjHandle.([Param,'_LUT']);
                            CLASSTYPE = 'multiTextSelection';
                        catch
                            if strcmpi(computer,'GLNXA64')
                                n = findstr(obj.handles.ObjHandle.(Param),'/');
                            else
                                n = findstr(obj.handles.ObjHandle.(Param),'\');
                            end
                            if isempty(n)
                                CLASSTYPE = 'editbox';
                            else
                                Length = size(obj.handles.ObjHandle.(Param),2);
                                Last_ = n(end);
                                if Length == Last_
                                    CLASSTYPE = 'dirSelection';
                                else
                                    CLASSTYPE = 'fileSelection';
                                end
                            end
                        end
                    case 'double'
                        CLASSTYPE = 'editbox';
                    case 'logical'
                        CLASSTYPE = 'logical';
                    otherwise
                end
            else %matrix    
                if  and(x == 1, y == 2)
                    CLASSTYPE = 'matrix2by1';
                elseif and(x == 1, y == 3)
                    CLASSTYPE = 'matrix3by1';
                else
                    switch lower(CLASS)
                        case {'uint16','double','uint8'}  
                            if and(z == 3, x > 100)
                                CLASSTYPE = 'image';
                            else
                                CLASSTYPE = 'array';
                            end
                        otherwise
                    end
                end
            end
            if strcmpi(Param,'Progress')  
                CLASSTYPE = 'progress';
            end
            %% Class overwrites
            try
                CLASSTYPE = obj.handles.ObjHandle.([Param,'_Class']);
            end
            %%
            if obj.logging == true
                    disp(['Evaluting: ',Param])
                    disp(['CLASS: ',CLASS])
                    disp(['CLASSTYPE: ',CLASSTYPE])
                    disp(' ')
            end
        end
        function Params = GetParamList(obj)
            % This function will only return properties that are not
            % hidden. So change the hidden property of the class def if you
            % don't want them to appear. It may be more flexible to add a
            % parameter to hide visible or make hidden properties appear on
            % the GUI. For now it will not be considered. 
            
            %%
            Params = properties(obj.handles.ObjHandle);
        end
        function VisibleMethods = GetMethodList(obj)
            %%
            Methods = methods(obj.handles.ObjHandle);
            RemovedMethods = {  'Example'; ...
                                'addlistener'; ...
                                'delete'; ...
                                'eq'; ...
                                'findobj'; ...
                                'findprop'; ...
                                'ge'; ...
                                'gt'; ...
                                'isvalid'; ...
                                'le'; ...
                                'lt'; ...
                                'ne'; ...
                                'notify'};
            VisibleMethods = [];
            x = size(Methods,1);
            for i = 1:x
                method_ = Methods{i};
                n = find(strcmpi(method_,RemovedMethods));
                if isempty(n)
                    VisibleMethods = [VisibleMethods;{method_}];
                end
            end
        end
        function GenerateFigure(obj,figureHeight,figureWidth,ClassName)
            %%
            obj.handles.figure = figure;
            set(obj.handles.figure, 'Position',     [0, 0 , figureWidth, figureHeight], ...
                                    'MenuBar',      'none', ...
                                    'Resize',       'off', ...
                                    'Visible',       'off', ...
                                    'Name',         ['Obj Inspect: ',ClassName], ...  
                                    'DeleteFcn',    @obj.DeleteFig, ...
                                    'NumberTitle',  'off');
            movegui(obj.handles.figure,'center'); 
        end
        function icon = ChangeBG_Colour(obj,icon,Colour)
            [x,y,z] = size(icon);
            icons = reshape(icon,x*y,3);
            MASK = (icons(:,1)==1).*(icons(:,2)==0).*(icons(:,3)==1);
            n = find(MASK == 1);
            icons(n,1) = Colour(1);
            icons(n,2) = Colour(2);
            icons(n,3) = Colour(3);
            icon = reshape(icons,x,y,3);            
        end
        function icon = ChangeBG_Colour2(obj,icon,Colour,OldColour)
            [x,y,z] = size(icon);
            icons = reshape(icon,x*y,3);
            MASK = (icons(:,1)==OldColour(1)).*(icons(:,2)==OldColour(2)).*(icons(:,3)==OldColour(3));
            n = find(MASK == 1);
            icons(n,1) = Colour(1);
            icons(n,2) = Colour(2);
            icons(n,3) = Colour(3);
            icon = reshape(icons,x,y,3);            
        end
        function DeleteFig(varargin)
           disp('fig delete in process') 
           obj = varargin{1};
           x = max(size(obj.listenerHandles));
           for i = 1:x
               delete(obj.listenerHandles{i})
           end
        end
        function AddlistenerHandle(obj,handle)
            %%
            x = max(size(obj.listenerHandles));
            obj.listenerHandles{x+1} = handle;
        end
        function AddToolTip(obj,h1,paramName,NoToolTip)
            if NoToolTip == true
            ClassName = class(obj.handles.ObjHandle);
            Help = feval('help',[ClassName,'.',paramName]);
            obj.tooltips.(paramName) = Help;
            else
                Help = obj.tooltips.(paramName);
            end
            
            jButton= findjobj(h1);
            set(jButton,'Enabled',false);
            set(jButton,'ToolTipText',Help); 
        end
    end
    methods  %GUI - Add File Selection
        function handle  = addFileSelection(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            mode = 'pixels'; %pixels or normalized
         	Fudge = 18;
                
          	height = FigureHeight - H_StartLoc;
          	Gap_Border2ParamBox = 8;
%           	ParameterBoxWidth = 158;
         	SlitherHeight = 22;  
                
          	% edit box
%            	EditBoxWidth = 158-Fudge;
           	Gap_ParamBox2EditBox = Fudge;
                
           	% set button
           	Gap_EditBox2SetButtom = 0;
           	SetButtonWidth = 26;
                
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
            
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)), ...
                            'Position',             Pos.editBox);
                        
            filename = fullfile( matlabroot,'toolbox','matlab','icons','HDF_filenew.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);  
            icon = obj.ChangeBG_Colour(icon,[1,1,1]);
            
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA',                icon, ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.getFileDir(paramName,h2), ...
                            'position',             Pos.setButton);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateFile(paramName,h2));
            obj.AddlistenerHandle(h);
            
        end  
        function getFileDir(obj,paramName,h2)
            DIR = get(h2,'String');
            [filename,path] = uigetfile(DIR);
            set(h2,'String',fullfile(path,filename));
            obj.handles.ObjHandle.(paramName) = fullfile(path,filename);
        end
        function updateFile(varargin)
            obj = varargin{1};
            paramName = varargin{2};
            h2 = varargin{3};
            %%
            if ischar(obj.handles.ObjHandle.(paramName))
                set(h2,'String',obj.handles.ObjHandle.(paramName));
            else
                set(h2,'String',num2str(obj.handles.ObjHandle.(paramName)));
            end
        end    
    end
    methods  %GUI - Add Directory Selection
        function handle  = addDirSelection(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if strcmpi(h.SetAccess,'protected')
                button_Enable = 'off';
                GapText = 'RO';
                EditBoxEnable = 'inactive';
            else            
                button_Enable = 'on';
                GapText = '';
                EditBoxEnable = 'on';
            end
            mode = 'pixels'; %pixels or normalized
         	Fudge = 18;
                
          	height = FigureHeight - H_StartLoc;
          	Gap_Border2ParamBox = 8;
%           	ParameterBoxWidth = 158;
         	SlitherHeight = 22;  
                
          	% edit box
%            	EditBoxWidth = 158-Fudge;
           	Gap_ParamBox2EditBox = Fudge;
                
           	% set button
           	Gap_EditBox2SetButtom = 0;
           	SetButtonWidth = 26;
                
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName); 
            
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               GapText, ...
                            'FontSize',             7, ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               EditBoxEnable, ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)), ...
                            'Position',             Pos.editBox);
                        
            filename = fullfile( matlabroot,'toolbox','matlab','icons','foldericon.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);    
            
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA',                icon, ...
                            'Units',                mode, ...
                            'Enable',               button_Enable, ...
                            'Callback',             @(x,y)obj.getFolderDir(paramName,h2), ...
                            'position',             Pos.setButton);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateFolderDir(paramName,h2));
            obj.AddlistenerHandle(h);
        end  
        function getFolderDir(obj,paramName,h2)
            DIR = get(h2,'String');
            directoryname = uigetdir(DIR);
            if not(isnumeric(directoryname))
                if strcmpi(computer,'glnxa64')
                    directoryname = [directoryname,'/'];
                else
                    directoryname = [directoryname,'\'];
                end
                set(h2,'String',directoryname);
                obj.handles.ObjHandle.(paramName) = directoryname;
            end
        end
        function updateFolderDir(varargin)
            obj = varargin{1};
            paramName = varargin{2};
            h2 = varargin{3};
            %%
            if ischar(obj.handles.ObjHandle.(paramName))
                set(h2,'String',obj.handles.ObjHandle.(paramName));
            else
                set(h2,'String',num2str(obj.handles.ObjHandle.(paramName)));
            end
        end            
    end
    methods  %GUI - Add dataset table view box
        function handle = addDataSetTableView(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            mode = 'pixels'; %pixels or normalized

            Fudge = 18;
                
          	height = FigureHeight - H_StartLoc;
         	Gap_Border2ParamBox = 8;
%          	ParameterBoxWidth = 158;
         	SlitherHeight = 22;  
                
          	% edit box
         	Gap_ParamBox2EditBox = Fudge;
                
          	% set button
          	Gap_EditBox2SetButtom = 0;
          	SetButtonWidth = 26;
                
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '[Dataset]', ...
                            'Position',             Pos.editBox);
    
            % create a pushbutton to confirm the assignment
            filename = fullfile( matlabroot,'toolbox','matlab','icons','HDF_VData.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            icon = obj.ChangeBG_Colour(icon,[1,1,1]);
            
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              '', ...
                            'CDATA',                icon, ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.runDataSetTableView(paramName), ...
                            'position',             Pos.setButton);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
%             obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateEditBox(paramName,h2));
            
        end
        function runDataSetTableView(obj,paramName)
            %%
            disp('set DATASET table view')
            if strcmpi(computer,'GLNXA64')
            uiDataSetTable( 'DATASET',obj.handles.ObjHandle.(paramName), ...
                            'ObjectHandle',obj.handles.ObjHandle, ...
                            'xls', false, ...
                            'ParamName',(paramName));         
            else
            uiDataSetTable( 'DATASET',obj.handles.ObjHandle.(paramName), ...
                            'ObjectHandle',obj.handles.ObjHandle, ...
                            'xls', false, ...
                            'ParamName',(paramName));                    
            end
        end
    end
    methods  %GUI - Add multi Text Selection Box Selection
        function handles = addMultiTextSelectionBox(obj,paramName,FigureHeight,EditBoxWidth,ParamNameWidth,H_StartLoc)
            %%
            persistent listen ObjHandle
            listen = true;
            ObjHandle = obj.handles.ObjHandle;
            %disp(['Disp Loc: ',num2str(H_StartLoc-22)])
%             ClassName = class(obj.handles.ObjHandle);
%             Help = feval('help',[ClassName,'.',paramName]);

            
            %%
            [handle] = MultiTextSelectionBox( 'Type', 'MultiTextSelection', ...
                                            'paramName', paramName, ...
                                            'paramValue', obj.handles.ObjHandle.(paramName), ...
                                            'LUT', obj.handles.ObjHandle.([paramName,'_LUT']), ...
                                            'ParamNameWidth', ParamNameWidth, ...
                                            'EditBoxWidth', EditBoxWidth, ...
                                            'ParentFigureHandle',obj.handles.figure, ...
                                            'SpaceFromTop',H_StartLoc-22);
            handles = handle.handle;
            
            %%
            obj.CheckParamsAreObservable({  paramName; ...
                                            [paramName,'_LUT']});
                  
            h1 = obj.handles.ObjHandle.addlistener(  paramName,          'PostSet',  @(x,y)obj.GUI_updateMultiTextSelectionBox(handle,paramName));  
            h2 = obj.handles.ObjHandle.addlistener( [paramName,'_LUT'],  'PostSet',  @(x,y)obj.GUI_updateMultiTextLUT(handle,paramName)); 
            obj.AddlistenerHandle(h1);
            obj.AddlistenerHandle(h2);
            
            h = handle.addlistener( 'paramValue', 'PostSet',  @(x,y)obj.Params_updateMultiTextSelectionBox(handle,paramName)); 
            obj.AddlistenerHandle(h);
            
        end
        function CheckParamsAreObservable(obj,paramName)
            if ischar(paramName)
                h = findprop(obj.handles.ObjHandle,paramName);
                if h.SetObservable == false
                    error(['Please change "',paramName,'", parameter to SetObservable = true'])
                end     
            else
                x = max(size(paramName));
                for i = 1:x
                    h = findprop(obj.handles.ObjHandle,paramName{i});
                    if h.SetObservable == false
                        error(['Please change "',paramName{i},'", parameter to SetObservable = true'])
                    end   
                end
            end
        end  
        function GUI_updateMultiTextSelectionBox(varargin)
            persistent listen 
            obj = varargin{1};
            handle = varargin{2};
            paramName = varargin{3};
            if listen == true
                disp('GUI_updateMultiTextSelectionBox')
                listen = false;
                currentValue = obj.handles.ObjHandle.(paramName)
                handle.paramValue = currentValue;
                listen = true;
            end
        end
        function GUI_updateMultiTextLUT(varargin)
            %%
            obj = varargin{1};
            obj.handles.ObjHandle
            %%
%             persistent ObjHandle
%             obj = varargin{1};
            handle = varargin{2};
            paramName = varargin{3};
            disp('GUI_updateMultiTextLUT')
            currentValue = obj.handles.ObjHandle.([paramName,'_LUT']);
            handle.LUT = currentValue;
            
            %%
            obj.handles.ObjHandle.(paramName) = obj.handles.ObjHandle.([paramName,'_LUT']){1};
            
            %%
            
        end
        function Params_updateMultiTextSelectionBox(varargin)
            persistent listen
            if isempty(listen)
                listen = true;
            end
            obj = varargin{1};
            handle = varargin{2};
            paramName = varargin{3};
            
            if listen == true
                disp('Params_updateMultiTextSelectionBox')
                listen = false;
                paramValue = handle.paramValue;
                obj.handles.ObjHandle.(paramName) = paramValue;
                listen = true;
            end
        end
    end
    methods  %GUI - Add Multi Text Box Selection
        function handles = addMultiTextBox(obj,paramName,FigureHeight,EditBoxWidth,ParamNameWidth,H_StartLoc)
            %%
            handle = MultiTextSelectionBox( 'Type', 'MultiText', ...
                                            'paramName', paramName, ...
                                            'LUT', obj.handles.ObjHandle.(paramName), ...
                                            'EditBoxWidth',EditBoxWidth, ...
                                            'ParamNameWidth',ParamNameWidth, ...
                                            'ParentFigureHandle',obj.handles.figure, ...
                                            'SpaceFromTop',H_StartLoc-22)  
            h1 = obj.handles.ObjHandle.addlistener(  paramName,  'PostSet', ...
                                                @(x,y)obj.runMultiTextBox(handle,paramName)); 
                                            
            handles = handle.handle;
            obj.AddlistenerHandle(h1);
        end
        function runMultiTextBox(varargin)
            %%
            dips('harrya')
            handle.LUT = obj.handles.ObjHandle.(paramName);            
        end
    end
    methods  %GUI - Add Metric 3by1 Box
        function handle = addMatrix3by1Box(obj,paramName,FigureHeight,H_StartLoc)    
            %%
            %%
            mode = 'pixels'; %pixels or normalized
            Fudge = 18;

            height = FigureHeight - H_StartLoc;
            Gap_Border2ParamBox = 8;
            ParameterBoxWidth = 158;
            SlitherHeight = 22;  

            % edit box
            EditBoxWidth = 158-Fudge;
            Gap_ParamBox2EditBox = Fudge;

            % set button
            Gap_EditBox2SetButtom = 0;
            SetButtonWidth = 26;
                
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth/3, ...
                                SlitherHeight];
                            
            Pos.editBox3 =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth/3, ...
                                height, ...
                                EditBoxWidth/3, ...
                                SlitherHeight];
                            
            Pos.editBox4 =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth*2/3, ...
                                height, ...
                                EditBoxWidth/3, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);
             
            CLASS = class(obj.handles.ObjHandle.(paramName)(1));
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)(1)), ...
                            'Position',             Pos.editBox);
                        
            % create a edit box for you to type the desired value
            h5 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)(2)), ...
                            'Position',             Pos.editBox3);
                        
            % create a edit box for you to type the desired value
            h6 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)(3)), ...
                            'Position',             Pos.editBox4);
                        
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              'Set', ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.setMatrix3by1Box(paramName,h6,h5,h2,CLASS), ...
                            'position',             Pos.setButton);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateMatrix3by1Box(paramName,h6,h5,h2));
            obj.AddlistenerHandle(h1);
        end
        function setMatrix3by1Box(obj,paramName,h6,h4,h2,CLASS)
            %%
            disp('CLASS')
            Value1 = str2num(get(h2,'String'));
            Value2 = str2num(get(h4,'String'));
            Value3 = str2num(get(h6,'String'));
            Value = [Value1, Value2, Value3];
            switch CLASS
                case 'uint8'
                    Value = uint8(Value);
                otherwise
            end
            obj.handles.ObjHandle.(paramName) = Value;
        end
        function updateMatrix3by1Box(obj,paramName,h6,h4,h2)
            Value = obj.handles.ObjHandle.(paramName);
            set(h2,'String',num2str(Value(1)));
            set(h4,'String',num2str(Value(2)));
            set(h6,'String',num2str(Value(3)));
        end
    end
    methods  %GUI - Add Metric 2by1 Box
        function handle = addMatrix2by1Box(obj,paramName,FigureHeight,H_StartLoc)       
            %%
            mode = 'pixels'; %pixels or normalized
            Fudge = 18;

            height = FigureHeight - H_StartLoc;
            Gap_Border2ParamBox = 8;
            ParameterBoxWidth = 158;
            SlitherHeight = 22;  

            % edit box
            EditBoxWidth = 158-Fudge;
            Gap_ParamBox2EditBox = Fudge;

            % set button
            Gap_EditBox2SetButtom = 0;
            SetButtonWidth = 26;
                
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth/2, ...
                                SlitherHeight];
                            
            Pos.editBox3 =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth/2, ...
                                height, ...
                                EditBoxWidth/2, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)(1)), ...
                            'Position',             Pos.editBox);
                        
            % create a edit box for you to type the desired value
            h5 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)(2)), ...
                            'Position',             Pos.editBox3);
                        
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              'Set', ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.setMatrix2by1Box(paramName,h5,h2), ...
                            'position',             Pos.setButton);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateMatrix2by1Box(paramName,h5,h2));
            obj.AddlistenerHandle(h1);
        end
        function setMatrix2by1Box(obj,paramName,h4,h2)
            Value = [str2num(get(h2,'String')), str2num(get(h4,'String'))]
            obj.handles.ObjHandle.(paramName) = Value;
        end
        function updateMatrix2by1Box(obj,paramName,h4,h2)
            Value = obj.handles.ObjHandle.(paramName);
            set(h2,'String',num2str(Value(1)));
            set(h4,'String',num2str(Value(2)));
        end
    end
    methods  %GUI - Add Object Box
        function handle = addObjectBox(obj,paramName,FigureHeight,H_StartLoc)
            %%
            mode = 'pixels'; %pixels or normalized
            Fudge = 18;

            height = FigureHeight - H_StartLoc;
            Gap_Border2ParamBox = 8;
            ParameterBoxWidth = 158;
            SlitherHeight = 22;  


            % edit box
            EditBoxWidth = 158-Fudge;
            Gap_ParamBox2EditBox = Fudge;

            % set button
            Gap_EditBox2SetButtom = 0;
            SetButtonWidth = 26;
            
            %%
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight]; 
                            
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos.paramName);
    
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '[Object]', ...
                            'Position',             Pos.editBox);
    
            filename = fullfile( matlabroot,'toolbox','matlab','icons','HDF_object01.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            
            %%
%             icon = obj.ChangeBG_Colour(icon,[1,1,1]);
            icon = obj.ChangeBG_Colour2(icon, [NaN,NaN,NaN], [icon(1,1,1),icon(1,1,2),icon(1,1,3)]);

            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA' ,               icon, ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.setObjectBox(paramName), ...
                            'position',             Pos.setButton);
                        
            % create a edit box for you to type the desired value
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;             
        end
        function setObjectBox(obj,paramName)
            %%
            ObjectInspector(obj.handles.ObjHandle.(paramName));
        end
    end
    methods  %GUI - Add Image Box
        function handle = addImageBox(obj,paramName,FigureHeight,H_StartLoc)
            %%
            height = FigureHeight - H_StartLoc;
            Gap_Border2ParamBox = 8;
            ParameterBoxWidth = 158;
            SlitherHeight = 22;  
                
            % edit box
            EditBoxWidth = 158-18+1;
            Gap_ParamBox2EditBox = 0;
                
            % set button
            Gap_EditBox2SetButtom = 0;
            SetButtonWidth = 16;
            
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+SetButtonWidth+Gap_EditBox2SetButtom + 1, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.checkBox = [    Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox + 1, ...
                                height + 2, ...
                                SetButtonWidth, ...
                                SlitherHeight - 4];     
            
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
           
            try
                [x,y,z] = size(obj.handles.ObjHandle.(paramName).image);
            catch
                error('image array class not properly defined')
            end
            String = ['IMAGE <',num2str(x),'x',num2str(y),'x',num2str(z),'>'];
            Value = 0;

%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                'pixel', ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'Position',             Pos.paramName);
                        
            % create a pushbutton to confirm the assignment
            
            h2 = uicontrol( 'Style',                'checkbox', ...
                            'String' ,              'Set', ...
                            'Value',                Value, ...
                            'Units',                'pixel', ...
                            'position',             Pos.checkBox);
            
    
            % create a edit box for you to type the desired value
            h3 = uicontrol( 'Style',                'edit', ...
                            'Units',                'pixel', ...
                            'Enable',               'inactive', ...
                            'HorizontalAlignment',  'left', ...
                            'String',               String, ...
                            'Position',             Pos.editBox);
    
            set(h2,'Callback', @(x,y)obj.setImageBox(paramName,h2))

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateImageBox(paramName,h2));       
            obj.AddlistenerHandle(h1);
        end
        function setImageBox(obj,paramName,h2)
            %%
            Value = get(h2,'Value');
            if Value == true
            obj.handles.images.(paramName) = imageShow(     'imageOUT',        obj.handles.ObjHandle.(paramName), ...
                                                            'box_enable',   false)
            else
                try
                delete(obj.handles.images.(paramName).handles.figure);
                end
            end
        end
        function updateImageBox(obj,paramName,h2)
            %%
            Value = get(h2,'Value');
            if Value == true
                %%
                if not(isempty(obj.handles.ObjHandle.(paramName))) %it get set to zero to save memory
                    [x,y,z] = size(obj.handles.ObjHandle.(paramName).image);
                    [x1,y1,z1] = size(obj.handles.images.(paramName).imageOUT.image);
                    
                    if and(x1 == x,y == y1)
                        obj.handles.images.(paramName).imageOUT = obj.handles.ObjHandle.(paramName);
                    else
                        delete(obj.handles.images.(paramName).handles.figure);
                        obj.handles.images.(paramName) = imageShow(     'imageOUT',     obj.handles.ObjHandle.(paramName), ...
                                                                        'box_enable',   false)
                    end
                end
            end
            drawnow;
        end
    end
    methods  %GUI - Logical Box 
        function handle = addLogicalBox(obj,paramName,FigureHeight,EditBoxWidth,ParamNameWidth,H_StartLoc)
            %%
            height = FigureHeight - H_StartLoc;
            Gap_Border2ParamBox = 8;
            ParameterBoxWidth = ParamNameWidth;
            SlitherHeight = 22;  
                
            % edit box
            % EditBoxWidth = obj.ParamValueWidth;
            Gap_ParamBox2EditBox = 0;
                
            % set button
            Gap_EditBox2SetButtom = 0;
            SetButtonWidth = 16;
            
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+SetButtonWidth+Gap_EditBox2SetButtom + 1, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.checkBox = [    Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox + 1, ...
                                height + 2, ...
                                SetButtonWidth, ...
                                SlitherHeight - 4];     
            
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
           
            if obj.handles.ObjHandle.(paramName) == true
                String = 'TRUE';
                Value = 1;
                Color = [0,  0.4, 0];
            else
                String = 'FALSE';
                Value = 0;
                Color = [0.4, 0,  0];
            end
% 
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                'pixel', ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
            
            % create a pushbutton to confirm the assignment
            
            h2 = uicontrol( 'Style',                'checkbox', ...
                            'String' ,              'Set', ...
                            'Value',                Value, ...
                            'Units',                'pixel', ...
                            'position',             Pos.checkBox);
            

            
            % create a edit box for you to type the desired value
            h3 = uicontrol( 'Style',                'edit', ...
                            'Units',                'pixel', ...
                            'Enable',               'inactive', ... 
                            'HorizontalAlignment',  'left', ...
                            'String',               String, ...
                            'FontWeight',           'bold', ...
                            'ForegroundColor',      Color, ...
                            'Position',             Pos.editBox);
                        

    
            set(h2,'Callback', @(x,y)obj.setLogicalBox(paramName,h2,h3))

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateLogicalBox(paramName,h2,h3));
            obj.AddlistenerHandle(h1);
        end
        function setLogicalBox(obj,paramName,checkbox,editbox)
            Value = get(checkbox,'Value');
            if Value == 0
                Color = [0.4, 0, 0];
                set(editbox,'String','FALSE', ...
                            'ForegroundColor',Color)
                
            else
                Color = [0,  0.4, 0];
                set(editbox,'String','TRUE', ...
                            'ForegroundColor',Color)
            end
            if Value == 1
                obj.handles.ObjHandle.(paramName) = true;
            else
                obj.handles.ObjHandle.(paramName) = false;
            end
        end
        function updateLogicalBox(obj,paramName,checkbox,editbox)
            %%
            if obj.handles.ObjHandle.(paramName) == 0
                Color = [0.4, 0, 0];
                set(checkbox,'Value',0)
                set(editbox,'String','FALSE', ...
                            'ForegroundColor',Color)
            else
                Color = [0,  0.4, 0];
                set(checkbox,'Value',1)
                set(editbox,'String','TRUE', ...
                            'ForegroundColor',Color)
            end
        end
    end
    methods  %GUI - Method Box
        function handle = addMethodBox(obj,methodName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            mode = 'pixels'; %pixels or normalized
            if strcmpi(mode,'pixels')
                Fudge = 18;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 8;
                SlitherHeight = 22;  
                
                
                % edit box
                Gap_ParamBox2EditBox = Fudge;
                
                % set button
                Gap_EditBox2SetButtom = 0;
                SetButtonWidth = 26;
                
           else
                FigureHeight = 0.706;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 0.02;
                ParameterBoxWidth = 0.46;
                SlitherHeight = 0.3;
                
                % edit box
                EditBoxWidth = 0.445;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                SetButtonWidth = 0.07;
                Gap_EditBox2SetButtom = 0;
            end
            
            %%
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight]; 
                            
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
            
%             figure( obj.handles.figure )
            % create the popup menu which include all the properties
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               methodName, ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);   
            
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '[Function]', ...
                            'Position',             Pos.editBox);
    
            [X map] = imread(fullfile(...
                            matlabroot,'toolbox','matlab','icons','greenarrowicon.gif'));  
            icon = ind2rgb(X,map);
            icon = obj.ChangeBG_Colour2(icon, [NaN,NaN,NaN], [icon(1,1,1),icon(1,1,2),icon(1,1,3)]);
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA' ,               icon, ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.runMethodBox(methodName), ...
                            'position',             Pos.setButton);
                        
            % create a edit box for you to type the desired value
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '', ...
                            'Position',             Pos.editBox2);

            handle.ParmeterName = methodName;             
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;          
        end
        function runMethodBox(obj,methodName)
            %%
            obj.handles.ObjHandle.(methodName);
        end
    end
    methods  %GUI - Edit Box
        function handle = addEditBox(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if strcmpi(h.SetAccess,'protected')
                button_Enable = false;
                EditBoxEnable = 'inactive';
                GapText = 'RO';
            else            
                button_Enable = true;
                EditBoxEnable = 'on';
                GapText = '';
            end
            mode = 'pixels'; %pixels or normalized
            if strcmpi(mode,'pixels')
                Fudge = 18;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 8;
                SlitherHeight = 22;  
                
                % edit box
                Gap_ParamBox2EditBox = Fudge;
                
                % set button
                Gap_EditBox2SetButtom = 0;
                SetButtonWidth = 26;
                
           else
                FigureHeight = 0.706;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 0.02;
                ParameterBoxWidth = 0.46;
                SlitherHeight = 0.3;
                
                % edit box
                EditBoxWidth = 0.445;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                SetButtonWidth = 0.07;
                Gap_EditBox2SetButtom = 0;
            end
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure );
            % create the popup menu which include all the properties
            
            
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...  
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               GapText, ...
                            'FontSize',             7, ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               EditBoxEnable, ...
                            'String',               num2str(obj.handles.ObjHandle.(paramName)), ...
                            'Position',             Pos.editBox);
    
            if button_Enable == true
            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              'Set', ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.setEditBox(paramName,h2), ...
                            'position',             Pos.setButton);
            else
            h3 = [];    
            end

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateEditBox(paramName,h2));
            obj.AddlistenerHandle(h1);
        end
        function updateEditBox(varargin)
            persistent ObjHandle
            obj = varargin{1};
            paramName = varargin{2};
            h2 = varargin{3};
            if isempty(ObjHandle)
                ObjHandle = obj.handles.ObjHandle;
            end
            %%
            if ischar(ObjHandle.(paramName))
                set(h2,'String',ObjHandle.(paramName));
            else
                set(h2,'String',num2str(ObjHandle.(paramName)));
            end
        end
        function deleteEditBox(obj,handle)
            %%
            try
            delete(handle.ParamName);
            end
            try
            delete(handle.EditBox);
            end
            try
            delete(handle.SetButton);
            end
        end
        function setEditBox(obj,paramName,handle)
            %%
            Value = get(handle,'String');
            Value2write = str2num(Value);
            if isempty(Value2write)
                Value2write = Value;
            end
            obj.handles.ObjHandle.(paramName) = Value2write;
        end        
    end
    methods  %GUI - Progress bar
        function handle = addProgressBar(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if strcmpi(h.SetAccess,'protected')
                button_Enable = false;
                EditBoxEnable = 'inactive';
                GapText = 'RO';
            else            
                button_Enable = true;
                EditBoxEnable = 'on';
                GapText = '';
            end
            mode = 'pixels'; %pixels or normalized
            if strcmpi(mode,'pixels')
                Fudge = 18;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 8;
                SlitherHeight = 22;  
                
                % edit box
                Gap_ParamBox2EditBox = Fudge;
                
                % set button
                Gap_EditBox2SetButtom = 0;
                SetButtonWidth = 26;
                
           else
                FigureHeight = 0.706;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 0.02;
                ParameterBoxWidth = 0.46;
                SlitherHeight = 0.3;
                
                % edit box
                EditBoxWidth = 0.445;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                SetButtonWidth = 0.07;
                Gap_EditBox2SetButtom = 0;
            end
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure );
            % create the popup menu which include all the properties
            
            
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...  
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               GapText, ...
                            'FontSize',             7, ...
                            'Position',             Pos.editBox2);
                        
%             % create a edit box for you to type the desired value
%             h2 = uicontrol( 'Style',                'edit', ...
%                             'Units',                mode, ...
%                             'HorizontalAlignment',  'left', ...
%                             'Enable',               EditBoxEnable, ...
%                             'String',               num2str(obj.handles.ObjHandle.(paramName)), ...
%                             'Position',             Pos.editBox);
%     
%             if button_Enable == true
%             % create a pushbutton to confirm the assignment
%             h3 = uicontrol( 'Style',                'pushbutton', ...
%                             'String' ,              'Set', ...
%                             'Units',                mode, ...
%                             'Callback',             @(x,y)obj.setEditBox(paramName,h2), ...
%                             'position',             Pos.setButton);
%%
            h2 = ValueBox_Progress( 'Pos',          Pos.editBox, ...
                                    'FractionComplete', 0, ...
                                    'FigureHandle', obj.handles.figure)  ;
                                
            obj.progressbar_handle = h2;
%%
            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateProgressBar(paramName,h2));
            obj.AddlistenerHandle(h1);
        end
        function updateProgressBar(varargin)
            
            %%
            obj = varargin{1};
            paramName = varargin{2};
             
            index = obj.handles.ObjHandle.(paramName)(1);
            total = obj.handles.ObjHandle.(paramName)(2);
            
            obj.progressbar_handle.FractionComplete = index/total*100;
        end
        function deleteProgressBar(obj,handle)
            %%
            try
            delete(handle.ParamName);
            end
            try
            delete(handle.EditBox);
            end
            try
            delete(handle.SetButton);
            end
        end
        function setProgressBar(obj,paramName,handle)
            %%
            Value = get(handle,'String');
            Value2write = str2num(Value);
            if isempty(Value2write)
                Value2write = Value;
            end
            obj.handles.ObjHandle.(paramName) = Value2write;
        end        
    end
    methods  %GUI - Add Spectrum
        function handle = addSpectrum(obj,paramName,FigureHeight,EditBoxWidth,ParameterBoxWidth,H_StartLoc)
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if strcmpi(h.SetAccess,'protected')
                button_Enable = false;
                EditBoxEnable = 'inactive';
                GapText = 'RO';
            else            
                button_Enable = true;
                EditBoxEnable = 'on';
                GapText = '';
            end
            mode = 'pixels'; %pixels or normalized
            if strcmpi(mode,'pixels')
                Fudge = 18;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 8;
                SlitherHeight = 22;  
                
                % edit box
                Gap_ParamBox2EditBox = Fudge;
                
                % set button
                Gap_EditBox2SetButtom = 0;
                SetButtonWidth = 26;
                
           else
                FigureHeight = 0.706;
                
                height = FigureHeight - H_StartLoc;
                Gap_Border2ParamBox = 0.02;
                ParameterBoxWidth = 0.46;
                SlitherHeight = 0.3;
                
                % edit box
                EditBoxWidth = 0.445;
                Gap_ParamBox2EditBox = 0;
                
                % set button
                SetButtonWidth = 0.07;
                Gap_EditBox2SetButtom = 0;
            end
            Pos.editBox2 =   [   Gap_Border2ParamBox+ParameterBoxWidth, ...
                                height, ...
                                Fudge, ...
                                SlitherHeight];
                            
            %
            Pos.editBox =   [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox, ...
                                height, ...
                                EditBoxWidth, ...
                                SlitherHeight];
                            
            Pos.paramName = [   Gap_Border2ParamBox, ...
                                height, ...
                                ParameterBoxWidth, ...
                                SlitherHeight];
                            
            Pos.setButton = [   Gap_Border2ParamBox+ParameterBoxWidth+Gap_ParamBox2EditBox+EditBoxWidth+Gap_EditBox2SetButtom, ...
                                height, ...
                                SetButtonWidth, ...
                                SlitherHeight];     
            
%             figure( obj.handles.figure );
            % create the popup menu which include all the properties
            
            
            h1 = uicontrol( 'Style',                'edit', ...
                            'string',               paramName, ...
                            'Units',                mode, ...  
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'on', ...
                            'Position',             Pos.paramName);
    
            h4 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               GapText, ...
                            'FontSize',             7, ...
                            'Position',             Pos.editBox2);
                        
            % create a edit box for you to type the desired value
            h2 = uicontrol( 'Style',                'edit', ...
                            'Units',                mode, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',               'inactive', ...
                            'String',               '[Spectrum]', ...
                            'Position',             Pos.editBox);
    
            if button_Enable == true
                % tool_colorbar.gif
                        
            filename = fullfile( matlabroot,'toolbox','matlab','icons','tool_colorbar.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            icon = obj.ChangeBG_Colour2(icon, [NaN,NaN,NaN], [icon(1,1,1),icon(1,1,2),icon(1,1,3)]);
%             icon = obj.ChangeBG_Colour(icon, [icon(1,1,1),icon(1,1,2),icon(1,1,3)]);
            
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              '', ...
                            'CDATA',                icon, ...
                            'Units',                mode, ...
                            'Callback',             @(x,y)obj.runSpectrum(paramName), ...
                            'position',             Pos.setButton);
            else
            h3 = [];    
            end

            handle.ParmeterName = paramName;            
            handle.Type = 'edit_double';
            handle.ParamName   = h1;
            handle.EditBox     = h2;
            handle.SetButton   = h3;
            
            
            %%
            h = findprop(obj.handles.ObjHandle,paramName);
            if h.SetObservable == false
                error(['Please change "',paramName,'", parameter to SetObservable = true'])
            end
            h1 = obj.handles.ObjHandle.addlistener(paramName,'PostSet',@(x,y)obj.updateSpectrum(paramName,h2));
            obj.AddlistenerHandle(h1);
        end
        function runSpectrum(varargin)
            %%
            obj = varargin{1}
            paramName = varargin{2}
            DATASET = obj.handles.ObjHandle.(paramName);
            obj.handles.spectrum.(paramName) = plotSpectrum( 'DATASET',      DATASET);        
        end
        function updateSpectrum(varargin)
            %%
            x = 1;
            obj = varargin{1}
            paramName = varargin{2}
            obj.handles.spectrum.(paramName).DATASET = obj.handles.ObjHandle.(paramName);
        end
    end
end