# multibody_animation

## USAGE:

clone with git:
```bash
git clone https://github.com/AMLing2/multibody_animation.git
```
Add to MATLAB path:
how

[Link to documentation](url) 

TODO:
- force arrows on shapes (pos,dir,force,scalefac_width,scalefactor_length)
    - done for points
- some way to do belts/ropes on moving shapes
    - point which ignores shape's orientation but instead uses a moving dir vector?
    - Alternatively a point where the user can specify the local pos each frame
- option to switch from x,y to other frames
- drawing single frame with specified q_link for each shape for realtime drawing
- more rotational objects such as rotational springs, dampers, gears etc
- need to add dampers to link class
- split link class visuals into each of their own class?
- optimisations, most important for realtime visualisation

