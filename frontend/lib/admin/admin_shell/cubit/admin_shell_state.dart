import 'package:equatable/equatable.dart';
import '../../admin_navigation.dart';

class AdminShellState extends Equatable {
  const AdminShellState({
    required this.selectedTab,
    required this.barTabs,
    required this.moreTabs,
  });

  final AdminTab selectedTab;
  final List<AdminTab> barTabs;
  final List<AdminTab> moreTabs;

  AdminShellState copyWith({
    AdminTab? selectedTab,
    List<AdminTab>? barTabs,
    List<AdminTab>? moreTabs,
  }) {
    return AdminShellState(
      selectedTab: selectedTab ?? this.selectedTab,
      barTabs: barTabs ?? this.barTabs,
      moreTabs: moreTabs ?? this.moreTabs,
    );
  }

  @override
  List<Object?> get props => [selectedTab, barTabs, moreTabs];
}
