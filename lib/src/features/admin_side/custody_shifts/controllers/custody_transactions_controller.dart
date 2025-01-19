import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/app_init.dart';
import '../../../cashier_side/main_screen/components/models.dart';

class CustodyTransactionsController extends GetxController {
  CustodyTransactionsController({required this.custodyReportId});
  final String custodyReportId;
  final RxBool isLoading = false.obs;
  final int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxList<CustodyTransaction> data = <CustodyTransaction>[].obs;
  final RxInt totalItems = 0.obs;
  final RxInt initialRow = 0.obs;
  final RxInt currentSelectedStatus = 0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int currentStartIndex = 0;
  final RefreshController transactionsRefreshController =
      RefreshController(initialRefresh: false);
  @override
  void onInit() {
    super.onInit();
    fetchData(start: currentStartIndex);
  }

  void resetTableValues() {
    data.clear();
    currentStartIndex = 0;
  }

  Future<void> fetchData({
    int start = 0,
    int limit = 10,
    bool ascending = false,
  }) async {
    if (isLoading.value) return;

    if (start == currentStartIndex && data.isNotEmpty) return;

    try {
      isLoading.value = true;
      currentStartIndex = start;

      Query query = _firestore
          .collection('custody_shifts')
          .doc(custodyReportId)
          .collection('transactions');

      if (start != 0) {
        query = query.startAfter([data[start].timestamp]);
      }
      final querySnapshot = await query.limit(limit).get();

      data.value = querySnapshot.docs
          .map((doc) => CustodyTransaction.fromFirestore(doc))
          .toList();

      totalItems.value = querySnapshot.size;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onTransactionsRefresh() {
    resetTableValues();
    fetchData(start: currentStartIndex);
    transactionsRefreshController.refreshCompleted();
  }
}

//   Future<List<CustodyTransaction>?> fetchTransactions(String reportId) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('custody_reports')
//           .doc(reportId)
//           .collection('transactions')
//           .get();
//
//       return querySnapshot.docs
//           .map((doc) => CustodyTransaction.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch transactions: $e');
//  if (kDebugMode) {
//         AppInit.logger.e(e.toString());
//       }
//     }
//     return null;
//   }
