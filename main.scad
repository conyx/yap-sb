include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
include <BOSL2/fnliterals.scad>
include <BOSL2/joiners.scad>

include <utils.scad>
include <constants.scad>
include <compartments.scad>
include <connection.scad>
include <box.scad>
include <lid.scad>
include <magnets.scad>
include <hinges.scad>
include <latches.scad>
include <summary.scad>

/* [Main] */

// How the box and lid connect
lid_type = "hinges_magnets"; // [no_lid: No lid, lip: Lip, magnets: Magnets, lip_magnets: Lip and magnets, hinges: Hinges, hinges_magnets: Hinges and magnets]

// Number of fragments (a.k.a. $fn, a.k.a. resolution). Increase for better but slower results.
resolution = 100;

// Number of fragments in preview mode (a.k.a. $fn, a.k.a. resolution). Increase for better but slower results in preview mode.
resolution_preview = 25;

// Generate a summary plate with dimensions and accessory info (only in preview mode).
generate_summary_plate = true;

// Compartment dimensions as a flat vector. Format: depth, width, width, ..., 0, depth, width, ... Zeros separate rows. The first number of each row is its Y depth, followed by X widths of compartments in that row. (TIP: Use "[100, 100]" for a single full-box compartment.)
compartments_dimensions = [50, 20, 55, 55, 20, 0, 25, 37.5, 37.5, 37.5, 37.5];

// Bottom part height. The sum of the bottom and lid heights equals the total interior height of the container.
bottom_height = 25; // .5

// Lid height. The sum of the bottom and lid heights equals the total interior height of the container.
lid_height = 10; // .5

// Wall thickness. This adds to the outside dimensions of the box.
thickness = 2.4; // .1

/* [Separators] */

// Thickness of the walls between compartments (i.e., separators).
separator_thickness = 1.0; // .1

// Whether separators should also be generated inside the lid.
separators_inside_lid = false;

/* [Rounding] */

// Box/lid corner outer radius (0 = sharp outer corner).
corner_outer_radius = 4; // .5

// Box/lid corner inner radius (0 = sharp inner corner).
corner_inner_radius = 2; // .5

// Compartment bottom corner radius (0 = sharp inner corner). Warning: high values can significantly slow rendering.
compartment_bottom_radius = 0; // .5

/* [Lip] */

// Height of lip above box top, used for the friction fit.
lip_height = 5; // .5

// Wall thickness of the lip.
lip_thickness = 0.8; // .1

// Lip outer dimension offset. The larger the number, the looser the friction fit.
lip_looseness_offset = 0.15; // .05

/* [Connection groove / bump] */

// Connection type on top of the box/lid wall: bump is the smaller protrusion, groove is the larger channel that receives it. Has no effect if: 1) no lid is generated, 2) lip is generated, or 3) bump or groove percentage is zero.
connection_type = "bump_box"; // [off: Off, bump_box: Bump on box & groove on lid, bump_lid: Bump on lid & groove on box]

// Groove diameter as percentage of wall thickness. Must be >= bump percentage.
connection_groove_percentage = 80; // [0:1:100]

// Bump diameter as percentage of wall thickness. Must be <= groove percentage.
connection_bump_percentage = 70; // [0:1:100]

/* [Magnets] */

// # of magnets
magnets_number = 2; // [2: 2 magnets, 4: 4 magnets]

// Magnet diameter
magnet_diameter = 3;  // .5

// Magnet height
magnet_height = 3;  // .5

// Magnet holder diameter (must be greater than magnet_diameter)
magnet_holder_diameter = 5;  // .5

// Extra height for (super) glue to secure magnets in their holes
magnet_glue_height = 1; // .5

// Whether to generate a magnet closure that fills the space above the magnet. IMPORTANT: You have to pause printing at a specific layer to insert magnets. See console output or the summary plate for instructions.
magnet_generate_closure = false;

// Height of the magnet closure.
magnet_closure_height = 0.45; // [0.1:0.05:1]

// Magnet hole dimension offset. The larger the number, the looser the friction fit.
magnet_looseness_offset = 0.15; // .05

/* [Hinges] */

// How hinge segments should be joined. "Simple pin" creates a simple hole with a specific diameter, "Screw with nut" also creates holes for the screw head and nut, "Self-tapping screw" creates a hole for the screw head and adjusts the last segment for self-tapping.
hinge_join_type = "screw_nut"; // [pin: Simple pin, screw_nut: Screw with nut, screw_self_tap: Self-tapping screw]

// # of hinges
hinges_number = 2; // [1:1:10]

// # of segments of each hinge
hinge_segments = 2; // [2:1:30]

// Hinge segments ratio (ratio between lid and box hinge segment lengths; use 1 for equal length)
hinge_segments_ratio = 1; // [0.2:0.1:5]

// Hinge knuckle diameter
hinge_knuckle_diameter = 6;  // .5

// Whether the last hinge should be mirrored (e.g., for easier screwdriver access or a symmetric hinge pair)
hinge_flip_last = true;

// Angle of the hinge arm measured down from the vertical
hinge_arm_angle = 45; // [30:1:90]

// Additional offset between the hinge and the box/lid
hinge_mount_gap = 0.1; // .05

// Gap between hinge segments
hinge_segments_gap = 0.15; // .05

/* [Hinges / simple pin] */

// Length of each hinge (also the minimum length of the hinge pin)
hinge_pin_length = 20;

// Diameter of the hinge pin (budget tip: use 1.75 for a filament string)
hinge_pin_diameter = 1.75; // .05

/* [Hinges / screw with nut] */

// Hinge screw length (without head)
hinge_screw_length = 30;

// Hinge screw diameter
hinge_screw_diameter = 2.5;  // .05

// Hinge screw head width
hinge_screw_head_width = 1.8; // .1

// Hinge screw head diameter
hinge_screw_head_diameter = 4; // .1

// Hinge screw nut width (depth of the nut recess)
hinge_nut_width = 1.8; // .1

// Hinge screw nut size (i.e., the spanner/wrench size needed)
hinge_nut_size = 4; // .1

// Looseness offset for the screw head and nut. The larger the number, the looser the friction fit.
hinge_screw_looseness_offset = 0.1; // .05

/* [Hinges / self-tapping screw] */

// Type of the self-tapping screw (ISO/metric and UTS/imperial standards)
hinge_self_tap_screw_type = "M2"; // [M1.6: M1.6 {ISO / metric}, M1.8: M1.8 {ISO / metric}, M2: M2 {ISO / metric}, M2.5: M2.5 {ISO / metric}, M3: M3 {ISO / metric}, M3.5: M3.5 {ISO / metric}, M4: M4 {ISO / metric}, M5: M5 {ISO / metric}, M6: M6 {ISO / metric}, #0: #0 {UTS / imperial}, #1: #1 {UTS / imperial}, #2: #2 {UTS / imperial}, #3: #3 {UTS / imperial}, #4: #4 {UTS / imperial}, #5: #5 {UTS / imperial}, #6: #6 {UTS / imperial}, #8: #8 {UTS / imperial}, #10: #10 {UTS / imperial}, #12: #12 {UTS / imperial}]

// Length of the self-tapping screw (including head)
hinge_self_tap_screw_length = 20;

// Maximum depth of the tapped portion of the screw hole in the last hinge segment.
hinge_self_tap_screw_tap_depth = 10; // .5

// Safety gap between the screw tip and the edge of the hinge
hinge_self_tap_screw_gap = 2; // .5

/* [Latches] */
latch_x_width = 15;
latch_z_height = 15;
latch_y_thickness = 4;
latch_snap_lock = true;
latch_snap_lock_firmness = 0.5; // [0:0.05:1]
latch_hinge_arm_angle = 45; // [30:1:90]
latch_hinge_gap = 0.15; // .05
latch_looseness_offset = 0.1; // .05

/* [Lid notches] */

// Where lid notches (for easier lid opening) should be generated
lid_notches = "x"; // [no: None,x:X sides only, y:Y sides only, all:Both X and Y sides]

// # of lid notches
lid_notches_number = 2;

// Lid notch spacing
lid_notches_spacing = 1.5; // .1

/* [Hidden] */

$fn = $preview ? resolution_preview : resolution;

compartments_grid = parse_compartments_grid(compartments_dimensions);

// Derived flags
generate_lid = lid_type != "no_lid";
generate_lip = (lid_type == "lip" || lid_type == "lip_magnets");
generate_magnets = (lid_type == "magnets" || lid_type == "lip_magnets" || lid_type == "hinges_magnets");
generate_hinges = (lid_type == "hinges" || lid_type == "hinges_magnets");
generate_connection = connection_type != "off" && generate_lid && !generate_lip &&
                    connection_groove_percentage > 0 && connection_bump_percentage > 0;

// Reset lip parameters if needed
lp_height = generate_lip ? lip_height : 0;
lp_thickness = generate_lip ? lip_thickness : 0;
lp_looseness_offset = generate_lip ? lip_looseness_offset : 0;

// Final margins from Y axis
box_x_margin = 2;
lid_x_margin = 2;

// Total X width: sum of compartment widths + separators in each row
x_width = max([for (row = compartments_grid)
  let(widths = row[1], n = len(widths))
  sum(widths) + (n - 1) * separator_thickness
]);
// Total Y depth: sum of row depths + separators between rows
y_depth = sum([for (row = compartments_grid) row[0]])
          + (len(compartments_grid) - 1) * separator_thickness;
x_width_outside = x_width + thickness*2 + lp_thickness*2 + lp_looseness_offset*2;
y_depth_outside = y_depth + thickness*2 + lp_thickness*2 + lp_looseness_offset*2;
bottom_height_outside = bottom_height + thickness;
box_height_inside = bottom_height + lp_height;
box_height_outside = bottom_height_outside + lp_height;
lid_height_outside = lid_height + thickness;
lip_rounding = max(MIN_CORNER_RADIUS,
                   corner_outer_radius - thickness - lp_looseness_offset);
lid_cut_out_rounding = max(MIN_CORNER_RADIUS, corner_outer_radius - thickness);

// Hinges
hinge_knuckle_offset = hinge_knuckle_diameter / 2 + hinge_mount_gap;
hinge_length = hinge_join_type == "screw_self_tap"
  ? hinge_self_tap_screw_length + hinge_self_tap_screw_gap
  : hinge_join_type == "screw_nut"
    ? hinge_screw_length + hinge_screw_head_width + 4*hinge_screw_looseness_offset
    : hinge_pin_length;
hinge_hole_diameter = hinge_join_type == "screw_self_tap"
  ? hinge_self_tap_screw_type
  : hinge_join_type == "screw_nut"
    ? hinge_screw_diameter
    : hinge_pin_diameter;

// Magnets
magnet_holder_radius = magnet_holder_diameter/2;
magnet_holder_rounding_fix_offset = max(
  0,
  ((sqrt(2) - 1) * (lip_rounding - magnet_holder_radius)) / sqrt(2)
);
magnet_hole_diameter = magnet_diameter + 2*magnet_looseness_offset;
magnet_hole_height = magnet_height + magnet_glue_height + 2*magnet_looseness_offset;

// Connaction groove / bump
connection_groove_diameter = connection_groove_percentage / 100 * thickness;
connection_bump_diameter = connection_bump_percentage / 100 * thickness;
connection_rounding = max(MIN_CORNER_RADIUS, corner_outer_radius - thickness/2);

// Latches
latch_slope = 6;
latch_radius = min(latch_x_width, latch_z_height) / 10;
latch_x_width_outside = latch_x_width * 1.5;
latch_x_width_back = latch_x_width * 0.9;
latch_hinge_diameter = latch_y_thickness;
latch_inner_hinge_segment_width = latch_x_width
                                          - latch_z_height / latch_slope * 2 +
                                          latch_hinge_gap;
latch_notch_y_depth = latch_y_thickness / 2;
latch_notch_z_height = min(latch_y_thickness / 2, latch_z_height / 5);
latch_snap_lock_diameter_female = min(3, latch_y_thickness * 0.85);
latch_snap_lock_diameter_male = latch_snap_lock_diameter_female * 0.9;

// Lid notches
lid_notch_radius = thickness / 2;

// Generate box
box();

// Generate the lid
lid();

// Magnet holders
magnets();

// Hinges
hinges();

// Latches
latches();

// Output summary
summary();
