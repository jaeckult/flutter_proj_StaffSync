import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/application/bloc/user/user_cubit.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/presentaion/widgets/profile_picture_widget.dart';
import 'package:staffsync/presentaion/widgets/shimmer_skeletons.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state;

    return FutureBuilder<List<NotificationModel>>(
      future: context.read<UserCubit>().getNotificationMessage(),
      builder: (context, snapshot) {
        int notificationCount = 0;
        if (snapshot.hasData) {
          notificationCount = snapshot.data!.length;
        }
        if (user == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: const [
                    ShimmerCircle(size: 48),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerListTile()),
                  ],
                ),
              ),
            ),
          );
        }

        return ListTile(
          leading: ProfilePictureWidget(
            profilePicture: user.profile.profilePicture,
            radius: 24,
          ),
          title: Text(
            user.profile.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.profile.designation),
          trailing: GestureDetector(
            onTap: () => context.push('/notification'),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none, size: 28),
                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
