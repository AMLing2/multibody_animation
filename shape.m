classdef shape
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
            obj.body = body;
        end

        function createHole(points)
            % Create a hole in the body for drawing
            %   Detailed explanation goes here
            
        end

        function drawBody(self,n)
            % draw the body on the current figure
                % n : index in q_vec position vector
            % rotate and translate points
            q = self.q_vec(n,:);
            np = translateAndRotate(self.body,q);
            % np = self.body
            plot(np(1,:),np(2,:))
        end

        function setOptions(opts)
            % Set additional items to draw
            % OPTIONS:
            % 'title', string : add text to the shape drawing
            % 'coordinate', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line

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