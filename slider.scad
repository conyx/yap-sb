module slider_lid_base(is_clearance = false) {
  h = slider_lid_thickness + (is_clearance ? SWO * 2 : 0);
  cuboid([x_width, y_depth, h],
         rounding = lid_cut_out_rounding,
         edges = "Z");
}

module slider_rail_base_part_mask(is_lid_part = false) {
  cut_x = x_width_outside
          - max(thickness, corner_outer_radius)
          - (is_lid_part ? 0 : slider_lid_tolerance);
  mask_x_width = cut_x + SWO * 2;
  mask_y_depth = y_depth_outside + SWO * 2;
  mask_z_height = slider_lid_thickness + SWO * 2;
  
  left((x_width_outside - mask_x_width) / 2 + SWO)
    cuboid([
      mask_x_width,
      mask_y_depth,
      mask_z_height
    ]);
}

module slider_rail_base_part(is_lid_part = false) {
  if (is_lid_part) {
    difference() {
      slider_rail_base();
      slider_rail_base_part_mask(is_lid_part);
    }
  } else {
    intersection() {
      slider_rail_base_part_mask(is_lid_part);
      slider_rail_base();
    }
  }
}

module slider_rail_base() {
  difference() {
      cuboid([x_width_outside, y_depth_outside, slider_lid_thickness],
             rounding = corner_outer_radius,
             edges = "Z");
      slider_lid_base(is_clearance = true);
    }
}

module slider_base(is_clearance = false) {
  grip = slider_lid_rail_grip / 100 * thickness;
  h = slider_lid_thickness + (is_clearance ? SWO * 2 : 0);
  profile = [
    [is_clearance ? -SWO : 0, 0],
    [grip, 0],
    [is_clearance ? -SWO : 0, h]
  ];
  path = rect([x_width, y_depth], rounding = lid_cut_out_rounding);
  down(h/2)
    path_sweep2d(profile, path, closed = true);
}

module slider_lid() {
  move([x_width_outside/2 + lid_x_margin, 0, slider_lid_thickness/2]) {
    slider_lid_base();
    slider_rail_base_part(is_lid_part = true);
    slider_base();
  }
}

module slider_rail_box() {
  left(x_width_outside/2 + box_x_margin)
  up(bottom_height_outside + slider_lid_thickness/2)
    difference() {
      slider_rail_base_part(is_lid_part = false);
      slider_base(is_clearance = true);
    }
}
