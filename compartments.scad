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
module compartments(
  height, z_offset, outer_rounding, inner_rounding, bottom_rounding, edge_extension, mirror_x = false
) {
  for (r = [0 : len(get_compartments_grid()) - 1]) {
    row = get_compartments_grid()[r];
    row_primary = row[0];
    row_comps = row[1];
    num_comps = len(row_comps);

    comps_total = sum(row_comps) + (num_comps - 1) * separator_thickness;
    last_comp_extension = (compartments_transpose ? get_y_depth() : get_x_width()) - comps_total;

    prev_primaries = r > 0 ? sum([for (i = [0 : r-1]) get_compartments_grid()[i][0]]) : 0;

    is_first_row = (r == 0);
    is_last_row = (r == len(get_compartments_grid()) - 1);

    for (c = [0 : num_comps - 1]) {
      is_last_comp = (c == num_comps - 1);
      comp_size = row_comps[c] + (is_last_comp ? last_comp_extension : 0);

      prev_comps = c > 0 ? sum([for (i = [0 : c-1]) row_comps[i]]) : 0;
      is_first_comp = (c == 0);

      // Non-transposed: rows stack along Y, compartments along X
      // Transposed: rows stack along X, compartments along Y
      comp_width = compartments_transpose ? row_primary : comp_size;
      comp_depth = compartments_transpose ? comp_size : row_primary;

      comp_center_x = compartments_transpose
        ? -get_x_width()/2 + prev_primaries + r * separator_thickness + row_primary/2
        : -get_x_width()/2 + prev_comps + c * separator_thickness + comp_size/2;

      comp_center_y = compartments_transpose
        ? get_y_depth()/2 - prev_comps - c * separator_thickness - comp_size/2
        : get_y_depth()/2 - prev_primaries - r * separator_thickness - row_primary/2;

      // Edge extensions: swap row/comp roles when transposed
      ext_left = (compartments_transpose ? is_first_row : is_first_comp) ? edge_extension : 0;
      ext_right = (compartments_transpose ? is_last_row : is_last_comp) ? edge_extension : 0;
      ext_front = (compartments_transpose ? is_first_comp : is_first_row) ? edge_extension : 0;
      ext_back = (compartments_transpose ? is_last_comp : is_last_row) ? edge_extension : 0;

      final_width = comp_width + ext_left + ext_right;
      final_depth = comp_depth + ext_front + ext_back;
      final_center_x = comp_center_x + (ext_right - ext_left) / 2;
      final_center_y = comp_center_y + (ext_front - ext_back) / 2;

      // Determine which walls this compartment touches
      is_x_neg = compartments_transpose ? is_first_row : is_first_comp;
      is_x_pos = compartments_transpose ? is_last_row : is_last_comp;
      is_y_pos = compartments_transpose ? is_first_comp : is_first_row;
      is_y_neg = compartments_transpose ? is_last_comp : is_last_row;

      is_x_pos_wall = mirror_x ? is_x_neg : is_x_pos;
      is_x_neg_wall = mirror_x ? is_x_pos : is_x_neg;

      // Corner rounding: outer corners at box/lid edges, inner corners at separators
      cutout_corner_rounding = [
        (is_x_pos_wall && is_y_pos) ? outer_rounding : inner_rounding,  // X+Y+
        (is_x_neg_wall && is_y_pos) ? outer_rounding : inner_rounding,  // X-Y+
        (is_x_neg_wall && is_y_neg) ? outer_rounding : inner_rounding,  // X-Y-
        (is_x_pos_wall && is_y_neg) ? outer_rounding : inner_rounding   // X+Y-
      ];

      move([mirror_x ? -final_center_x : final_center_x, final_center_y, z_offset])
        offset_sweep(
          rect([final_width, final_depth], rounding = cutout_corner_rounding),
          height = height,
          bottom = os_circle(r = bottom_rounding),
          steps = 4 + 4 * bottom_rounding * get_model_detail()
        );
    }
  }
}
