# multibody_animation

## USAGE:

clone with git:
```bash
git clone https://github.com/AMLing2/multibody_animation.git
```
Add to MATLAB path:
how

## USING THE LIBRARY:
An animation scene is created through the *animation* class which allows creating shapes and linking them to a position array, points can be created on each shape which can be visually linked together by a simple line, springs, dampers, etc.
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
animate(t_vec,t_pause,skip)
```
Animate the specified scene\
t_vec - \[s\] : Time vector for the scene\
t_pause - \[s\] (optional): Length of time to pause between each frame\
skip - integer (optional): Number of frames to skip to speed up display
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
Link two shape points together, returns a *link* object. This is explained further in the **Link class** section.\
objPoint1 : Reference to the first shape's point.
objPoint2 : Reference to the second shape's point.
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
Create a custom shape with user defined points.\
points : Points of the shape in the format \[x1,x2,...,xn; y1,y2,...,yn\].

---
### Shape class
The shape class allows adding points, creating holes, and setting the options of a shape which is returned by a shape creating function in the *animation* class.
#### Functions:
---
##### General
###### setOptions
```MATLAB
setOptions(field1,value1,...)
```
Set options to a shape, available options:\
- im not even sure what the options are yet... TODO
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
Return a reference of the point for use in visually linking together points.\
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
###### solidLine
```MATLAB
solidLine(pos,n,d) % change pos to points for consistency with createLine
```
Create a line with optional ground lines on the shape.\
pos : Start and end points in the format \[x1,x2;y1,y2\].\
n (optional) : Number of ground lines, disabled by default.\
d (optional) : Length/size of ground lines.

### Link class
Create links (lines, dampers, springs, etc) between shape points. Create through an *animation* object's *linkPoints* function, using *shape* object's *point* function for referencing created points:
```MATLAB
a.linkPoints(objPoint1,objPoint2,style)
% usage:
circShape = a.createCircle(...)
squareShape = a.createSquare(...)
circShape.addPoint([1,1],"A")
squareShapeShape.addPoint([0,0],"B")
spring_AB = a.linkPoints(circShape.point("A"),squareShape.point("B"),"spring")
```
The visualisation of the links are initialized based on the distance between the two points at timestep = 0, but can be changed manually.
#### Functions:
###### setOptions
TODO


