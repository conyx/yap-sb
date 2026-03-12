// Shared module for cutting out compartments.
//
// Parameters:
//   height          - height of the cutout extrusion
//   z_offset        - Z position where the cutout starts
//   outer_rounding  - corner rounding for compartments at box/lid outer corners
//   inner_rounding  - corner rounding for compartments at separator intersections
//   bottom_rounding - bottom edge radius (os_circle) for compartment floors
//   edge_extension  - extra size added to edge compartments (those touching outer walls)
//   mirror_x        - mirror compartment layout along X axis (lid has reversed X vs box)
module compartments(height, z_offset, outer_rounding, inner_rounding, bottom_rounding, edge_extension, mirror_x = false) {
  for (r = [0 : len(compartments_grid) - 1]) {
    row = compartments_grid[r];
    row_depth = row[0];
    row_compartments = row[1];
    num_comps = len(row_compartments);
    row_width = sum(row_compartments) + (num_comps - 1) * separator_thickness;
    last_comp_extension = x_width - row_width;

    // Y position of row center (first row at +Y, last row at -Y)
    prev_depths = r > 0 ? sum([for (i = [0 : r-1]) compartments_grid[i][0]]) : 0;
    row_center_y = y_depth/2 - prev_depths - r * separator_thickness - row_depth/2;

    is_first_row = (r == 0);
    is_last_row = (r == len(compartments_grid) - 1);

    for (c = [0 : num_comps - 1]) {
      is_last_comp = (c == num_comps - 1);
      comp_width = row_compartments[c] + (is_last_comp ? last_comp_extension : 0);

      // X position of compartment center
      prev_widths = c > 0 ? sum([for (i = [0 : c-1]) row_compartments[i]]) : 0;
      comp_center_x = -x_width/2 + prev_widths + c * separator_thickness + comp_width/2;

      is_first_comp = (c == 0);

      // Extend edge compartments to fill space up to the outer wall
      ext_left = is_first_comp ? edge_extension : 0;
      ext_right = is_last_comp ? edge_extension : 0;
      ext_front = is_first_row ? edge_extension : 0;
      ext_back = is_last_row ? edge_extension : 0;

      final_width = comp_width + ext_left + ext_right;
      final_depth = row_depth + ext_front + ext_back;
      final_center_x = comp_center_x + (ext_right - ext_left) / 2;
      final_center_y = row_center_y + (ext_front - ext_back) / 2;

      // Determine which comp touches the +X / -X outer wall (swapped when mirrored)
      is_x_pos_wall = mirror_x ? is_first_comp : is_last_comp;
      is_x_neg_wall = mirror_x ? is_last_comp : is_first_comp;

      // Corner rounding: outer corners at box/lid edges, inner corners at separators
      cutout_corner_rounding = [
        (is_x_pos_wall && is_first_row) ? outer_rounding : inner_rounding,  // X+Y+
        (is_x_neg_wall && is_first_row) ? outer_rounding : inner_rounding,  // X-Y+
        (is_x_neg_wall && is_last_row) ? outer_rounding : inner_rounding,   // X-Y-
        (is_x_pos_wall && is_last_row) ? outer_rounding : inner_rounding    // X+Y-
      ];

      move([mirror_x ? -final_center_x : final_center_x, final_center_y, z_offset])
        offset_sweep(
          rect([final_width, final_depth], rounding = cutout_corner_rounding),
          height = height,
          bottom = os_circle(r = bottom_rounding),
          steps = 4 + 4 * bottom_rounding * model_detail
        );
    }
  }
}
