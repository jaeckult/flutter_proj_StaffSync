import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityItem extends StatelessWidget {
  final DateTime date;
  final DateTime time;
  final String type;
  final String status;
  final int id;
  final VoidCallback? onDelete;

  const ActivityItem({
    super.key,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.id,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              type == 'Check In' ? Colors.green : const Color.fromARGB(255, 162, 93, 68),
          child: Icon(
            type == 'Check In' ? Icons.login : Icons.logout,
            color: Colors.white,
          ),
        ),
        title: Text(type),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy').format(date)} at ${DateFormat('hh:mm a').format(time)}',
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
