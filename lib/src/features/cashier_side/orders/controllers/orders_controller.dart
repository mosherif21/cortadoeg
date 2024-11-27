import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final RxList<OrderModel> ordersList = <OrderModel>[].obs;
  final loadingOrders = true.obs;
  late final StreamSubscription ordersListener;
  @override
  void onInit() async {
    //
    super.onInit();
  }

  @override
  void onReady() {
    ordersListener = listenToTables().listen((tables) {
      ordersList.value = tables;
      loadingOrders.value = false;
    });
    super.onReady();
  }

  Stream<List<OrderModel>> listenToTables() {
    final CollectionReference tablesRef =
        FirebaseFirestore.instance.collection('orders');
    return tablesRef.snapshots().map((snapshot) {
      List<OrderModel> orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      orders.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return orders;
    });
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
