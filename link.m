classdef link
    %Object for drawing a link between two shape object points
    properties (SetAccess = private)
        cellInd % indexes points to shape objects
        pointInd % indexes to points within shape's specific point output
        style % 'line', 'spring', 'damper', 'spring-damper' anything else relevant?
        options % TODO: draw length, draw other stuff?
    end

    methods
        function obj = link(cellInd,pointInd,style)
            % constructor
            obj.cellInd = cellInd;
            obj.pointInd = pointInd;
            obj.style = style;
        end

        function drawLink(self,cellPoints)
            % TODO: mostly placeholder, continue for rest of styles
            pos = [cellPoints{self.cellInd(1)}(:,self.pointInd(1)),...
                   cellPoints{self.cellInd(2)}(:,self.pointInd(2))]; % create [x1,x2;y1,y2] from input
            switch self.style
                case 'line'
                    self.line(pos);
            end
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    methods (Access = private)
        function line(self,pos)
            % Draw a line
                % pos : line points
            plot(pos(1,1:2),pos(2,1:2));
        end
    end
end