import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: NotificationSetting(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotificationSetting extends StatefulWidget {
  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  bool isNotificationOn = true;
  bool isDropdownExpanded = false;
  String selectedOption = 'Only my activities';

  final List<Map<String, String>> options = [
    {
      'title': 'Only my activities',
      'description': 'Only be notified of your activity with managers.'
    },
    {
      'title': 'Only others activities',
      'description': 'Only be notified of others activities with managers.'
    },
    {
      'title': 'All activities',
      'description': 'Be notified of all the activities.'
    },
  ];

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
                  value: isNotificationOn,
                  activeColor: Colors.deepOrange,
                  onChanged: (value) {
                    setState(() {
                      isNotificationOn = value;
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  isDropdownExpanded = !isDropdownExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Get notified from', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                  Icon(Icons.expand_more, color: Colors.black),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose the activities you like to be notified about',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            if (isDropdownExpanded)
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: options.map((option) {
                    final isSelected = selectedOption == option['title'];
                    return ListTile(
                      onTap: () {
                        setState(() {
                          selectedOption = option['title']!;
                          isDropdownExpanded = false;
                        });
                      },
                      title: Text(option['title']!,
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          )),
                      subtitle: Text(option['description']!),
                      tileColor: isSelected ? Colors.orange.shade50 : Colors.white,
                    );
                  }).toList(),
                ),
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Clear Notifications', style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          )),
                Icon(Icons.delete, color:  Colors.deepOrange )
              ],
            ),
              
          ],
        ),
      ),
    );
  }
}
