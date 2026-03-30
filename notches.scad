// Single lid notch shape
module lid_notch(dimension, z_position, near) {
  lid_notch_half_length = (dimension == "x" ? get_x_width_outside() : get_y_depth_outside()) / PHI / 2;
  move([dimension == "y" ? (get_x_width_outside() / 2 * (near ? -1 : 1)) : 0,
        dimension == "x" ? (get_y_depth_outside() / 2 * (near ? -1 : 1)) : 0,
        -get_lid_height_outside()/4 + z_position])
  xrot(dimension == "y" ? 90 : 0)
  yrot(dimension == "x" ? 90 : 0)
    hull() {
      up(lid_notch_half_length) sphere(r = get_lid_notch_radius());
      down(lid_notch_half_length) sphere(r = get_lid_notch_radius());
    }
}

// Main notches module - generates all notch cutouts for the lid
module notches() {
  z_position_offset = (get_lid_height_outside() / 2
                       - (lid_notches_number * get_lid_notch_radius() * 2)
                       - ((lid_notches_number - 1) * lid_notches_spacing))
                      / 2 + get_lid_notch_radius();
  for (n = [0 : lid_notches_number - 1]) {
    z_position = n * (get_lid_notch_radius() * 2 + lid_notches_spacing);
    if (lid_notches == "x" || lid_notches == "all") {
      if (!get_generate_latches()) {
        lid_notch("x", z_position_offset + z_position, true);
      }
      if (!get_generate_hinges() && !get_generate_latches_back()) {
        lid_notch("x", z_position_offset + z_position, false);
      }
    }
    if (lid_notches == "y" || lid_notches == "all") {
      lid_notch("y", z_position_offset + z_position, true);
      lid_notch("y", z_position_offset + z_position, false);
    }
  }
}
