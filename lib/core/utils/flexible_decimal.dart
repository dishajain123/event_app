/// FastAPI/Pydantic's JSON encoding of a `Decimal` field (e.g.
/// `EventConfiguration.fee_amount`, payment amounts from later phases) can
/// arrive as either a JSON number or a JSON string depending on
/// configuration — this parses either shape defensively rather than
/// assuming one, mirroring the same defensive `string | number` handling
/// used for amount fields on the web console side.
double? parseFlexibleDecimal(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
