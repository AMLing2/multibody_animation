classdef link < matlab.mixin.SetGet
    %Object for drawing a link between two shape object points
    properties (SetAccess = private)
        cellInd % indexes points to shape objects
        pointInd % indexes to points within shape's specific point output
        style % 'line', 'spring', 'damper', 'spring-damper' anything else relevant?
        options = struct('L_end',0,... % initialize struct with empty options
                         'Ncoils',0,...
                         'width_spring', 0,...
                         'L_pist',0,...
                         'L_rod',0,...
                         'width_cyl',0,...
                         'L_cyl',0,...
                         'lineWidth',1.5,...
                         'Color',"green");
    end

    methods
        function obj = link(cellInd,pointInd,initP,style)
            % constructor
            obj.cellInd = cellInd;
            obj.pointInd = pointInd;
            obj.style = style;
            % initialize visuals for spring and dampers
            initLen = sqrt((initP(1,1)-initP(1,2))^2+(initP(2,1)-initP(2,2))^2);
            width = 0.5;
            opts = obj.options;
            switch style
                case 'spring'
                    opts.Ncoils = round(initLen*2.5);
                    opts.L_end = initLen/4;
                    opts.width_spring = width;
                case 'damper'
                    disp("not implemented")
                case 'spring-damper'
                    opts.L_end = initLen/4;
                    opts.Ncoils = round(initLen*2.5);
                    opts.width_spring = width;
                    opts.L_pist = initLen/3;
                    opts.L_rod = initLen/5;
                    opts.width_cyl = width-0.1;
                    opts.L_cyl = initLen/2.5;
            end
            % hacky workaround because MATLAB refuses to initialize options
            % struct properly when not using set.options setter
            f = fieldnames(opts);
            for i = 1:length(fieldnames(opts))
                setOptions(obj,f{i},opts.(f{i}));
            end
        end

        function setOptions(self,field,value)
            % Change visualization of links
            % field : array of options
            % value : cell of values

            % OPTIONS:
            % 'title', string : add text to the shape drawing % todo
            % 'frame', size : draw the shape's coordinate frame at the COM
            % 'lineStyle', style : change the style of the line % todo
            % 'fontSize', double : font size
            % 'Color' : line color of link
            arguments
                self 
            end
            arguments (Repeating)
                field string {mustBeMember(field,["L_end","Ncoils","width_spring","L_pist","L_rod","width_cyl","L_cyl","lineWidth","Color"])}
                value
            end
            if length(field) ~= length(value)
                error("Expected even number of options and values")
            end
            for i = 1:length(field)
                set(self,"options",struct(field{i},value{i}))
            end
        end

        function drawLink(self,cellPoints)
            % TODO: mostly placeholder, continue for rest of styles
            pos = [cellPoints{self.cellInd(1)}(:,self.pointInd(1)),...
                   cellPoints{self.cellInd(2)}(:,self.pointInd(2))]; % create [x1,x2;y1,y2] from input
            switch self.style
                case 'line'
                    f = self.line(pos);
                case 'spring'
                    f =self.spring(pos);
                case 'damper'
                    error("not implemented error");
                case 'spring-damper'
                    f = self.springDamper(pos);
            end
            plot(f(1,:),f(2,:),"LineWidth",self.options.lineWidth,"Color",self.options.Color);
        end

        % setters
        function set.options(obj,field_val)
            field = fieldnames(field_val);
            val = struct2cell(field_val);
            obj.options.(field{1}) = val{1};
        end
    end


    methods (Access = private)
        function f = line(self,pos)
            % Draw a line
                % pos : line points
            f = pos(1:2,1:2);
        end
        function f =  spring(self,pos)
            % Draw a spring
                % pos : line points
            f = SpringData(pos(:,1),pos(:,2),self.options.width_spring,...
                self.options.Ncoils,self.options.L_end);
        end
        function f = damper(self,pos) %TODO: add
            % Draw a spring
                % pos : line points
            f = DamperData(pos(:,1),pos(:,2),0.6,20,0.5);
        end
        function f = springDamper(self,pos)
            % Draw a spring-damper
                % pos : line points
            f = SpringDamperData(pos(:,1),pos(:,2),self.options.width_spring,...
                self.options.Ncoils,self.options.L_end,self.options.width_spring,...
                self.options.L_pist,self.options.L_rod,self.options.width_cyl,...
                self.options.L_cyl);
        end
    end
end

function f = SpringData(P1, P2, Width,Ncoil,L_end)
% f = SpringData(P1, P2, Width,Ncoil)
% P1    = [x;y] starting point
% P2    = [x;y] end point
% Width = width of spring
% Ncoil = number of coils in the spring
% L_end = length from end to start of coil
v = P2 - P1;
lv = norm(v);
Lcoil = (lv-2*L_end)/Ncoil;
theta = atan2(Width/2,Lcoil/4);
if (lv>2*L_end)
    h = [[0;0], [L_end;0]];
    for i=1:Ncoil
%         h = [h, ([L_end+(i-1)*Lcoil;Width/2*[cos(theta);sin(theta)]),  ([L_end+i*Lcoil - Lcoil*3/4;0]+Width*[cos(-theta);sin(-theta)]),  ([L_end+i*Lcoil - Lcoil*1/4;0]+Width/2*[cos(theta);sin(theta)])];
        h = [h, ([L_end+(i-1+1/4)*Lcoil;Width/2]), [L_end+(i-1+3/4)*Lcoil;-Width/2], [L_end+i*Lcoil;0]];
    end
    h = [h, [lv;0]];
else
    h = [[0;0], [lv/2;0], [lv/2;Width/2], [lv/2;-Width/2], [lv/2;0], [lv;0]];
end
phi = atan2(v(2,1), v(1,1));
f = [cos(phi), -sin(phi);sin(phi), cos(phi)]*h;
f = [P1(1,1)+f(1,:);P1(2,1)+f(2,:)];
end

function f = SpringDamperData(P1, P2, Width,Ncoil,L_end,L1,L2,L3,L4,L5)
% f = SpringData(P1, P2, Width,Ncoil)
% P1    = [x;y] starting point
% P2    = [x;y] end point
% Width = width of spring
% Ncoil = number of coils in the spring
% L_end = length from end to start of coil
% L1    = width of spring-damper
% L2    = length of piston rod
% L3    = length of cylinder rod
% L4    = width of cylinder
% L5    = length of cylinder
v = P2 - P1;
lv = norm(v);
Lcoil = (lv-2*L_end)/Ncoil;
% theta = atan2(Width/2,Lcoil/4);
if (lv>2*L_end)
    h = [[L_end+L3+L5;L1/2+L4/2], [L_end+L3;L1/2+L4/2], [L_end+L3;L1/2-L4/2], [L_end+L3+L5;L1/2-L4/2], [L_end+L3;L1/2-L4/2], [L_end+L3;L1/2], [L_end;L1/2], [L_end;0], [0;0], [L_end;0], [L_end;-L1/2]];
    for i=1:Ncoil
        h = [h, ([L_end+(i-1+1/4)*Lcoil;Width/2-L1/2]), [L_end+(i-1+3/4)*Lcoil;-Width/2-L1/2], [L_end+i*Lcoil;-L1/2]];
    end
    h = [h, [lv-L_end;0], [lv-L_end;L1/2], [lv-L_end-L2;L1/2], [lv-L_end-L2;L1/2+0.7*L4/2], [lv-L_end-L2;L1/2-0.7*L4/2], [lv-L_end-L2;L1/2], [lv-L_end;L1/2], [lv-L_end;0],           [lv;0]];
else
    h = [[0;0], [lv/2;0], [lv/2;Width/2], [lv/2;-Width/2], [lv/2;0], [lv;0]];
end
phi = atan2(v(2,1), v(1,1));
f = [cos(phi), -sin(phi);sin(phi), cos(phi)]*h;
f = [P1(1,1)+f(1,:);P1(2,1)+f(2,:)];
end