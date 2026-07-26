import 'package:equatable/equatable.dart';
import '../models/elder.dart';

class FamilyDashboardState extends Equatable {
  const FamilyDashboardState({
    this.elders = const [],
    this.filteredElders = const [],
    this.selectedElder,
    this.bookingForElder,
  });

  final List<Elder> elders;
  final List<Elder> filteredElders;
  final Elder? selectedElder;
  final Elder? bookingForElder;

  // Pattern to allow null values in copyWith
  FamilyDashboardState copyWith({
    List<Elder>? elders,
    List<Elder>? filteredElders,
    Elder? Function()? selectedElder,
    Elder? Function()? bookingForElder,
  }) {
    return FamilyDashboardState(
      elders: elders ?? this.elders,
      filteredElders: filteredElders ?? this.filteredElders,
      selectedElder: selectedElder != null ? selectedElder() : this.selectedElder,
      bookingForElder: bookingForElder != null ? bookingForElder() : this.bookingForElder,
    );
  }

  @override
  List<Object?> get props => [
        elders,
        filteredElders,
        selectedElder,
        bookingForElder,
      ];
}
