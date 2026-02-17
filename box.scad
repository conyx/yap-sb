// Main box module
module box() {
  color(BOX_COLOR)
  difference() {
    union() {
      left(generate_lid ? x_width_outside/2 + box_x_margin : 0)
      difference()
        {
          union()
          {
            // Outer body
            up(bottom_height_outside/2)
              cuboid([x_width_outside, y_depth_outside, bottom_height_outside],
                     rounding = corner_outer_radius,
                     edges = "Z");

            // Inner body that forms lip
            up(box_height_outside/2)
              cuboid([x_width_outside - thickness*2 - lp_looseness_offset*2,
                      y_depth_outside - thickness*2 - lp_looseness_offset*2,
                      box_height_outside],
                     rounding = lip_rounding,
                     edges = "Z");
          }

          // Cut out inside
          compartments(
            height = box_height_outside,
            z_offset = thickness,
            outer_rounding = max(MIN_CORNER_RADIUS,
                                 corner_inner_radius,
                                 corner_outer_radius - thickness - lp_thickness - lp_looseness_offset),
            inner_rounding = max(MIN_CORNER_RADIUS, corner_inner_radius),
            bottom_rounding = compartment_bottom_radius,
            edge_extension = 0
          );
        }

      // Connection bump
      connection_box("bump");
      }

      // Cut out magnet holders space
      magnet_holders_box(clearance = true);

      // Cut out connection groove
      connection_box("groove");
    }
}
