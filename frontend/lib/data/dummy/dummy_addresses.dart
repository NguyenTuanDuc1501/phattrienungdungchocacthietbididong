import '../models/address.dart';

final List<Address> dummyAddresses = [
  const Address(
    id: 'a1',
    fullName: 'Jane Doe',
    addressLine: '3 Newbridge Court',
    city: 'Chino Hills',
    state: 'CA',
    zipCode: '91709',
    country: 'United States',
    isDefault: true,
  ),
  const Address(
    id: 'a2',
    fullName: 'Jane Doe',
    addressLine: '51 Riverside',
    city: 'Chino Hills',
    state: 'CA',
    zipCode: '91709',
    country: 'United States',
  ),
  const Address(
    id: 'a3',
    fullName: 'Jane Doe',
    addressLine: '5 Newbridge Court',
    city: 'Chino Hills',
    state: 'CA',
    zipCode: '91709',
    country: 'United States',
  ),
];
