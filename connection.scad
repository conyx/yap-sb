// Connection bump / groove modules
// Bump is the smaller protrusion, groove is the larger channel that receives it.

module connection_sweep(diameter) {
  path_sweep2d(
    circle(d = diameter),
    rect([x_width_outside - thickness, y_depth_outside - thickness],
         rounding = connection_rounding),
    closed=true
  );
}

// type = "bump" or "groove"
module connection_box(type) {
  if (generate_connection) {
    assert(connection_groove_percentage >= connection_bump_percentage,
           str("connection_groove_percentage must be greater than or equal to connection_bump_percentage. ",
               "Groove: ", connection_groove_percentage, "%, Bump: ", connection_bump_percentage, "%"));
  }

  should_render = generate_connection && (
    (type == "bump" && connection_type == "bump_box") ||
    (type == "groove" && connection_type == "bump_lid")
  );

  if (should_render) {
    left(generate_lid ? x_width_outside/2 + box_x_margin : 0)
    up(bottom_height_outside)
      connection_sweep(type == "bump" ? connection_bump_diameter : connection_groove_diameter);
  }
}

// type = "bump" or "groove"
module connection_lid(type) {
  should_render = generate_connection && (
    (type == "bump" && connection_type == "bump_lid") ||
    (type == "groove" && connection_type == "bump_box")
  );

  if (should_render) {
    move([x_width_outside/2 + lid_x_margin, 0, lid_height_outside])
      connection_sweep(type == "bump" ? connection_bump_diameter : connection_groove_diameter);
  }
}
