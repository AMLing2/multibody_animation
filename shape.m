classdef shape < matlab.mixin.SetGet
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        q_vec % link to position x,y & rotation, phi [x;y;phi] matrix
        body % outline of body
        lines = []
        options
        staticFlag = false
    end

    methods
        function obj = shape(q_vec,body) % constructor
            % Construct an instance of a shape class
            obj.q_vec = q_vec;
            % obj.body = body;
            obj.body = polyshape(body(1,:),body(2,:));
            % initialize options struct
            obj.options.drawFrame = true;
        end

        function createHole(self,points)
            % Create a hole in the body
                % points : verteces if hole
            newBody = addboundary(self.body,points(1,:),points(2,:));
            set(self,'body', newBody);
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

        function addPoint(self,style)

        end

        function drawBody(self,n)
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
            if self.options.drawFrame
                drawCoordinate(self,q(1:2)',q(3))
            end
        end

        function setStatic(self,flag)
            arguments
                self 
                flag logical
            end
            set(self,'staticFlag',flag)
        end

        function setOptions(self,fields,values)
            % Set additional items to draw
            % OPTIONS:
            % 'title', string : add text to the shape drawing % todo
            % 'frame', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line % todo
            arguments
                self 
                fields (1,:) string
                values (1,:)
            end
            if length(fields) ~= length(values)
                error("Length of option arrays must be equal")
            end
            for i = 1:length(fields)
                set(self,"options",struct(fields(i),values(i)))
            end
        end
        % setters
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
    end

    methods (Access=private)
        function drawCoordinate(self,pos,rot)
            % draw the coordinate frame of the body
                % pos : position of the body
                % rot : rotation of body
            frame = TranslateAndRotate(pos,rot,...
                                       CoordSys2D(0.5,0.2,pi/4));
            plot(frame(1,:),frame(2,:),"Color",'b');
            text(frame(1,2)+0.05,frame(2,2)+0.05,'\xi','FontSize',18)
            text(frame(1,6)+0.05,frame(2,6)+0.05,'\eta','FontSize',18)
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
% Creates a two dimensional coordinate system
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