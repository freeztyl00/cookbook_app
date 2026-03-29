enum Sizes {
  xs(4.0),
  s(8.0),
  m(16.0),
  l(32.0),
  xl(64.0);

  final double _value;
  const Sizes(this._value);

  double get value => _value;
}
