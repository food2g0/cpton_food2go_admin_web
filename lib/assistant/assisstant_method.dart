import 'dart:convert';
import 'package:http/http.dart' as http; // Import http package from http.dart

import 'package:cpton_food2go_admin_web/global/global.dart';

class AssistantMethods {
  static sendNotificationToUserNow(String registrationToken, String orderId) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingserverToken,
    };

    Map bodyNotification = {
      "body": "Your order has been cancelled due to wrong reference or invalid total amount.",
      "title": "Order Cancelled"
    };

    Map dataMap = {
      "clcik_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "ToPay",
      "orderId": orderId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": registrationToken,
    };

    var responseNotification = await http.post( // Await the http.post() call
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    // Handle response if needed
    if (responseNotification.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${responseNotification.statusCode}');
      print('Response body: ${responseNotification.body}');
    }
  }

  static sendNotificationToUserNowOrderApproved(String registrationToken, String orderId) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingserverToken,
    };

    Map bodyNotification = {
      "body": "Your G-cash Payment has been approved.",
      "title": "Order Approved"
    };

    Map dataMap = {
      "clcik_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "ToPay",
      "orderId": orderId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": registrationToken,
    };

    var responseNotification = await http.post( // Await the http.post() call
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    // Handle response if needed
    if (responseNotification.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${responseNotification.statusCode}');
      print('Response body: ${responseNotification.body}');
    }
  }

  static sendNotificationToSellersApplicationApproved(String registrationToken,) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingserverToken,
    };

    Map bodyNotification = {
      "body": "Your Application is approved please restart your app.",
      "title": "Congratulations"
    };

    Map dataMap = {
      "clcik_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "disapproved",

    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": registrationToken,
    };

    var responseNotification = await http.post( // Await the http.post() call
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    // Handle response if needed
    if (responseNotification.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${responseNotification.statusCode}');
      print('Response body: ${responseNotification.body}');
    }
  }

  static sendNotificationToRidersApplicationApproved(String registrationToken,) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingserverToken,
    };

    Map bodyNotification = {
      "body": "Your Application is approved please restart your app.",
      "title": "Congratulations"
    };

    Map dataMap = {
      "clcik_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "disapproved",

    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": registrationToken,
    };

    var responseNotification = await http.post( // Await the http.post() call
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    // Handle response if needed
    if (responseNotification.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${responseNotification.statusCode}');
      print('Response body: ${responseNotification.body}');
    }
  }
}
