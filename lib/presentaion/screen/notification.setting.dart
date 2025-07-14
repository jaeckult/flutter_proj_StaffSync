import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/user/user_cubit.dart';

void main() {
  runApp(MaterialApp(
    home: NotificationSetting(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  bool isOn = true;
  bool isDropdownExpanded = false;
  String selectedOption = 'Only my activities';
  @override
  Widget build(BuildContext context) {
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
                    setState(() {
                      isOn = value;
                    });
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
        context.read<UserCubit>().deleteNotification();
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
        context.read<UserCubit>().deleteNotification();
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
