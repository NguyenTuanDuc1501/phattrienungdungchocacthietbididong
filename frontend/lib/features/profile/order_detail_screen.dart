import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_app_bar.dart';
import '../../data/models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Order Details'),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Order №${order.orderNumber}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
            Text('${order.date.day}-${order.date.month}-${order.date.year}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Tracking number: ', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
            Text(order.trackingNumber, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
          ]),
          const SizedBox(height: 4),
          Text(order.statusLabel, style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500,
            color: order.status == OrderStatus.delivered ? AppColors.success
                 : order.status == OrderStatus.cancelled ? AppColors.error : AppColors.dark)),
          const SizedBox(height: 16),
          Text('${order.items.length} items', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
          const SizedBox(height: 12),
          // Items list
          ...order.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12),
            child: Container(height: 104, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
              child: Row(children: [
                ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: item.imageUrl.startsWith('http')
                      ? Image.network(item.imageUrl, width: 104, height: 104, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))
                      : Image.asset(item.imageUrl, width: 104, height: 104, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))),
                Expanded(child: Padding(padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(item.name, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
                    Text(item.brand, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('Color: ${item.color}  ', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                      Text('Size: ${item.size}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Units: ${item.quantity}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                      Text('${item.price.toInt()}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark)),
                    ]),
                  ]))),
              ])))),
          const SizedBox(height: 16),
          // Order information
          const Text('Order information', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
          const SizedBox(height: 12),
          _infoRow('Shipping Address:', '3 Newbridge Court, Chino Hills, CA 91709, United States'),
          _infoRow('Payment method:', '**** **** **** 3947'),
          _infoRow('Delivery method:', 'FedEx, 3 days, 15\$'),
          _infoRow('Discount:', '10%, Personal promo code'),
          _infoRow('Total Amount:', '${order.totalAmount.toInt()}\$'),
          const SizedBox(height: 24),
          // Buttons
          Row(children: [
            Expanded(child: SizedBox(height: 36,
              child: OutlinedButton(onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.dark, side: const BorderSide(color: AppColors.dark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text('Reorder', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14))))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 36,
              child: ElevatedButton(onPressed: () {},
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text('Leave feedback', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500))))),
          ]),
          const SizedBox(height: 24),
        ])),
    );
  }

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey))),
      Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark))),
    ]));
}
