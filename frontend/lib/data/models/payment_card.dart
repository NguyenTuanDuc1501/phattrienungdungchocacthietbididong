class PaymentCard {
  final String id;
  final String cardNumber; // masked, e.g. "**** **** **** 3947"
  final String holderName;
  final String expiryDate; // MM/YY
  final String cardType; // 'mastercard' | 'visa'
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });
}
