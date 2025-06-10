import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

void main() {
  runApp(MaterialApp(
    home: NotificationSetting(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotificationSetting extends ConsumerStatefulWidget {
  const NotificationSetting({super.key});

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends ConsumerState<NotificationSetting> {
  bool isNotificationOn = true;
  bool isDropdownExpanded = false;
  String selectedOption = 'Only my activities';
  @override
  Widget build(BuildContext context) {
    final isOn = ref.watch(toggleProvider);
    final delete =  ref.read(userNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Setting', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Turn notifications on or off'),
                Switch(
                  value: isOn,
                  activeColor: Colors.deepOrange,
                  onChanged: (value) {
                    ref.read(toggleProvider.notifier).set(value);
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    GestureDetector(
      onTap: () {
        delete.deleteNotification();
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cleared Notification')));
           
        
      },
      child: const Text(
        'Clear Notifications',
        style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        delete.deleteNotification();
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cleared Notification')));
           
        
        
      },
      child: Icon(Icons.delete, color: Colors.deepOrange),
    ),
  ],
),

              
          ],
        ),
      ),
    );
  }
}
