import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class NotificationHandler {
  static void sendNotification({title, body, to}) async {
    var serverKey =
        'AAAAp71RWqI:APA91bFN6RKoSW94151WuA1UTx5azoz-WGWh374X5cKxOdL_mItb7hMiF96oGKS6J4tGh1tulvprTS6EfvorLaAkFEyRr-qbaKqGX1E6CxYlCwjOiJMjkVcIgXaVr-jBWe8qS3AkGVxF';
    try {


      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': to,
          },
        ),
      );
    } catch (e) {
      log("error push notification");
    }
  }
}
