import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_dto.dart';
import '../services/user_service.dart';
import '../../../core/network/models/paginated_list_dto.dart';

class UserState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<UserDto>? data;
  final String searchQuery;
  final int pageNumber;

  UserState({
    this.isLoading = false,
    this.error,
    this.data,
    this.searchQuery = '',
    this.pageNumber = 1,
  });

  UserState copyWith({
    bool? isLoading,
    String? error,
    PaginatedListDto<UserDto>? data,
    String? searchQuery,
    int? pageNumber,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class UserViewModel extends Notifier<UserState> {
  late final UserService _userService;

  @override
  UserState build() {
    _userService = ref.read(userServiceProvider);
    // Fetch initial data async
    Future.microtask(() => loadUsers());
    return UserState(isLoading: true);
  }

  Future<void> loadUsers({int? page, String? search}) async {
    final newPage = page ?? state.pageNumber;
    final newSearch = search ?? state.searchQuery;
    
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage, searchQuery: newSearch);

    try {
      final result = await _userService.getUsers(
        search: newSearch,
        pageNumber: newPage,
        pageSize: 10,
      );
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLockUser(int userId, bool currentIsLocked) async {
    try {
      if (currentIsLocked) {
        await _userService.unlockUser(userId);
      } else {
        await _userService.lockUser(userId);
      }
      
      // Update local state without full reload
      if (state.data != null) {
        final updatedItems = state.data!.items.map((user) {
          if (user.id == userId) {
            return user.copyWith(isLocked: !currentIsLocked);
          }
          return user;
        }).toList();
        
        final updatedData = PaginatedListDto<UserDto>(
          items: updatedItems,
          totalCount: state.data!.totalCount,
          pageNumber: state.data!.pageNumber,
          totalPages: state.data!.totalPages,
          hasPreviousPage: state.data!.hasPreviousPage,
          hasNextPage: state.data!.hasNextPage,
        );
        state = state.copyWith(data: updatedData);
      }
    } catch (e) {
      // Re-throw or handle error
      throw Exception('Failed to update user status: $e');
    }
  }
}

final userViewModelProvider = NotifierProvider<UserViewModel, UserState>(() {
  return UserViewModel();
});
