import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin_navigation.dart';

/// Tracks which tab is currently selected in the persistent admin
/// shell. State is just the [AdminTab] itself — no need for a bigger
/// state class for a single value like this.
class AdminShellCubit extends Cubit<AdminTab> {
  AdminShellCubit() : super(AdminTab.dashboard);

  void selectTab(AdminTab tab) {
    if (tab == state) return;
    emit(tab);
  }
}