# multibody_animation

## USAGE:

clone with git:
```bash
git clone https://github.com/AMLing2/multibody_animation.git
```
Add to MATLAB path:
how

## USING THE LIBRARY:
An animation scene is created through the *animation* class which allows creating shapes and linking them to a position array from earlier simulation data or real-time data, points can be created on each shape which can be visually linked together by a simple line, springs, dampers, etc. Once the scene is created, an animation can be displayed from the position data of each shape, or the current frame can be drawn for real-time data after updating the postion of each shape.
### Animation class
```MATLAB
animation(coordPos)
% usage
a = animation();
```
Instantiate and return an *animation* object\
coordPos - (1,2) double (optional) : Set the world coordinate frame, (0,0) by default. 


#### Functions:
---
##### General
###### animate
```MATLAB
animate(t_vec,t_pause,skip,func)
```
Animate the specified scene. A new figure is created using the axis defined through *setOptions*.\
t_vec - \[s\] : Time vector for the scene\
t_pause - \[s\] (optional): Length of time to pause between each frame\
skip - integer (optional): Number of frames to skip to speed up display at low timesteps\
func - function handle (optional): Evaluate a user-defined function each frame, the current frame is input to the function argument

###### drawFrame
```MATLAB
drawFrame(n,func)
```
Draw a specified frame on the current figure. Useful for real-time visualization using a shape's *set_q* function to update the position and rotation. The figure's axis must be set manually.\
n - (optional): Frame and related q_link variables to draw, defaults to the first frame\
func - function handle (optional): Evaluate a user-defined function, the current frame is input to the function argument

###### setOptions
```MATLAB
setOptions(field1,value1,...)
% usage example
a.setOptions('axis', [-10 10 -10 10]); % set the axis of the animation plot
```
Set options of the scene, available options:\
'axis' : axis of the plot\
... TODO i guess
###### linkPoints
```MATLAB
linkPoints(objPoint1,objPoint2,style)
```
Visually link two shape points together, returns a *link* object. This is explained further in the **Link class** section.\
objPoint1 : Reference to the first shape's point.\
objPoint2 : Reference to the second shape's point.\
style - string : style of the link, one of:
- "line" : simple line.
- "spring"
- "damper"
- "spring-damper"

---
##### Creating shapes
These functions return a *Shape* object and require a position vector for the *q_link* argument, describing the position and rotation of the shape in each timestep in the format:\
\[x1,y1,phi1;\
x2,y2,phi2;\
...\]\
Where phi is in radians.
###### createSquare
*createSquare(q_link, size)* \
Create a square.\
size : Length of each side of the square.
###### createRect
```MATLAB
createRect(q_link,top,bottom,left,right)
```
Create a rectangle through the distances from each side to the local frame.\
top : Length to the top side\
bottom : Length to the bottom side\
left : Length to the left side\
right : Length to the right side
###### createCircle
```MATLAB
createCircle(q_link,r,offset,corners)
```
CLEAN UP THIS FUNCTION\
Create a circle.\
r : Radius\
offset (optional) : offset of the local coordinate frame\
corners (optional) : number of corners on the circle
###### createTurtleGraphics
```MATLAB
createTurtleGraphics(q_link,start,t)
% usage example - creating a triangle with the local frame on the bottom left corner
start = [0,0];
turt = [0,1,120,1,120,1] % TODO: check if this actually works....
a.createTurtleGraphics(q_link,start,turt);
```
Create a shape using [turtle graphics](https://en.wikipedia.org/wiki/Turtle_graphics#/media/File:Turtle-animation.gif).\
start : Starting coordinate of the pen.\
t : turtle graphics vector in the form \[angle, length, angle, length, ...\] where the angle is in degrees.
###### createSupport
```MATLAB
createSupport(pos,rot,size)
```
Create a fixed pin support.\
pos : Position of the support in the global frame.\
rot \[deg\] : Rotation of the support.\
size : size of the support.
###### createLine
```MATLAB
createLine(points,n,d)
```
Create a static line in the scene, optionally with ground lines.\
points : Start and end points in the format \[x1,x2;y1,y2\].\
n (optional) : Number of ground lines, disabled by default.\
d (optional) : Length/size of ground lines.
###### createCustom
```MATLAB
createCustom(q_link,points)
```
Create a custom shape with user defined points. Input an empty array with [] to prevent drawing a shape, which can be useful for points or lines which are not connected to a body.\
points : Corner points of the shape in the format \[x1,x2,...,xn; y1,y2,...,yn\].

#### Members:
##### shapes
Array of the created *shape* objects, index is by order of creation.
##### options
Options struct of the scene, modify through *setOptions*.
##### coordPos
Coordinate position of the global frame, set through the constructor.
##### links
Array of the created *link* objects, index is by order of creation.

---
### Shape class
The shape class allows adding points, creating holes, and setting the options of a shape which is returned by a shape creating function in the *animation* class.
#### Functions:
---
##### General
###### setOptions
```MATLAB
```MATLAB
setOptions(field1,value1,...)
```
Set options of the shape, available options:\
'drawFrame', logical : Draw the shape's coordinate frame.\
'fontSize', double : Font size\
'FaceColor', string or [r,g,b] vector : Color of face of polygon\
'EdgeColor', string or [r,g,b] vector : Color of edge of polygon\
'LineStyle', string : Line style of polygon edges and lines\
'LineWidth', double : Width of polygon edges and lines\
'FaceAlpha', double : Alpha of body face (transparency)
###### addPoint
```MATLAB
addPoint(pos,name,MarkerSize,Marker,drawName)
```
Add a point to the shape.\
pos : Position of the point relative to the local frame.\
name - string : Name of the point.\
MarkerSize (optional) : size of the point marker.\
Marker - string (optional): Marker of the point, see [linespec](https://www.mathworks.com/help/matlab/creating_plots/specify-line-and-marker-appearance-in-plots.html) of MATLAB's plot() function.\
drawName - logical (optional): draw the name of the point on the scene, enabled by default.
###### point
```MATLAB
point(name)
```
Return a reference of the point for use in visually linking together points with *linkPoints*.\
name - string : name of the point set in the *addPoint* function.
###### setStatic
```MATLAB
setStatic(flag)
```
Set the shape as a static/non-moving shape, using only the first entry in *q_link* for the display.\
flag - logical : Set or disable the shape movement.
###### drawBody
```MATLAB
pointArray = drawBody(n)
```
Draw the shape on the current figure, this function is used during the main animation loop.\
n : index in q_vec position vector.
###### set_q
```MATLAB
set_q(q_vec)
```
Update the *q_link* position and rotation vector of the body, useful for real-time visualization. The input q_vec can be of size 1x3 for the current position from for example the data from an IMU sensor, and drawn with the animation class' *drawFrame(1)*.\
q_vec : New q_link postion vector

---
##### Visual
###### createSlot
```MATLAB
createSlot(pos,phi,L,r)
```
Create a slot hole in the shape by specifying a starting point, direction and length.\
pos - (1,2) : starting point of the slot.\
phi : \[deg\] angle of the slot.\
L : length of the slot.\
r : radius of corner fillets / half thickness of slot.
###### createHole
```MATLAB
createHole(points)
```
Create a custom shaped hole based on points, similar to *createCustom* for shapes.\
points : Points of the shape in the format \[x1,x2,...,xn; y1,y2,...,yn\].
###### forceArrowPoint
```MATLAB
forceArrowPoint(pName,rot,force,frame,sf_width,sf_length)
```
Add a static or dynamic force arrow on a point, where the direction can be set relative to the global or the shape's local frame.\
pName - string : Name of a point on the same shape set in *addPoint*\
rot - double or array : The rotation of the force.\
force - double or array : Constant force or a force each frame. Changes the size of the arrow.\
frame - 'global' or 'local' : The reference frame to base the roation of the arrow.\
sf_width - (optional) : Scale factor on the width based on the force.\
sf_length - (optional) : Scale factor on the length based on the force.
###### solidLine
```MATLAB
solidLine(pos,n,d) % change pos to points for consistency with createLine
```
Create a line with optional ground lines on the shape.\
pos : Start and end points in the format \[x1,x2;y1,y2\].\
n (optional) : Number of ground lines, disabled by default.\
d (optional) : Length/size of ground lines.

#### Members
##### q_vec
Link to position x,y & rotation [x;y;phi] matrix, phi is in radians, set through *set_q* or in the constructor.
##### body
Polysshape of the body.
##### lines
Optional line to draw
##### forceArrows
Array of forceArrows struct
##### points
Array of points struct of body
##### options
Options struct
##### staticFlag
Static drawing of the shape.
##### fUnit
Defaults to "kN", used for force arrows. TODO move to options

---

### Link class
Create links (lines, dampers, springs, etc) between shape points. Create through an *animation* object's *linkPoints* function, using *shape* object's *point* function for referencing created points:
```MATLAB
a.linkPoints(objPoint1,objPoint2,style)
% usage:
circShape = a.createCircle(...)
squareShape = a.createSquare(...)
circShape.addPoint([1,1],"A")
squareShape.addPoint([0,0],"B")
spring_AB = a.linkPoints(circShape.point("A"),squareShape.point("B"),"spring")
```
The visualization of the links are initialized based on the distance between the two points at timestep = 0, but can be changed manually.
#### Functions:

##### setOptions
```MATLAB
setOptions(field1,value1,...)
% usage example
a.setOptions('axis', [-10 10 -10 10]); % set the axis of the animation plot
```
Set visual options of the link, available options:\
'L_end' : Length from end to start of coil\
'Ncoils' : Number of coils on spring\
'width_spring' : Width of the spring\
'L_pist' : Length of damper piston\
'L_rod' : Length of rod on damper piston\
'width_cyl' : Width of the piston cylinder\
'L_cyl' : Length of the cylinder on the damper piston\
'lineWidth' : Width of the lines\
'Color', string or [r,g,b] vector : Color of lines

