import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../data/dummy/dummy_orders.dart';
import '../../data/models/order.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(elevation: 0, backgroundColor: AppColors.background, centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), color: AppColors.dark, onPressed: () => Navigator.pop(context)),
          title: const Text('My Orders', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
          bottom: const TabBar(
            labelColor: AppColors.dark, unselectedLabelColor: AppColors.grey, indicatorColor: AppColors.dark,
            labelStyle: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontFamily: 'Metropolis', fontSize: 14),
            tabs: [Tab(text: 'Delivered'), Tab(text: 'Processing'), Tab(text: 'Cancelled')])),
        body: TabBarView(children: [
          _orderList(OrderStatus.delivered, context),
          _orderList(OrderStatus.processing, context),
          _orderList(OrderStatus.cancelled, context),
        ]),
      ));
  }

  Widget _orderList(OrderStatus status, BuildContext context) {
    final orders = dummyOrders.where((o) => o.status == status).toList();
    if (orders.isEmpty) return const Center(child: Text('No orders', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, color: AppColors.grey)));
    return ListView.separated(padding: const EdgeInsets.all(16),
      itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i],
        onTap: () => Navigator.of(context).pushNamed('/order-detail', arguments: orders[i])));
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Order №${order.orderNumber}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
            Text('${order.date.day}-${order.date.month}-${order.date.year}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Tracking number: ', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
            Text(order.trackingNumber, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Text('Quantity: ', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
              Text('${order.itemCount}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
              const SizedBox(width: 16),
              const Text('Total Amount: ', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
              Text('${order.totalAmount.toInt()}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
            ]),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(width: 100, height: 36,
              child: OutlinedButton(onPressed: onTap,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.dark, side: const BorderSide(color: AppColors.dark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500)),
                child: const Text('Details'))),
            Text(order.statusLabel, style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500,
              color: order.status == OrderStatus.delivered ? AppColors.success
                   : order.status == OrderStatus.cancelled ? AppColors.error : AppColors.dark)),
          ]),
        ])));
  }
}
