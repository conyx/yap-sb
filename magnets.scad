// Magnet holder base shape
module magnet_holder(height, wall_distance, wall_rounding, clearance) {
  color(INSIDE_ACCESSORIES_COLOR)
    difference() {
      holder_height = height + (clearance ? TINY : 0);
      holder_size = wall_distance + magnet_holder_radius;
      holder_rounding = [
        0,                   // X+Y+ (RIGHT+BACK)
        wall_rounding,       // X-Y+ (LEFT+BACK)
        0,                   // X-Y- (LEFT+FRONT)
        magnet_holder_radius // X+Y- (RIGHT+FRONT)
      ];
      holder_rect_xy_offset = (wall_distance - magnet_holder_radius) / 2
                              - magnet_holder_rounding_fix_offset;
      holder_circle_xy_offset = magnet_holder_rounding_fix_offset;

      up(holder_height/2)
        linear_extrude(height = holder_height, center = true)
          if (wall_rounding > holder_size) {
            move([holder_circle_xy_offset, -holder_circle_xy_offset])
              circle(r = magnet_holder_radius);
          } else {
            move([-holder_rect_xy_offset, holder_rect_xy_offset])
              rect([holder_size, holder_size],
                   rounding = holder_rounding);
          }

      if (!clearance) {
        move([magnet_holder_rounding_fix_offset,
              -magnet_holder_rounding_fix_offset,
              holder_height - magnet_hole_height - (magnet_generate_closure ? magnet_closure_height : 0)])
          cylinder(d=magnet_hole_diameter,
                   h=magnet_hole_height + (magnet_generate_closure ? 0 : SHIMMERING_WALL_OFFSET));
      }
    }
}

// Box magnet holder
module magnet_holder_box(clearance) {
  magnet_holder(height = box_height_outside,
                wall_distance = magnet_holder_radius + magnet_holder_rounding_fix_offset,
                wall_rounding = lip_rounding,
                clearance = clearance);
}

module magnet_holders_box_pair(clearance) {
  magnet_holder_box_left_x_position = -((x_width_outside + box_x_margin)
                                       -magnet_holder_radius
                                       -thickness
                                       -lp_tolerance);
  magnet_holder_box_right_x_position = -(box_x_margin + magnet_holder_radius + thickness + lp_tolerance);
  y_position = -y_depth/2 - lp_thickness + magnet_holder_radius;
  // When using hinges with 2 magnets, place both on the front side
  left_y_position = (generate_hinges && magnets_number == 2)
                    ? y_position
                    : -y_position;
  left_rotation = (generate_hinges && magnets_number == 2) ? 90 : 0;
  move([magnet_holder_box_left_x_position, left_y_position, 0]) {
    zrot(left_rotation) magnet_holder_box(clearance);
  }
  move([magnet_holder_box_right_x_position, y_position, 0]) {
    zrot(180) magnet_holder_box(clearance);
  }
}

module magnet_holders_box(clearance = false) {
  if (generate_magnets) {
    magnet_holders_box_pair(clearance);
    if (magnets_number == 4) {
      yflip() magnet_holders_box_pair(clearance);
    }
  }
}

// Lid magnet holder
module magnet_holder_lid(clearance) {
  xflip()
    magnet_holder(height = lid_height_outside - lp_height,
                  wall_distance = magnet_holder_radius + lp_tolerance + magnet_holder_rounding_fix_offset,
                  wall_rounding = lid_cut_out_rounding,
                  clearance = clearance);
}

module magnet_holders_lid_pair(clearance) {
  magnet_holder_lid_right_x_position = (x_width_outside + lid_x_margin)
                                      -magnet_holder_radius
                                      -thickness
                                      -lp_tolerance;
  magnet_holder_lid_left_x_position = lid_x_margin + magnet_holder_radius + thickness + lp_tolerance;
  y_position = -y_depth/2 -lp_thickness + magnet_holder_radius;
  // When using hinges with 2 magnets, place both on the front side
  right_y_position = (generate_hinges && magnets_number == 2)
                     ? y_position
                     : -y_position;
  right_rotation = (generate_hinges && magnets_number == 2) ? -90 : 0;
  move([magnet_holder_lid_right_x_position, right_y_position, 0]) {
    zrot(right_rotation) magnet_holder_lid(clearance);
  }
  move([magnet_holder_lid_left_x_position, y_position, 0]) {
    zrot(180) magnet_holder_lid(clearance);
  }
}

module magnet_holders_lid(clearance = false) {
  if (generate_magnets) {
    magnet_holders_lid_pair(clearance);
    if (magnets_number == 4) {
      yflip() magnet_holders_lid_pair(clearance);
    }
  }
}

// Main magnets module - generates all magnet holders based on generate_magnets and magnets_number
module magnets() {
  // Magnet-related assertions (only when magnets are used)
  if (generate_magnets) {
    assert(magnet_diameter > 0,
           str("magnet_diameter must be greater than 0. ",
               "Current value: ", magnet_diameter, "mm"));

    assert(magnet_height > 0,
           str("magnet_height must be greater than 0. ",
               "Current value: ", magnet_height, "mm"));

    assert(magnets_number == 2 || magnets_number == 4,
           str("Invalid magnets_number: ", magnets_number, ". ",
               "Must be 2 or 4"));

    required_height = magnet_hole_height + (magnet_generate_closure ? magnet_closure_height : 0);

    assert(box_height_inside >= required_height,
           str("Not enough height in box for magnets. ",
               "Box height: ", bottom_height, "mm, ",
               "required: ", required_height, "mm"));

    lid_available_height = lid_height - lp_height;

    assert(lid_available_height >= required_height,
           str("Not enough height in lid for magnets. ",
               "Lid available height: ", lid_available_height, "mm, ",
               "required: ", required_height, "mm"));

    assert(magnet_holder_diameter > magnet_hole_diameter,
           str("Magnet holder diameter must be larger. ",
               "Magnet holder diameter: ", magnet_holder_diameter, "mm, ",
               "required more than: ", magnet_hole_diameter, "mm"));
  }

  magnet_holders_box();
  magnet_holders_lid();
}
