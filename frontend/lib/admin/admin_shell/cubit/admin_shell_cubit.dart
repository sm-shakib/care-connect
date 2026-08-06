import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin_navigation.dart';
import 'admin_shell_state.dart';

/// Tracks which tab is currently selected in the persistent admin
/// shell and manages the layout/order of tabs in the bottom nav bar
/// vs the "More" menu.
class AdminShellCubit extends Cubit<AdminShellState> {
  AdminShellCubit()
      : super(
          const AdminShellState(
            selectedTab: AdminTab.users,
            barTabs: [
              AdminTab.users,
              AdminTab.verification,
              AdminTab.complaints,
              AdminTab.more,
            ],
            moreTabs: [
              AdminTab.central_fund,
              AdminTab.bookings,
            ],
          ),
        );

  void selectTab(AdminTab tab) {
    if (tab == state.selectedTab) return;
    emit(state.copyWith(selectedTab: tab));
  }

  /// Swaps two tabs within the bottom nav bar.
  void swapBarTabs(int indexA, int indexB) {
    final newBarTabs = List<AdminTab>.from(state.barTabs);
    final temp = newBarTabs[indexA];
    newBarTabs[indexA] = newBarTabs[indexB];
    newBarTabs[indexB] = temp;
    emit(state.copyWith(barTabs: newBarTabs));
  }

  /// Replaces a tab in the bottom nav bar with one from the "More" menu.
  /// The replaced bar tab moves to the "More" menu at the same relative position.
  void swapBarWithMore(AdminTab fromMore, AdminTab inBar) {
    final barIndex = state.barTabs.indexOf(inBar);
    final moreIndex = state.moreTabs.indexOf(fromMore);
    
    if (barIndex == -1 || moreIndex == -1) return;

    final newBarTabs = List<AdminTab>.from(state.barTabs);
    final newMoreTabs = List<AdminTab>.from(state.moreTabs);

    newBarTabs[barIndex] = fromMore;
    newMoreTabs[moreIndex] = inBar;

    emit(state.copyWith(barTabs: newBarTabs, moreTabs: newMoreTabs));
  }
}
