// Single lid notch shape
module lid_notch(dimension, z_position, near) {
  lid_notch_half_length = (dimension == "x" ? x_width_outside : y_depth_outside) / PHI / 2;
  move([dimension == "y" ? (x_width_outside / 2 * (near ? -1 : 1)) : 0,
        dimension == "x" ? (y_depth_outside / 2 * (near ? -1 : 1)) : 0,
        -lid_height_outside/4 + z_position])
  xrot(dimension == "y" ? 90 : 0)
  yrot(dimension == "x" ? 90 : 0)
    hull() {
      up(lid_notch_half_length) sphere(r = lid_notch_radius);
      down(lid_notch_half_length) sphere(r = lid_notch_radius);
    }
}

// Main notches module - generates all notch cutouts for the lid
module notches() {
  z_position_offset = (lid_height_outside / 2
                       - (lid_notches_number * lid_notch_radius * 2)
                       - ((lid_notches_number - 1) * lid_notches_spacing))
                      / 2 + lid_notch_radius;
  for (n = [0 : lid_notches_number - 1]) {
    z_position = n * (lid_notch_radius * 2 + lid_notches_spacing);
    if (lid_notches == "x" || lid_notches == "all") {
      lid_notch("x", z_position_offset + z_position, true);
      if (!generate_hinges) {
        lid_notch("x", z_position_offset + z_position, false);
      }
    }
    if (lid_notches == "y" || lid_notches == "all") {
      lid_notch("y", z_position_offset + z_position, true);
      lid_notch("y", z_position_offset + z_position, false);
    }
  }
}
