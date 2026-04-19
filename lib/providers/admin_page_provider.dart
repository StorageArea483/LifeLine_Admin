import 'package:flutter_riverpod/legacy.dart';

class AdminPageNotifier extends StateNotifier<AdminPageState> {
  AdminPageNotifier()
    : super(AdminPageState(isLoading: false, ngoRequests: []));

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void addNgoRequest(Map<String, dynamic> request) {
    state = state.copyWith(ngoRequests: [...state.ngoRequests, request]);
  }
}

class AdminPageState {
  final bool isLoading;
  final List<Map<String, dynamic>> ngoRequests;

  AdminPageState({required this.isLoading, required this.ngoRequests});

  AdminPageState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? ngoRequests,
  }) {
    return AdminPageState(
      isLoading: isLoading ?? this.isLoading,
      ngoRequests: ngoRequests ?? this.ngoRequests,
    );
  }
}

final adminPageProvider =
    StateNotifierProvider<AdminPageNotifier, AdminPageState>((ref) {
      return AdminPageNotifier();
    });
