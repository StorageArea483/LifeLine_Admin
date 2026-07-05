import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class AdminPageNotifier extends StateNotifier<AdminPageState> {
  AdminPageNotifier()
    : super(
        AdminPageState(
          isLoading: false,
          ngoRequests: [],
          victimCount: 0,
          ngoCount: 0,
          onGoingOperations: 0,
        ),
      );

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setNgoRequests(List<Map<String, dynamic>> requests) {
    if (listEquals(state.ngoRequests, requests)) return;
    state = state.copyWith(ngoRequests: requests);
  }

  void setVictimCount(int count) {
    state = state.copyWith(victimCount: count);
  }

  void setNgoCount(int count) {
    state = state.copyWith(ngoCount: count);
  }

  void setOngoingOperationsCount(int count) {
    state = state.copyWith(onGoingOperations: count);
  }
}

class AdminPageState {
  final bool isLoading;
  final List<Map<String, dynamic>> ngoRequests;
  final int victimCount;
  final int ngoCount;
  final int onGoingOperations;

  AdminPageState({
    required this.isLoading,
    required this.ngoRequests,
    required this.victimCount,
    required this.ngoCount,
    required this.onGoingOperations,
  });

  AdminPageState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? ngoRequests,
    int? victimCount,
    int? ngoCount,
    int? onGoingOperations,
  }) {
    return AdminPageState(
      isLoading: isLoading ?? this.isLoading,
      ngoRequests: ngoRequests ?? this.ngoRequests,
      victimCount: victimCount ?? this.victimCount,
      ngoCount: ngoCount ?? this.ngoCount,
      onGoingOperations: onGoingOperations ?? this.onGoingOperations,
    );
  }
}

final adminPageProvider =
    StateNotifierProvider<AdminPageNotifier, AdminPageState>((ref) {
      return AdminPageNotifier();
    });
