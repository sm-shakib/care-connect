import 'package:equatable/equatable.dart';

import '../models/elder.dart';

class FamilyDashboardState extends Equatable {
  const FamilyDashboardState({
    this.elders = const [],
    this.filteredElders = const [],
    this.selectedElder,
  });

  final List<Elder> elders;
  final List<Elder> filteredElders;
  final Elder? selectedElder;

  FamilyDashboardState copyWith({
    List<Elder>? elders,
    List<Elder>? filteredElders,
    Elder? selectedElder,
  }) {
    return FamilyDashboardState(
      elders: elders ?? this.elders,
      filteredElders: filteredElders ?? this.filteredElders,
      selectedElder: selectedElder ?? this.selectedElder,
    );
  }

  @override
  List<Object?> get props => [
    elders,
    filteredElders,
    selectedElder,
  ];
}