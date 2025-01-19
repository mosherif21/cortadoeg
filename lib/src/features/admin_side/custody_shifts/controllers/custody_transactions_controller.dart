import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/app_init.dart';
import '../../../cashier_side/main_screen/components/models.dart';

class CustodyTransactionsController extends GetxController {
  CustodyTransactionsController({required this.custodyReportId});
  final String custodyReportId;
  final int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final List<CustodyTransaction> transactions = <CustodyTransaction>[];
  int totalTransactionsCount = 0;
  final RxInt currentSelectedStatus = 0.obs;
  DocumentSnapshot? lastDocument;
  late final GlobalKey<AsyncPaginatedDataTable2State> tableKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RefreshController transactionsRefreshController =
      RefreshController(initialRefresh: false);
  @override
  void onInit() {
    tableKey = GlobalKey<AsyncPaginatedDataTable2State>();
    super.onInit();
  }

  Future<void> fetchData({int start = 0, int limit = 10}) async {
    try {
      if (kDebugMode) {
        AppInit.logger.i('Fetching custody transactions');
      }
      Query query = _firestore
          .collection('custody_shifts')
          .doc(custodyReportId)
          .collection('transactions')
          .orderBy('timestamp', descending: true);

      if (start == 0) {
        final countSnapshot = await query.count().get();
        totalTransactionsCount = countSnapshot.count ?? 0;
        lastDocument = null;
      }
      if (start != 0 && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      final querySnapshot = await query.limit(limit).get();
      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
        if (start == 0) {
          transactions.assignAll(querySnapshot.docs
              .map((doc) => CustodyTransaction.fromFirestore(doc))
              .toList());
        } else {
          transactions.addAll(querySnapshot.docs
              .map((doc) => CustodyTransaction.fromFirestore(doc))
              .toList());
        }
      } else if (start == 0) {
        transactions.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  void onTransactionsRefresh() async {
    transactions.clear();
    lastDocument = null;
    totalTransactionsCount = 0;
    tableKey.currentState!.pageTo(0);
    transactionsRefreshController.refreshCompleted();
  }
}
