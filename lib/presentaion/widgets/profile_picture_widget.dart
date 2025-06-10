import 'dart:convert';
import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePicture;
  final double radius;
  final VoidCallback? onTap;

  const ProfilePictureWidget({
    super.key,
    required this.profilePicture,
    this.radius = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(profilePicture!);
        imageWidget = CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        imageWidget = CircleAvatar(
          radius: radius,
          backgroundImage: const AssetImage('assets/profile.png'),
        );
      }
    } else {
      imageWidget = CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/profile.png'),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            imageWidget,
            Positioned(
              bottom: 0,
              right: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      );
    }

    return imageWidget;
  }
} 