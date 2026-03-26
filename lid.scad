// Main lid module
module lid() {
  // Lip-related assertions (only when lip is used)
  if (generate_lip) {
    assert(lp_height > 0,
           str("lip_height must be greater than 0 when using lip. ",
               "Current value: ", lp_height, "mm"));

    assert(lp_thickness > 0,
           str("lip_thickness must be greater than 0 when using lip. ",
               "Current value: ", lp_thickness, "mm"));

    assert(lp_height <= lid_height,
           str("lip_height must be smaller or equal than lid_height when using lip. ",
               "Current value: ", lp_height, "mm"));
  }

  if (generate_lid) {
    color(LID_COLOR)
      if (lid_type == "slider") {
        slider_lid();
      } else {
        difference() {
          union() {
            move([x_width_outside/2 + lid_x_margin, 0, lid_height_outside/2])
            difference() {
              // Body
              cuboid([x_width_outside, y_depth_outside, lid_height_outside],
                     rounding = corner_outer_radius,
                     edges = "Z");

              // Cut out compartments (separators in non-lip zone)
              if (separators_inside_lid) {
                compartments(
                  height = lid_height_outside,
                  z_offset = thickness - lid_height_outside/2,
                  outer_rounding = lid_cut_out_rounding,
                  inner_rounding = MIN_CORNER_RADIUS,
                  bottom_rounding = 0,
                  edge_extension = lp_thickness + lp_tolerance,
                  mirror_x = true
                );
              }

              // Cut out full lid width and depth for lip clearance
              up((thickness + (separators_inside_lid ? (lid_height - lp_height) : 0) + SHIMMERING_WALL_OFFSET) / 2)
                cuboid([x_width_outside - thickness*2,
                        y_depth_outside - thickness*2,
                        (separators_inside_lid ? lp_height : lid_height) + SHIMMERING_WALL_OFFSET],
                       rounding = lid_cut_out_rounding,
                       edges = "Z");

              // Cut out notches
              notches();
            }

          // Connection bump
          connection_lid("bump");
        }

        // Cut out connection groove
        connection_lid("groove");

        // Cut out magnet holders space
        magnet_holders_lid(clearance = true);
      }
    }
  }
}
