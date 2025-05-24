import 'package:flutter_riverpod/flutter_riverpod.dart';
class ToggleNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state != state; //negate the state
  void set(bool value) => state = value;
}