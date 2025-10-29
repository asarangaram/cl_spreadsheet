import 'package:cl_spreadsheet/grid_layout.dart';
import 'package:flutter/material.dart';

import 'store/checkbox_grid_id.dart';

class GridExampleScreen extends StatelessWidget {
  const GridExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialGridContentMap = <CheckboxGridId, GridCellContent>{
      // R0: Headers
      CheckboxGridId(row: 0, column: 0): const TextContent('Padded Ints (Dec)'),
      CheckboxGridId(row: 0, column: 1): const TextContent('Padded Floats'),
      CheckboxGridId(row: 0, column: 2): const TextContent('Hex (Edit in Hex)'),
      CheckboxGridId(row: 0, column: 3): const TextContent(
        'Binary (Edit in Bin)',
      ),

      // R1: Decimal Integers
      CheckboxGridId(row: 1, column: 0): const IntegerContent(
        1,
        paddingCount: 8,
      ),
      CheckboxGridId(row: 2, column: 0): const IntegerContent(
        1234,
        paddingCount: 8,
      ),
      CheckboxGridId(row: 3, column: 0): const IntegerContent(
        1000000,
        paddingCount: 8,
      ),

      // R1: Floats
      CheckboxGridId(row: 1, column: 1): const FloatContent(
        1.23,
        precision: 2,
        paddingCount: 10,
      ),
      CheckboxGridId(row: 2, column: 1): const FloatContent(
        1234.5,
        precision: 3,
        paddingCount: 10,
      ),
      CheckboxGridId(row: 3, column: 1): const FloatContent(
        1234567.89,
        precision: 2,
        paddingCount: 10,
      ),

      // R1: Hex Codes
      CheckboxGridId(row: 1, column: 2): const IntegerContent(
        15,
        format: IntegerFormat.hex,
      ),
      CheckboxGridId(row: 2, column: 2): const IntegerContent(
        255,
        format: IntegerFormat.hex,
      ),
      CheckboxGridId(row: 3, column: 2): const IntegerContent(
        65535,
        format: IntegerFormat.hex,
      ),

      // R1: Binary Codes
      CheckboxGridId(row: 1, column: 3): const IntegerContent(
        16,
        format: IntegerFormat.binary,
      ),
      CheckboxGridId(row: 2, column: 3): const IntegerContent(
        12,
        format: IntegerFormat.binary,
      ),
      CheckboxGridId(row: 3, column: 3): const IntegerContent(
        255,
        format: IntegerFormat.binary,
      ),
    };

    // We will use 10 rows and 4 columns here to test the vertical scrolling/spacer logic
    return Container(
      width: 400,
      height: 400,

      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: CheckboxGridLayout(
        rows: 10, // Increased rows to 10 to test scrolling when height > 400
        columns: 4,
        initialChildren: initialGridContentMap,
      ),
    );
  }
}
