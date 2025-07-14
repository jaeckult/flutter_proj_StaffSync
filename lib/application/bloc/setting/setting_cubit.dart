import 'package:flutter_bloc/flutter_bloc.dart';

class SettingCubit extends Cubit<bool> {
  SettingCubit() : super(false);

  void toggle() => emit(!state);
  void set(bool value) => emit(value);
}
