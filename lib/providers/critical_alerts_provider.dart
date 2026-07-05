import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class CriticalAlertNotifier extends StateNotifier<CriticalAlertState> {
  CriticalAlertNotifier()
    : super(
        const CriticalAlertState(victimLocations: [], rescuerLocations: []),
      );

  void setVictimLocations(List<Map<String, dynamic>> locations) {
    if (listEquals(state.victimLocations, locations)) return;
    state = state.copyWith(victimLocations: locations);
  }

  void setRescuerLocations(List<Map<String, dynamic>> locations) {
    if (listEquals(state.rescuerLocations, locations)) return;
    state = state.copyWith(rescuerLocations: locations);
  }
}

class CriticalAlertState {
  final List<Map<String, dynamic>> victimLocations;
  final List<Map<String, dynamic>> rescuerLocations;

  const CriticalAlertState({
    this.victimLocations = const [],
    this.rescuerLocations = const [],
  });
  CriticalAlertState copyWith({
    List<Map<String, dynamic>>? victimLocations,
    List<Map<String, dynamic>>? rescuerLocations,
  }) {
    return CriticalAlertState(
      victimLocations: victimLocations ?? this.victimLocations,
      rescuerLocations: rescuerLocations ?? this.rescuerLocations,
    );
  }
}

final criticalAlertsProvider =
    StateNotifierProvider<CriticalAlertNotifier, CriticalAlertState>(
      (ref) => CriticalAlertNotifier(),
    );
