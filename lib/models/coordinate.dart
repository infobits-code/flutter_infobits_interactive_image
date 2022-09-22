class Coordinate {
  final double x;
  final double y;

  const Coordinate({
    required this.x,
    required this.y,
  });

  Coordinate.fromString(String string)
      : x = double.parse(string.split(",")[0]),
        y = double.parse(string.split(",")[1]);

  @override
  String toString() {
    return "($x, $y)";
  }
}
