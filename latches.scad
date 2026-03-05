module latch_dovetail(is_male) {
  dovetail(is_male? "male" : "female",
           slide=latch_y_thickness,
           width=latch_x_width,
           back_width=latch_x_width_back,
           height=latch_z_height,
           radius=latch_radius,
           slope = latch_slope,
           extra = is_male ? 0 : TINY,
           $slop=latch_looseness_offset);
}

module latch_hinge(is_male) {
  knuckle_hinge(length = latch_x_width_outside,
                segs = 3,
                offset = latch_hinge_diameter / 2,
                knuckle_diam = latch_hinge_diameter,
                gap = latch_hinge_gap,
                clear_top=true,
                inner = is_male,
                in_place=true,
                pin_diam = latch_hinge_diameter >= 5
                             ? latch_hinge_diameter - 1
                             : latch_hinge_diameter * 0.8,
                arm_angle = is_male ? 90 : latch_hinge_arm_angle,
                seg_ratio = latch_inner_hinge_segment_width /
                            ((latch_x_width_outside - latch_inner_hinge_segment_width) / 2),
                orient = is_male ? BOTTOM : FRONT
  );
}

module latch_female_support() {
  latch_x_width_female = latch_x_width + latch_looseness_offset * 2;
  latch_x_width_back_female = latch_x_width_back + latch_looseness_offset * 2;
  top_mount = [[0, 0],
               [0, latch_y_thickness],
               [(latch_x_width_outside - latch_x_width_back_female) / 2, latch_y_thickness],
               [(latch_x_width_outside - latch_x_width_female) / 2, 0]];
  bottom_mount = [[0, latch_y_thickness - TINY],
                  [0, latch_y_thickness],
                  [(latch_x_width_outside - latch_x_width_female) / 2, latch_y_thickness],
                  [(latch_x_width_outside - latch_x_width_female) / 2, latch_y_thickness - TINY]];
  skin([bottom_mount, top_mount], z=[0,latch_y_thickness], slices=$fn);
}

module latch_female_support_left() {
  move([-latch_x_width_outside / 2, -latch_y_thickness / 2, -latch_y_thickness - latch_z_height / 2])
    latch_female_support();
}

module latch_female_support_right() {
  xflip() latch_female_support_left();
}

module latch_female_supports() {
  latch_female_support_left();
  latch_female_support_right();
}

module latch_notch() {
  move([0, latch_notch_y_depth / 2, latch_z_height - latch_notch_z_height / 2])
        cuboid([latch_x_width,
                latch_notch_y_depth + TINY,
                latch_notch_z_height + TINY]);
}

module latch_snap_lock(is_male) {
  _diameter = is_male ? latch_snap_lock_diameter_male : latch_snap_lock_diameter_female;
  sphere(d = _diameter);
}

module latch_snap_lock_right(is_male) {
  _diameter = is_male ? latch_snap_lock_diameter_male : latch_snap_lock_diameter_female;
  _z_offset = latch_notch_z_height + latch_snap_lock_diameter_female / 2;
  _x_offset = _z_offset / latch_slope + (_diameter / 2) * (1 - latch_snap_lock_firmness);
  move([mean([latch_x_width, latch_x_width_back]) / 2 - _x_offset,
        0,
        latch_z_height - _z_offset])
    latch_snap_lock(is_male);
}

module latch_snap_lock_left(is_male) {
  xflip() latch_snap_lock_right(is_male);
}

module latch_snap_locks(is_male) {
  latch_snap_lock_left(is_male);
  latch_snap_lock_right(is_male);
}

module latch_lid_hinge() {
   latch_hinge(false);
}

module latch_lid() {
  xrot(90) union() {
    difference() {
      latch_dovetail(true);
      latch_notch();
    }
    latch_snap_locks(true);
    latch_hinge(true);
  }
}

module latch_box() {
  up(latch_z_height) xrot(180) {
    difference() {
      up(latch_z_height / 2) xrot(180) {
        xrot(-90)
          diff("female_dovetail")
            cuboid([latch_x_width_outside, latch_z_height, latch_y_thickness]) {
              tag("female_dovetail")
                attach(FRONT)
                  latch_dovetail(false);
          }
        latch_female_supports();
      }
      latch_snap_locks(false);
    }
  }
}

module latches() {
  // TODO
  fwd(100)
  color(OUTSIDE_ACCESSORIES_COLOR) {
    latch_box();
    latch_lid();
    latch_lid_hinge();
  }
}
