classdef shape < matlab.mixin.SetGet
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = private)
        q_vec % link to position x,y & rotation, phi [x;y;phi] matrix
        body % outline of body
        lines = []
        forceArrows = []
        points % array of points struct of body
        options = struct('drawFrame',true,...
                         'fontSize',18);
        staticFlag = false
        fUnit = "kN" % unit of force
    end

    methods
        function obj = shape(q_vec,body) % constructor
            % Construct an instance of a shape class
            arguments
                q_vec (:,3)
                body 
            end
            obj.q_vec = q_vec;
            % obj.body = body;
            if isempty(body)
                obj.body = polyshape(); % create non-existing polygon rather than [] so that other funcs dont break
            else
                obj.body = polyshape(body(1,:),body(2,:));
            end
        end

        function createSlot(self,pos,phi,L,r)
            % Create a hole in the body
                % pos : starting position of slot
                % phi : angle
                % L : length of slot in direction of angle
                % r : half height of slot (radius of fillets)
            seg = linspace(pi/2,-pi/2,10); % segments of semicircles
            sPoints = [[L+r*cos(seg); % [x;y]
                          r*sin(seg)],...
                       [-r*cos(seg);
                        -r*sin(seg)]];
            pRot = TranslateAndRotate(pos,deg2rad(phi),sPoints);
            self.createHole(pRot);
        end

        function createHole(self,points)
            % Create a hole in the body
                % points : verteces if hole
            newBody = addboundary(self.body,points(1,:),points(2,:));
            set(self,'body', newBody);
        end

        function forceArrowPoint(self,pName,rot,force,frame,sf_width,sf_length)
            % Add a force arrow at a point on the shape
                % pName : name of point
                % grot : [radians] angle of force each timestep or a constant in the
                    % specified reference frame
                % force : force each timestep or a constant
                % frame : "global" or "local" , if local then current timestep
                    % shape angle + specified grot angle is applied, "global" by default
                % sf_width : width scale factor of arrow based on force
                % sf_length : length scale factor of arrow
            %TODO: continue
            arguments
                self 
                pName 
                rot 
                force 
                frame string {mustBeMember(frame,["global","local"])}
                sf_width 
                sf_length 
            end
            % Create forceArrow struct
            newArrow.pInd = self.findPoint(pName);
            newArrow.rot = rot;
            newArrow.rotStatic = isscalar(rot); % true if a single value was input (constant offset rotation)
            newArrow.rotLocal = strcmp(frame,"local"); % dosent check for "global" but shouldnt really matter due to mustBeMember check
            newArrow.force = force;
            newArrow.forceStatic = isscalar(force);
            newArrow.sf_width = sf_width;
            newArrow.sf_length = sf_length;
            set(self,'forceArrows',newArrow);
        end

        function solidLine(self,pos,n,d)
            % Add lines to the shape including optional solid ground lines
                % pos : [x1,x2;y1,y2] main line
                % n : number of ground lines, set to 0 to draw none
                % d : size of ground lines
            arguments
                self 
                pos (2,2)
                n 
                d (1,1) double = 0.1
            end
            if n <= 0
                line = pos;
            else
                line = [pos(:,1), zeros(2,n*3), pos(:,2)]; % initalize with start and end
                move = (pos(:,2)-pos(:,1))/n;
                phi = atan2(move(2,1),move(1,1)) - 3*pi/4; % angle of ground lines
                grLine = [cos(phi)*d;
                          sin(phi)*d];
                for i = 2:3:n*3-1
                    line(:,i) = line(:,i-1) + move;
                    line(:,i+1) = line(:,i) + grLine;
                    line(:,i+2) = line(:,i);
                end
            end
            set(self,'lines',line)
        end

        function addPoint(self,pos,name,MarkerSize,Marker,drawName)
            % Add a point to the body
                % pos : position of the point [x;y]
                % name : name of point
                % Marker : point marker style (see plot's linespec for markers)
                % MarkerSize : size of the point
                % drawName : bool to draw name
            arguments
                self 
                pos (1,2)
                name string
                MarkerSize = 8
                Marker string = '.' % dot, 'o' for circle
                drawName logical = true
            end
            for i = 1:length(self.points) % check if point already exists
                if strcmp(self.points(i).name, name)
                    error("Points on same shape require unique names")
                end
            end
            % if any(strcmp(self.points(1:length(self.points)).name,name)) % didnt work unfortunately 
            %     error("Points on same shape require unique names")
            % end
            p.pos = pos;
            p.name = name;
            p.MarkerSize = MarkerSize;
            p.Marker = Marker;
            p.drawName = drawName;
            set(self,'point',p);
        end

        function pointArray = drawBody(self,n)
            % draw the body on the current figure
                % n : index in q_vec position vector
            if self.staticFlag
                q = self.q_vec(1,:);
            else
                q = self.q_vec(n,:);
            end
            % rotate and translate points  
            pgon = rotate(self.body,rad2deg(q(3)));
            pgon = translate(pgon,q(1:2));
            % np = self.body
            % plot(np(1,:),np(2,:))
            plot(pgon)
            if ~isempty(self.lines)
                nl = TranslateAndRotate(q(1:2)',q(3)',self.lines);
                plot(nl(1,:),nl(2,:),"Color",'black')
            end
            if ~isempty(self.forceArrows)
                self.drawArrows(n,q);
            end
            if self.options.drawFrame
                drawCoordinate(self,q(1:2)',q(3))
            end
            pointArray = drawPoints(self,q(1:2)',q(3));
        end

        function setStatic(self,flag)
            arguments
                self 
                flag logical
            end
            set(self,'staticFlag',flag)
        end

        function setOptions(self,field,value)
            % Set additional items to draw
            % fields : array of options
            % value : cell of values

            % OPTIONS:
            % 'title', string : add text to the shape drawing % todo
            % 'frame', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line % todo
            % 'fontSize', double : font size
            arguments
                self 
            end
            arguments (Repeating)
                field string {mustBeMember(field,["drawFrame","fontSize"])}
                value
            end
            if length(field) ~= length(value)
                error("Expected even number of options and values")
            end
            for i = 1:length(field)
                set(self,"options",struct(field{i},value{i}))
            end
        end

        function cellPRef = point(self,name)
            % return a reference to a point for use in creating links between points
                % name : name of point on object
                arguments
                    self 
                    name string
                end
            if isempty(self.points)
                error("No points have been created");
            end
            pInd = self.findPoint(name);
            cellPRef.obj = self;
            cellPRef.index = pInd;
            cellPRef.init = TranslateAndRotate(self.q_vec(1,1:2)',self.q_vec(1,3),...
                                               self.points(pInd).pos'); % point at t=0
        end

        %% setters
        function set.body(obj,newBody)
            obj.body = newBody;
        end
        function set.lines(obj,newLines)
            obj.lines = newLines;
        end
        function set.staticFlag(obj,flag)
            obj.staticFlag = flag;
        end
        function set.options(obj,field_val)
            field = fieldnames(field_val);
            val = struct2cell(field_val);
            obj.options.(field{1}) = val{1};
            % oldvals = obj.options;
            % obj.options = setfield(oldvals,field{1},val{1});% setfield(oldvals,field_val{1},field_val{2});
        end
        function set.points(obj,pointStruct)
            obj.points = [obj.points pointStruct];
        end
        function set.forceArrows(obj,arrowStruct)
            obj.forceArrows = [obj.forceArrows arrowStruct];
        end
    end

    methods (Access=private)
        function drawCoordinate(self,pos,rot)
            % draw the coordinate frame of the body
                % pos : position of the body
                % rot : rotation of body
            frame = TranslateAndRotate(pos,rot,...
                                       CoordSys2D(0.5,0.2,pi/4));
            plot(frame(1,:),frame(2,:),"Color",'b','LineWidth',1.5);
            text(frame(1,2)+0.05,frame(2,2)+0.05,'\xi','FontSize',self.options.fontSize)
            text(frame(1,6)+0.05,frame(2,6)+0.05,'\eta','FontSize',self.options.fontSize)
        end

        function pointArray = drawPoints(self,pos,rot)
            % draw each of the body's points
            pointArray = zeros(2,length(self.points));
            for i = 1:length(self.points)
                p = self.points(i);
                ploc = TranslateAndRotate(pos,rot,p.pos');
                plot(ploc(1),ploc(2),'Marker',p.Marker,'Color','black','MarkerSize',p.MarkerSize);
                if p.drawName
                    text(ploc(1)+0.05,ploc(2)+0.05,p.name,'FontSize',self.options.fontSize)
                end
                pointArray(:,i) = ploc; % save point for return
            end
        end

        function drawArrows(self,n,q) % a bit messy, could clean up arrow struct a bit?
            % Draw each of the arrows
            for i = 1:length(self.forceArrows)
                arrow = self.forceArrows(i);
                if ~isempty(arrow.pInd) % use point's position
                    pos = TranslateAndRotate(q(1,1:2)',q(3),self.points(arrow.pInd).pos');
                    %pos = q(1,1:2)'+self.points(arrow.pInd).pos;
                else % use specified position, not implemented yet
                    error("Not implemented error")
                end
                % rotation
                if arrow.rotStatic; rot = arrow.rot(1); else rot = arrow.rot(n); end
                if arrow.rotLocal; rot = rot + q(3); end
                % force
                if arrow.forceStatic; f = arrow.force(1); else f = arrow.force(n); end
                if f ~= 0 % only draw arrow if force is applied
                    pArrow = TranslateAndRotate(pos,rot,forceArrow(f*arrow.sf_length,f*arrow.sf_width));
                    plot(pArrow(1,:),pArrow(2,:),'Color',"R",'LineWidth',2);
                end
                text(pos(1)+0.5,pos(2)+1,strcat(num2str(f),"[",self.fUnit,"]"),'FontSize',self.options.fontSize);
            end
        end

        function pInd = findPoint(self,name)
            arguments
                self 
                name string
            end
            pInd = 0;
            for i = 1:length(self.points) % get index for the point
                if strcmp(self.points(i).name, name)
                    pInd = i;
                    break
                end
            end
            % alt: find(strcmp(self.points.name,name),1)
            if pInd == 0
                error("Point %s not found",name)
            end
        end
    end
end

% helper functions
function f = TranslateAndRotate(r, phi, body)
% TranslateAndRotate(r, A, body)
% r    = [x;y] position of center of mass in global coordinates
% phi  = rotation of the body in radians
% body = [[x;y], [x;y],....] body points in local coordinates
b = [cos(phi), -sin(phi);sin(phi), cos(phi)]*body;
f = [r(1,1)+b(1,:);r(2,1)+b(2,:)];
end

function M = CoordSys2D(la,lt,va)
% CoordSys2D(la,lt,va)
% Creates a two dimensional coordinate systposem
% la  = length of arrow
% lt  = length of arrow tip
% va  = angle for arrow tip in radians
M = [[la+lt*cos(pi-va),lt*sin(pi-va)]',...
    [la,0]',...
    [la+lt*cos(pi+va),lt*sin(pi+va)]',...
    [la,0]',...
    [0,0]',...
    [0,la]',...
    [lt*cos(3*pi/2-va),la+lt*sin(3*pi/2-va)]',...
    [0,la]',...
    [lt*cos(3*pi/2+va),la+lt*sin(3*pi/2+va)]'];
end

function M = forceArrow(l,w)
% create a force arrow
% l = length of arrow stem
% w = thickness of arrow
    %M = [[0;r],[l;r],[l;w],[l*2;0],[l;-w],[l;-r],[0;-r],[0;r]];
    % somewhat nice looking arrow:
    M = [[0;0],[-0.4;0.4],[-0.4;0.2],[-1;0.2],[-1;-0.2],[-0.4;-0.2],[-0.4;-0.4],[0;0]].*[l;w];
end