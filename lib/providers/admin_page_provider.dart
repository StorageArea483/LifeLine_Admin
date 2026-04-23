import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class AdminPageNotifier extends StateNotifier<AdminPageState> {
  AdminPageNotifier()
    : super(AdminPageState(isLoading: false, ngoRequests: []));

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setNgoRequests(List<Map<String, dynamic>> requests) {
    if (listEquals(state.ngoRequests, requests)) return;
    state = state.copyWith(ngoRequests: requests);
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
