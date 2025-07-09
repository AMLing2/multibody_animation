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
            shapeObj = shape(q_link,points);
            set(self,'shapes', shapeObj);
        end

        function animate(self,t_vec)
            % Draw animation from shapes based on a time vector
            figure
            hold on
            for n = 1:length(t_vec)
                cla
                for i = 1:length(self.shapes)
                    self.shapes(i).drawBody(n);
                end
                pause(0.5);
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