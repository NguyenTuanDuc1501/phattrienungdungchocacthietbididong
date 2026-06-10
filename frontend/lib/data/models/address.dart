class Address {
  final String id;
  final String fullName;
  final String addressLine;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.fullName,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  String get formattedAddress =>
      '$addressLine, $city, $state $zipCode, $country';
}
