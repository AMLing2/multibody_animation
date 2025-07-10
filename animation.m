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