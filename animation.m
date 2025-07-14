classdef animation < matlab.mixin.SetGet
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = private)
        shapes % array of shape objects
    end

    methods
        % function obj = animation()
        %     % Constructor
        %     %   Detailed explanation goes here
        %     obj.shapes = inputArg1 + inputArg2;
        % end

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

        function shapeObj = createCirc(self,q_link, r, varargin)
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
            q_vec = [pos', rot];
            r = size*0.3; % radius of top section
            theta = 65; % angle of top of support
            phi = 180-theta; % angle of lower side of support
            midsec = 2*(r + cosd(theta)*size);
            h = sind(theta)*size-r/2.7; % TODO: make not hardcoded..

            supStart = [0;r]; % start on top, go cw
            support = [turtArc(r,-theta,10),0.001,size,-phi,midsec,-phi,size,turtArc(r,-theta,10)];
            suppObj = self.createTurtleGraphics(q_vec,supStart,support);
            suppObj.setStatic(true);
            
            suppObj.solidLine([-midsec/2,midsec/2;-h,-h],10,size/4)
        end

        function shapeObj = createCustom(self,q_link,points)
            % Create a custom shape with specified line points
            shapeObj = shape(q_link,points);
            set(self,'shapes', shapeObj);
        end

        function animate(self,t_vec,varargin)
            % Draw animation from shapes based on a time vector
            if nargin < 3
                t_pause = 0.01;
            else
                t_pause = varargin{1};
            end
            figure
            axis equal
            hold on
            for n = 1:length(t_vec)
                cla
                for i = 1:length(self.shapes)
                    self.shapes(i).drawBody(n);
                end
                pause(t_pause);
            end
        end

    % setters
        function set.shapes(obj,newShape)
            obj.shapes = [obj.shapes newShape];
        end

    end
    methods (Access = private)

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