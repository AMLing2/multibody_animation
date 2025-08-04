classdef animation < matlab.mixin.SetGet
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = private)
        shapes % array of shape objects
        options
        coordPos
        links % array of link objects
    end

    methods
        function obj = animation(coordPos)
            % Constructor
            arguments
                coordPos (1,2) double = [0.0,0.0]
            end
            obj.coordPos = coordPos;
            %initialize options
            obj.options.axis = [-8.0 2 -4.0 6.0];
        end

        function shapeObj = createSquare(self,q_link,size)
            % Create a square, returns a shape object 
            s = size/2;
            points = [[s;s],... % [x;y]
                      [s;-s],...
                      [-s;-s],...
                      [-s;s],...
                      [s;s]];
            shapeObj = self.createCustom(q_link,points);
        end

        function shapeObj = createRect(self,q_link,top,bottom,left,right)
            % Create a rectangle
            points = [[right;top],... % [x;y]
                      [right;-bottom],...
                      [-left;-bottom],...
                      [-left;top]];
            shapeObj = self.createCustom(q_link,points);
        end

        function shapeObj = createCircle(self,q_link, r, varargin)
            % Create a circle, returns a shape object 
                % r : radius of circle
                % offset : center offset
            switch nargin
                case 3
                    corners = 25;
                    offset = 0;
                case 4
                    corners = varargin{1};
                    offset = 0;
                case 5
                    corners = varargin{1};
                    offset = varargin{2};
            end
            t = linspace(0,2*pi-(2*pi/corners),corners);
            points = [r*cos(t);r*sin(t)];
            points = points + offset;
            shapeObj = self.createCustom(q_link,points);
        end

        function shapeObj = createTurtleGraphics(self,q_link, start, t)
            % Create a shape from turtle graphics
                % q_link
                % start : [x;y] start point for pen 
                % t : turtle graphics list [angle, length, angle, length...] angle in degrees
            arguments
                self 
                q_link 
                start (2,1) double
                t (1,:) double
            end
            if mod(length(t),2)
                error("Turtle array length must be even")
            end
            points = zeros(2,length(t)/2);
            points(:,1) = start;
            theta = 0;
            for i = 1:1:length(t)/2
                theta = theta + t(i*2-1);
                len = t(i*2);
                points(:,i+1) = points(:,i)+[cosd(theta)*len;
                                             sind(theta)*len];
            end
            shapeObj = self.createCustom(q_link,points);
        end

        function suppObj = createSupport(self,pos,rot,size)
            % create a support
                % pos : position of support [x,y]
                % rot : [deg] rotation
                % size : size of support
                arguments
                    self 
                    pos (2,1) = [0;0]
                    rot = 0
                    size = 1
                end
            q_vec = [pos', deg2rad(rot)];
            r = size*0.3; % radius of top section
            theta = 65; % angle of top of support
            phi = 180-theta; % angle of lower side of support
            midsec = 2*(r + cosd(theta)*size);
            h = sind(theta)*size-r/2.7; % TODO: make not hardcoded..

            supStart = [0;r]; % start on top, go cw
            support = [turtArc(r,-theta,10),0.001,size,-phi,midsec,-phi,size,turtArc(r,-theta,10)];
            suppObj = self.createTurtleGraphics(q_vec,supStart,support);
            suppObj.setStatic(true);
            
            suppObj.solidLine([-midsec/2,midsec/2;-h,-h],5,size/3)
            suppObj.setOptions('drawFrame',false,'FaceColor',"none")
        end

        function shapeObj = createLine(self,points,n,d)
            % draw a static line
                % points : [x1,x2;y1,y2] of line
                % n : number of ground lines, set to 0 to draw none
                % d : length of ground lines
            q = [0,0,0];
            shapeObj = self.createCustom(q,[]);
            shapeObj.setStatic(true);
            shapeObj.solidLine(points,n,d);
            shapeObj.setOptions('drawFrame',false);
        end

        function shapeObj = createGear(self)
            % create a gear shape TODO
        end

        function linkObj = linkPoints(self,objPoint1,objPoint2,style)
            % create a link between two shape object's points, returns link object
                % objPoint1 : a point on the first shape object
                % objPoint2 : a point on the second shape object
                % style : style of link, one of hte following:
                    % 'line'
                    % 'spring'
                    % 'damper'
                    % 'spring-damper'
            
            % Find indexes to referenced shape objects:
            arguments
                self 
                objPoint1 
                objPoint2 
                style string {mustBeMember(style,["line","spring","damper","spring-damper"])}
            end
            shapeIndexes = [find(eq(self.shapes,objPoint1.obj)),...
                            find(eq(self.shapes,objPoint2.obj))];
            linkObj = link(shapeIndexes,...
                           [objPoint1.index, objPoint2.index],...
                           [objPoint1.init,objPoint2.init],style);
            set(self,'links',linkObj);
        end

        function shapeObj = createCustom(self,q_link,points)
            % Create a custom shape with specified line points
            shapeObj = shape(q_link,points);
            set(self,'shapes', shapeObj);
        end

        function animate(self,t_vec,t_pause,skip,func)
            % Draw animation from shapes based on a time vector
                % t_vec : time vector
                % t_pause : time paused between frames
                % skip : number of frames to skip
                % func : apply a function each frame
            arguments
                self 
                t_vec 
                t_pause double = 0.01 % [s]
                skip = 20
                func = [] 
            end
            if ~isa(func,"function_handle") & ~isempty(func) % cant use [] in place of function_handle
                error("Expected a function handle")
            end
            figure
            axis equal
            hold on
            axis(self.options.axis)
            for n = 1:skip:length(t_vec)
                self.drawFrame(n,func);
                title(['t = ',num2str(t_vec(n))])
                pause(t_pause);
            end
        end

        function drawFrame(self, n, func)
        % draw a singular frame on the current figure
            %n : desired frame, defaults to 1
            % func : function handle to evaluate during the frame
            arguments
                self 
                n = 1
                func = [] 
            end
            pointPos = cell(1,length(self.shapes));
            cla
            drawCoordinate(self,self.coordPos',0)
            % draw shapes
            for i = 1:length(self.shapes)
                pointPos{i} = self.shapes(i).drawBody(n);
            end
            % draw links
            for i = 1:length(self.links)
                self.links(i).drawLink(pointPos);
            end
            if ~isempty(func)
                func(n);
            end
        end

        function setOptions(self,field,value)
            % Set additional items to draw
            % OPTIONS:
            % 'title', string : add text to the shape drawing % todo
            % 'frame', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line % todo
            arguments
                self 
            end
            arguments (Repeating)
                field string {mustBeMember(field,["axis"])}
                value
            end
            if length(field) ~= length(value)
                error("Expected even number of options and values")
            end
            for i = 1:length(field)
                set(self,"options",struct(field{i},value{i}))
            end
        end

    % setters
        function set.shapes(obj,newShape)
            obj.shapes = [obj.shapes newShape];
        end
        function set.links(obj,newLink)
            obj.links = [obj.links newLink];
        end
        function set.options(obj,field_val)
            field = fieldnames(field_val);
            val = struct2cell(field_val);
            obj.options.(field{1}) = val{1};
        end
    end

    methods (Access=private)
        function pLen = initLinks(self)
            % initialize the animation scene if using links % REMOVE?
            p_indexes = [];
            for i = 1:length(self.shapes)
                p_indexes = [p_indexes, length(self.shapes(i).points)];
            end
            pLen = sum(p_indexes);
        end
        function drawCoordinate(self,pos,rot)
            % draw the coordinate frame of the body
                % pos : position of the body
                % rot : rotation of body
            frame = TranslateAndRotate(pos,rot,...
                                       CoordSys2D(0.8,0.2,pi/4));
            plot(frame(1,:),frame(2,:),"Color",'b','LineWidth',1.5);
            text(frame(1,2)+0.05,frame(2,2)+0.05,'x','FontSize',18)
            text(frame(1,6)+0.05,frame(2,6)+0.05,'y','FontSize',18)
        end
    end
end

% helper functions
function arc = turtArc(r,phi,n)
    % Create an arc for turtle graphics
        % r : radius of arc
        % phi : angle of arc from start, set to negative for cw arc
        % n : number of segments
    tot_len = r*deg2rad(abs(phi));
    b = tot_len/n;
    % b = b/2;
    theta = (90-acosd((b^2)/(b*r))) * sign(phi); % law of cosines /(2*b*r)
    arc = [0.001 b zeros(1,n*2)];
    for i = 3:2:n*2+2
        arc(i) = theta;
        arc(i+1) = b;
    end
end

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