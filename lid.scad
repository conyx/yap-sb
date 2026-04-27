// Main lid module
module lid() {
  // Lip-related assertions (only when lip is used)
  if (get_generate_lip()) {
    assert(get_lp_height() > 0,
           str("lip_height must be greater than 0 when using lip. ",
               "Current value: ", get_lp_height(), "mm"));

    assert(get_lp_thickness() > 0,
           str("lip_thickness must be greater than 0 when using lip. ",
               "Current value: ", get_lp_thickness(), "mm"));

    assert(get_lp_height() <= lid_height,
           str("lip_height must be smaller or equal than lid_height when using lip. ",
               "Current value: ", get_lp_height(), "mm"));
  }

  if (get_generate_lid()) {
    color(LID_COLOR)
      if (lid_type == "slider") {
        slider_lid();
      } else {
        difference() {
          union() {
            move([get_x_width_outside()/2 + get_lid_x_margin(), 0, get_lid_height_outside()/2])
            difference() {
              // Body
              cuboid([get_x_width_outside(), get_y_depth_outside(), get_lid_height_outside()],
                     rounding = corner_outer_radius,
                     edges = "Z");

              // Cut out compartments (separators in non-lip zone)
              if (separators_inside_lid) {
                compartments(
                  height = get_lid_height_outside(),
                  z_offset = thickness - get_lid_height_outside()/2,
                  outer_rounding = get_lid_cut_out_rounding(),
                  inner_rounding = MIN_CORNER_RADIUS,
                  bottom_rounding = 0,
                  edge_extension = get_lp_thickness() + get_lp_tolerance(),
                  mirror_x = true
                );
              }

              // Cut out full lid width and depth for lip clearance
              up((thickness + (separators_inside_lid ? (lid_height - get_lp_height()) : 0)) / 2 + SWO)
                cuboid([get_x_width_outside() - thickness*2,
                        get_y_depth_outside() - thickness*2,
                        (separators_inside_lid ? get_lp_height() : lid_height) + 2*SWO],
                       rounding = get_lid_cut_out_rounding(),
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
