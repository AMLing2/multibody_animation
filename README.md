# multibody_animation

## USAGE:

clone with git:
```bash
git clone https://github.com/AMLing2/multibody_animation.git
```
Add to MATLAB path:
how

## USING THE LIBRARY:
An animation scene is created through the *animation* class which allows creating shapes and linking them to a pre-generated position array, where points can be created on each shape which can be linked together with for example springs.
### Animation class
```MATLAB
animation(coordPos)
% usage
a = animation();
```
Instantiate and return an *animation* object\
coordPos - (1,2) double (optional) : Set the world coordinate frame, (0,0) by default. 
#### Functions:
##### General
---
```MATLAB
animate(t_vec,t_pause,skip)
```
Animate the specified scene\
t_vec - \[s\] : Time vector for the scene\
t_pause - \[s\] (optional): Length of time to pause between each frame\
skip - integer (optional): Number of frames to skip to speed up display\
```MATLAB
setOptions(field1,value1,...)
% usage example
a.setOptions('axis', [-10 10 -10 10]); % set the axis of the animation plot
```
Set options of the scene, available options:\
'axis' : axis of the plot\
... TODO i guess\
##### Creating shapes
---
These functions return a *Shape* object and require a position vector for the q_link argument, describing the position and rotation of the shape in each timestep in the format:
\[x1,y1,phi1;\
x2,y2,phi2;\
...\]\
Where phi is in radians.
```MATLAB
createSquare(q_link,size)
```
Create a square.\
size : Length of each side of the square.
```MATLAB
createRect(q_link,top,bottom,left,right)
```
Create a rectangle through the distances from each side to the local frame.\
top : Length to the top side\
bottom : Length to the bottom side\
left : Length to the left side\
right : Length to the right side
```MATLAB
createCircle(q_link,r,offset,corners)
```
CLEAN UP THIS FUNCTION\
Create a circle.\
r : Radius\
offset (optional) : offset of the local coordinate frame\
corners (optional) : number of corners on the circle
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
```MATLAB
createSupport(pos,rot,size)
```
Create a fixed pin support.\
pos : Position of the support in the global frame.\
rot \[deg\] : Rotation of the support.\
size : size of the support.\
```MATLAB
createLine(points,n,d)
```
Create a static line in the scene, optionally with ground lines.
points : Start and end points in the format \[x1,x2;y1,y2\].\
n (optional) : Number of ground lines, disabled by default.\
d (optional) : Length/size of ground lines.
```MATLAB
createCustom(q_link,points)
```
Create a custom shape with user defined points.\
points : Points of the shape in the format \[x1,x2,...,xn; y1,y2,...,yn\].

---
### Shape class
The shape class allows adding points, creating holes, and setting the options of a shape.
#### Functions:
##### General
---
```MATLAB
setOptions(field1,value1,...)
```
Set options to a shape, available options:\
- im not even sure what the options are yet... TODO
```MATLAB
addPoint(pos,name,MarkerSize,Marker,drawName)
```
Add a point to the shape.\
pos : Position of the point relative to the local frame.\
name - string : Name of the point.\
MarkerSize (optional) : size of the point marker.\
Marker - string (optional): Marker of the point, see [linespec](https://www.mathworks.com/help/matlab/creating_plots/specify-line-and-marker-appearance-in-plots.html) of MATLAB's plot() function.\
drawName - logical (optional): draw the name of the point on the scene, enabled by default.\
```MATLAB
point(name)
```
Return a reference of the point for use in visually linking together points.\
name - string : name of the point set in the *addPoint* function.
```MATLAB
setStatic(flag)
```
Set the shape as a static/non-moving shape, using only the first entry in *q_link* for the display.\
flag - logical : Set or disable the shape movement.
##### Visual
---

### Link class & creating links between shape points
