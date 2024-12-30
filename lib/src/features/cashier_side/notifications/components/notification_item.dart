import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../general/general_functions.dart';

class NotificationItem {
  final String title;
  final String body;
  final Timestamp timestamp;

  NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }
}

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    super.key,
    required this.notificationItem,
  });

  final NotificationItem notificationItem;

  @override
  Widget build(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    final formattedDateTime = formatDateTime(notificationItem.timestamp);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
            )
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              notificationItem.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10.0),
            AutoSizeText(
              notificationItem.body,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              width: screenWidth,
              child: AutoSizeText(
                formattedDateTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingNotificationWidget extends StatelessWidget {
  const LoadingNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
            )
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 100,
                color: Colors.black,
              ),
              const SizedBox(height: 10.0),
              Container(
                height: 15,
                width: 200,
                color: Colors.black,
              ),
              const SizedBox(height: 10.0),
              Container(
                height: 15,
                width: 100,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
