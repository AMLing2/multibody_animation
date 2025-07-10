classdef shape < matlab.mixin.SetGet
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        q_vec % link to position x,y & rotation, phi [x;y;phi] matrix
        body % outline of body
        points
        options
    end

    methods
        function obj = shape(q_vec,body)
            % Construct an instance of a shape class
            obj.q_vec = q_vec;
            % obj.body = body;
            obj.body = polyshape(body(1,:),body(2,:));
        end

        function createHole(self,points)
            % Create a hole in the body
                % points : verteces if hole
            newBody = addboundary(self.body,points(1,:),points(2,:));
            set(self,'body', newBody);
        end

        function drawBody(self,n)
            % draw the body on the current figure
                % n : index in q_vec position vector
            % rotate and translate points
            q = self.q_vec(n,:);
            pgon = rotate(self.body,rad2deg(q(3)));
            pgon = translate(pgon,q(1:2));
            % np = self.body
            % plot(np(1,:),np(2,:))
            plot(pgon)
        end

        function setOptions(opts)
            % Set additional items to draw
            % OPTIONS:
            % 'title', string : add text to the shape drawing
            % 'coordinate', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line

        end
        % setters
        function set.body(obj,newBody)
            obj.body = newBody;
        end
    end
end

% helper functions
function newBody = translateAndRotate(body,q)
    r = q(1,1:2)';
    phi = q(1,3)';
    b = [cos(phi), -sin(phi);sin(phi), cos(phi)]*body;
    newBody = [r(1,1)+b(1,:);r(2,1)+b(2,:)];
end