function in_place_knuckle_hinge_pin_diam(knuckle_diam) =
  knuckle_diam >= 5
    ? knuckle_diam - 1
    : knuckle_diam * 0.8;

function parse_compartments_grid(compartments_flat) =
  let(
    a1 = assert(len(compartments_flat) >= 2,
           str("compartments_dimensions must have at least 2 values (one depth and one width). ",
               "Current length: ", len(compartments_flat))),
    a2 = assert(len([for (v = compartments_flat) if (v < 0) v]) == 0,
           str("compartments_dimensions must not contain negative values. ",
               "Found: ", [for (v = compartments_flat) if (v < 0) v])),
    a3 = assert(compartments_flat[0] != 0 &&
                 compartments_flat[1] != 0 &&
                 compartments_flat[len(compartments_flat)-1] != 0 &&
                 compartments_flat[len(compartments_flat)-2] != 0,
           str("compartments_dimensions must not have zeros at 1st, 2nd, penultimate or last positions. ",
               "Values: ", compartments_flat)),
    zero_pos = [for (i = [0:len(compartments_flat)-1]) if (compartments_flat[i] == 0) i],
    a4 = assert(len(zero_pos) < 2
             ? true
             : len([for (i = [0:len(zero_pos)-2])
                    if (zero_pos[i+1] - zero_pos[i] < 3) i]) == 0,
           str("Between two zeros in compartments_dimensions there must be 2 or more non-zero values. ",
               "Zero positions: ", zero_pos)),

    f = (len(compartments_flat) > 0 && compartments_flat[len(compartments_flat)-1] != 0)
        ? concat(compartments_flat, [0])
        : compartments_flat,
    sentinel_indices = [for (i = [0:len(f)-1]) if (f[i] == 0) i]
  )
  [for (i = [0:len(sentinel_indices)-1])
    let(
      start = i == 0 ? 0 : sentinel_indices[i-1] + 1,
      end = sentinel_indices[i] - 1,
      depth = f[start],
      widths = [for (j = [start+1:end]) f[j]]
    )
    [depth, widths]
  ];

function get_model_detail() = $preview ? model_detail_preview : model_detail_stl;

function get_compartments_grid() = parse_compartments_grid(compartments_dimensions);

// Derived flags
function get_generate_lid() = lid_type != "no_lid";
function get_generate_lip() = (
  lid_type == "lip" || lid_type == "lip_magnets" || lid_type == "lip_latches"
);
function get_generate_magnets() = (
  lid_type == "magnets" || lid_type == "lip_magnets" || lid_type == "hinges_magnets"
);
function get_generate_hinges() = (
  lid_type == "hinges" || lid_type == "hinges_magnets" || lid_type == "hinges_latches"
);
function get_generate_latches() = (
  lid_type == "latches" || lid_type == "lip_latches" || lid_type == "hinges_latches"
);
function get_generate_latches_back() = (lid_type == "latches" || lid_type == "lip_latches");
function get_generate_connection() = (
  connection_type != "off" &&
  get_generate_lid() && lid_type != "slider" &&
  !get_generate_lip() &&
  connection_groove_percentage > 0 && connection_bump_percentage > 0
);

// Lip
function get_lp_height() = get_generate_lip() ? lip_height : 0;
function get_lp_thickness() = get_generate_lip() ? lip_thickness : 0;
function get_lp_tolerance() = get_generate_lip() ? lip_tolerance : 0;

// Final margins
function get_box_x_margin() = 2;
function get_lid_x_margin() = 2;
function get_latch_margin() = 2;

// Dimensions
function get_rows_size() = sum([for (row = get_compartments_grid()) row[0]])
             + (len(get_compartments_grid()) - 1) * separator_thickness;
function get_columns_size() = max([for (row = get_compartments_grid())
  let(widths = row[1], n = len(widths))
  sum(widths) + (n - 1) * separator_thickness
]);
function get_x_width() = compartments_transpose ? get_rows_size() : get_columns_size();
function get_y_depth() = compartments_transpose ? get_columns_size() : get_rows_size();
function get_x_width_outside() = get_x_width() +
                                 thickness*2 +
                                 get_lp_thickness()*2 +
                                 get_lp_tolerance()*2;
function get_y_depth_outside() = get_y_depth() +
                                 thickness*2 +
                                 get_lp_thickness()*2 +
                                 get_lp_tolerance()*2;
function get_bottom_height_outside() = bottom_height + thickness;
function get_box_height_inside() = bottom_height + get_lp_height();
function get_box_height_outside() = get_bottom_height_outside() + get_lp_height();
function get_lid_height_outside() = lid_type == "slider" ? slider_lid_thickness : lid_height + thickness;
function get_lip_rounding() = max(MIN_CORNER_RADIUS,
                   corner_outer_radius - thickness - get_lp_tolerance());
function get_lid_cut_out_rounding() = max(MIN_CORNER_RADIUS, corner_outer_radius - thickness);

// Hinges
function get_hinge_knuckle_offset() = hinge_knuckle_diameter / 2 + hinge_mount_gap;
function get_hinge_length() = hinge_join_type == "screw_self_tap"
  ? hinge_self_tap_screw_length + hinge_self_tap_screw_gap
  : hinge_join_type == "screw_nut"
    ? hinge_screw_length + hinge_screw_head_width + 4*hinge_screw_tolerance
    : hinge_join_type == "print_in_place"
      ? hinge_in_place_length
      : hinge_pin_length;
function get_hinge_hole_diameter() = hinge_join_type == "screw_self_tap"
  ? hinge_self_tap_screw_type
  : hinge_join_type == "screw_nut"
    ? hinge_screw_diameter
    : hinge_join_type == "print_in_place"
      ? in_place_knuckle_hinge_pin_diam(hinge_knuckle_diameter)
      : hinge_pin_diameter;

// Magnets
function get_magnet_holder_radius() = magnet_holder_diameter/2;
function get_magnet_holder_rounding_fix_offset() = max(
  0,
  ((sqrt(2) - 1) * (get_lip_rounding() - get_magnet_holder_radius())) / sqrt(2)
);
function get_magnet_hole_diameter() = magnet_diameter + 2*magnet_tolerance;
function get_magnet_hole_height() = magnet_height + magnet_glue_height + 2*magnet_tolerance;

// Connection groove / bump
function get_connection_groove_diameter() = connection_groove_percentage / 100 * thickness;
function get_connection_bump_diameter() = connection_bump_percentage / 100 * thickness;
function get_connection_rounding() = max(MIN_CORNER_RADIUS, corner_outer_radius - thickness/2);

// Latches
function get_latch_slope() = 6;
function get_latch_radius() = min(latch_x_width, latch_z_height) / 10;
function get_latch_x_width_outside() = latch_x_width * 1.5;
function get_latch_x_width_back() = latch_x_width * 0.9;
function get_latch_hinge_diameter() = latch_y_thickness;
function get_latch_inner_hinge_segment_width() = latch_x_width
                                                 - latch_z_height / get_latch_slope() * 2
                                                 + latch_hinge_gap;
function get_latch_notch_y_depth() = latch_y_thickness / 2;
function get_latch_notch_z_height() = min(latch_y_thickness / 2, latch_z_height / 5);
function get_latch_snap_lock_diameter_female() = 3;
function get_latch_snap_lock_diameter_male() = get_latch_snap_lock_diameter_female() * 0.9;
function get_latch_support_z_height() = latch_y_thickness * tan(90 - latch_support_angle);

// Slider lid
function get_slider_rail_base_cut_x(is_lid_part) =
  get_x_width_outside()
  - max(thickness, corner_outer_radius)
  - (is_lid_part ? 0 : slider_lid_tolerance);

// Lid notches
function get_lid_notch_radius() = thickness / 2;
