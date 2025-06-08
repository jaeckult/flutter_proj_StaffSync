import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/presentaion/screen/managerHome.dart';


void main() {
  runApp(ProviderScope(child: MaterialApp(home: NotificationList())));
}

class NotificationList extends ConsumerStatefulWidget {
  @override
  ConsumerState<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends ConsumerState<NotificationList> {
  late Future<List<NotificationModel>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture =
        ref.read(userNotifierProvider.notifier).getNotificationMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!;
          return ListView.separated(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),child: ListTile(
              title: Text(
                        notifications[index].message,
                        style: TextStyle(fontWeight: FontWeight.bold)),

              ),);
            }, separatorBuilder: (BuildContext context, int index) =>  Divider(),
          );
        },
      ),
    );
  }
}
