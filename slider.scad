module slider_lid_base(is_clearance = false) {
  h = slider_lid_thickness + (is_clearance ? SWO * 2 : 0);
  cuboid([get_x_width(), get_y_depth(), h],
         rounding = get_lid_cut_out_rounding(),
         edges = "Z");
}

module slider_rail_base_part_rounding_mask(is_lid_part) {
  slider_rail_base_part_rounding = min(
    slider_lid_thickness,
    max(corner_outer_radius, thickness)
  ) / 2;
  up(slider_lid_thickness / 2)
    right(
      get_x_width_outside() / 2
      - (get_x_width_outside() - get_slider_rail_base_cut_x(is_lid_part))
      + (is_lid_part ? -1 : 1) * SWO
    )
      rounding_edge_mask(
        height=get_y_depth_outside() + SWO,
        r=slider_rail_base_part_rounding,
        excess=SWO,
        spin=is_lid_part ? 270 : 90,
        orient=is_lid_part ? FRONT : BACK
      );
}

module slider_rail_base_part_mask(is_lid_part) {
  mask_x_width = get_slider_rail_base_cut_x(is_lid_part) + SWO * 2;
  mask_y_depth = get_y_depth_outside() + SWO * 2;
  mask_z_height = slider_lid_thickness + SWO * 2;

  left((get_x_width_outside() - mask_x_width) / 2 + SWO)
    cuboid([
      mask_x_width,
      mask_y_depth,
      mask_z_height
    ]);
}

module slider_rail_base_part(is_lid_part) {
  if (is_lid_part) {
    difference() {
      slider_rail_base();
      slider_rail_base_part_mask(is_lid_part);
      slider_rail_base_part_rounding_mask(is_lid_part);
    }
  } else {
    difference() {
      intersection() {
        slider_rail_base_part_mask(is_lid_part);
        slider_rail_base();
      }
      slider_rail_base_part_rounding_mask(is_lid_part);
    }
  }
}

module slider_rail_base() {
  difference() {
      cuboid([get_x_width_outside(), get_y_depth_outside(), slider_lid_thickness],
             rounding = corner_outer_radius,
             edges = "Z");
      slider_lid_base(is_clearance = true);
    }
}

module slider_base(is_clearance = false) {
  grip = slider_lid_rail_grip / 100 * thickness;
  h = slider_lid_thickness + (is_clearance ? SWO * 2 : 0);
  profile = [
    [0, 0],
    [grip, 0],
    [0, h]
  ];
  profile_clearance = [
    [-SWO, 0],
    [slider_lid_tolerance + grip, 0],
    [slider_lid_tolerance, h],
    [-SWO, h]
  ];
  path = rect([get_x_width(), get_y_depth()], rounding = get_lid_cut_out_rounding());
  down(h/2)
    path_sweep2d(is_clearance ? profile_clearance : profile, path, closed = true);
}

module slider_lid() {
  move([get_x_width_outside()/2 + get_lid_x_margin(), 0, slider_lid_thickness/2]) {
    slider_lid_base();
    slider_rail_base_part(is_lid_part = true);
    slider_base();
  }
}

module slider_rail_box() {
  left(get_x_width_outside()/2 + get_box_x_margin())
  up(get_bottom_height_outside() + slider_lid_thickness/2)
    difference() {
      slider_rail_base_part(is_lid_part = false);
      slider_base(is_clearance = true);
    }
}
