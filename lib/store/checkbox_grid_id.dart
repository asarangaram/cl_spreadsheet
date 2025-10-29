/// A helper class to uniquely tag children with their (row, column) index.
class CheckboxGridId {
  final int row;
  final int column;
  CheckboxGridId({required this.row, required this.column});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckboxGridId &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}