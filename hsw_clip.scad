include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2_utils.scad>
include <hswx.scad>

$fn=50;
generate_clipconnector = false;
generate_clip = false;
generate_clip_rect_base = false;
generate_clip_hex_base = false;

// A double clip to hold two pieces of HSW together
module hsw_clipconnector() {
  height=3;
  difference() {
    union() { // two clips with base
      hsw_clip(center=true, rotate=180, type=0, rectbase=3);
      translate([HSWX_OUTSIDE,0,0])
        hsw_clip(center=true, rotate=0, type=0, rectbase=height);
    } // carve out the stress-reliever between them to bend
    translate([HSWX_OUTSIDE/2,HSWX_INSIDE/2,height])
      rotate([90,0,0])
        cylinder(h=HSWX_INSIDE, d=height);
  }
}

plug_base_thickness = 1;
plug_base_lip = 1;
plug_stud_thickness = 1.7;
plug_stud_height = HSWX_LOCK_DEPTH-2;
plug_spring_base = 3;
plug_spring_depth = 5;
plug_spring_thickness = 1.4;

/* a simple, uninteresting clip made of rectangles. testing only, won't work as a clip
module hsw_clip0() {
  clip_points = [
[              0,                        0 ],     // origin
[              0,               HSWX_DEPTH ],     // strong-side base
[    HSWX_INSIDE,               HSWX_DEPTH ],     // strong lock
[    HSWX_INSIDE,                        0 ],     //                    HSWX_DEPTH ],
[ HSWX_INSIDE-plug_stud_thickness,  0 ],
[ HSWX_INSIDE-plug_stud_thickness, plug_spring_depth ],
[ plug_stud_thickness, plug_spring_depth ],
[ plug_stud_thickness,              0 ],

];
  rotate([-90,0,0])
    linear_extrude(HSWX_INSIDE/2)
  polygon(clip_points);
}*/

module hsw_clip(
  center=false, // center or start from [0,0,0]
  rotate=0,     // rotate result
  type=0,       // type not used -- may someday specify weak v. strong directional
  hexbase=0,    // put a hexbase on top and give it a height
  rectbase=0 )  // put a rectangular base on top and give it a height
{
outline = [ [
[ -plug_base_lip,                             0 ],
[              0,                             0, 0.1 ],   // origin
[              0,               HSWX_LOCK_DEPTH ],   // strong-side base
[ -HSWX_LOCK_LIP, HSWX_LOCK_LIP+HSWX_LOCK_DEPTH, 0.5 ],   // strong lock

[ -HSWX_LOCK_LIP,                    HSWX_DEPTH, 1.5 ],

[ plug_stud_thickness,               HSWX_DEPTH ],   // spring
[ plug_spring_base,                  HSWX_DEPTH,   3.5 ],
[ HSWX_INSIDE/2, HSWX_DEPTH-plug_spring_depth-0.5, 5.0 ], // upper spring midpoint
[ HSWX_INSIDE-plug_spring_base,      HSWX_DEPTH,   3.5 ],
[ HSWX_INSIDE-plug_stud_thickness,   HSWX_DEPTH ],

[    HSWX_INSIDE,                    HSWX_DEPTH,   2.0 ],    // weak lock
[ HSWX_INSIDE+HSWX_LOCK_LIP, HSWX_LOCK_DEPTH+HSWX_LOCK_LIP, 0.5 ],
[    HSWX_INSIDE,               HSWX_LOCK_DEPTH ],   // weak-side base
[    HSWX_INSIDE,                           0.1,   0.1 ],
[ HSWX_INSIDE+0.1,                            0 ],
[ HSWX_INSIDE-plug_stud_thickness-0.5,        0 ],
[ HSWX_INSIDE-plug_stud_thickness,          0.5,   1.0 ],
/**/
[ HSWX_INSIDE-plug_stud_thickness, HSWX_DEPTH-plug_spring_thickness-1.4, 1.5 ],
[ HSWX_INSIDE-plug_spring_base+.1, HSWX_DEPTH-plug_spring_thickness-0.1, 1.0 ],

[ HSWX_INSIDE/2, HSWX_DEPTH-plug_spring_depth-plug_spring_thickness, 6.0 ],

[ plug_spring_base, HSWX_DEPTH-plug_spring_thickness, 2.0 ],
[ plug_stud_thickness,             HSWX_DEPTH/3,   1.0 ],
[ HSWX_INSIDE/3.4,                            0 ],
[ plug_stud_thickness,                        0 ],
] ];

  translate(center?[0,0,0]:[HSWX_INSIDE/2,HSWX_INSIDE/4,0])
  rotate([0,0,rotate])
    union() {
      translate([-HSWX_INSIDE/2,-HSWX_INSIDE/4,0])
        rotate([-90,0,0])
          linear_extrude(HSWX_INSIDE/2)
            polygon( round_corners(path=points(outline[type]), radius=rads(outline[type]), $fn=90) );
      if( hexbase ) {
        cyl(l=hexbase, d=hswx_od-1, $fn=6, anchor=BOTTOM, spin=30, rounding2=hexbase/2);
      }
      if( rectbase ) {
        //rounding
        cuboid( size=[HSWX_OUTSIDE, HSWX_INSIDE/2, rectbase], rounding=rectbase/2, edges=[TOP+LEFT,TOP+RIGHT], anchor=BOTTOM+CENTER );
      }
  }
}

// hsw_clip(center=true, rotate=0); //, type=0, hexbase=3);
if( generate_clipconnector )
  rotate([90,0,0])
    hsw_clipconnector();

if( generate_clip )
  hsw_clip(center=true, rectbase=generate_clip_rect_base?3:0, hexbase=generate_clip_hex_base?3:0);