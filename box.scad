// Main box module
module box() {
  color(BOX_COLOR)
  difference() {
    union() {
      left(generate_lid ? x_width_outside/2 + box_x_margin : 0)
      difference() {
        union() {
          // Outer body
          up(bottom_height_outside/2)
            cuboid([x_width_outside, y_depth_outside, bottom_height_outside],
                   rounding = corner_outer_radius,
                   edges = "Z");

          // Inner body that forms lip
          up(box_height_outside/2)
            cuboid([x_width_outside - thickness*2 - lp_tolerance*2,
                    y_depth_outside - thickness*2 - lp_tolerance*2,
                    box_height_outside],
                   rounding = lip_rounding,
                   edges = "Z");
        }

        compartment_outer_rounding = max(
          MIN_CORNER_RADIUS,
          corner_inner_radius,
          corner_outer_radius - thickness - lp_thickness - lp_tolerance
        );

        // Cut out inside
        compartments(
          height = box_height_outside,
          z_offset = thickness,
          outer_rounding = compartment_outer_rounding,
          inner_rounding = max(MIN_CORNER_RADIUS, corner_inner_radius),
          bottom_rounding = compartment_bottom_radius,
          edge_extension = 0
        );

        // Cut out separator Z offset from the top
        if (separators_z_offset > 0) {
          assert(separators_z_offset <= bottom_height + lp_height,
            str("separators_z_offset must be less than bottom_height (+ lip_height if lip used) (= ",
                bottom_height + lp_height, "mm). ",
                "Current value: ", separators_z_offset, "mm"));  
        
          up(box_height_outside - separators_z_offset)
            cuboid([x_width, y_depth, separators_z_offset + SHIMMERING_WALL_OFFSET],
                   rounding = compartment_outer_rounding,
                   edges = "Z",
                   anchor = BOTTOM);
        }
      }

      if (lid_type == "slider") {
        // Rail which holds slider lid
        slider_rail_box();
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
