import 'package:equatable/equatable.dart';

import 'user_management_filter.dart';
import 'user_model.dart';

enum UserManagementStatus { initial, loading, success, failure }

class UserManagementState extends Equatable {
  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const <UserAccount>[],
    this.filter = UserManagementFilter.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  final UserManagementStatus status;
  final List<UserAccount> users;
  final UserManagementFilter filter;
  final String searchQuery;
  final String? errorMessage;

  /// Users after applying the active filter chip and search query.
  List<UserAccount> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();
    return users.where((user) {
      final matchesFilter = filter.matches(user.role);
      final matchesSearch =
          query.isEmpty || user.name.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  bool get isLoading => status == UserManagementStatus.loading;

  bool get isEmpty =>
      status == UserManagementStatus.success && filteredUsers.isEmpty;

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<UserAccount>? users,
    UserManagementFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    filter,
    searchQuery,
    errorMessage,
  ];
}