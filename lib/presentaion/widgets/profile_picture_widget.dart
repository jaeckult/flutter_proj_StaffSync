import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatefulWidget {
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
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  Uint8List? _cachedImageBytes;
  String? _cachedProfilePicture;

  @override
  void didUpdateWidget(ProfilePictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache if profile picture changed
    if (oldWidget.profilePicture != widget.profilePicture) {
      _cachedImageBytes = null;
      _cachedProfilePicture = null;
    }
  }

  Uint8List? _getImageBytes() {
    // Return cached bytes if available and profile picture hasn't changed
    if (_cachedImageBytes != null && _cachedProfilePicture == widget.profilePicture) {
      return _cachedImageBytes;
    }

    // Decode and cache new image
    if (widget.profilePicture != null && widget.profilePicture!.isNotEmpty) {
      try {
        _cachedImageBytes = base64Decode(widget.profilePicture!);
        _cachedProfilePicture = widget.profilePicture;
        return _cachedImageBytes;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getImageBytes();
    
    Widget imageWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: imageBytes != null
          ? CircleAvatar(
              key: ValueKey(widget.profilePicture),
              radius: widget.radius,
              backgroundImage: MemoryImage(imageBytes),
              backgroundColor: Colors.grey[200],
            )
          : CircleAvatar(
              key: const ValueKey('default'),
              radius: widget.radius,
              backgroundImage: const AssetImage('assets/profile.png'),
              backgroundColor: Colors.grey[200],
            ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
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