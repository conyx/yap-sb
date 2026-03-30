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
