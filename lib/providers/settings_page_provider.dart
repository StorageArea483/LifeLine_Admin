import 'package:flutter_riverpod/legacy.dart';

class SettingsPageNotifier extends StateNotifier<SettingsPageState> {
  SettingsPageNotifier()
    : super(
        SettingsPageState(
          isLoading: false,
          autoApprovalMode: false,
          sosSystemEnabled: false,
          systemMaintenance: false,
        ),
      );

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setAutoApprovalMode(bool autoApprovalMode) {
    state = state.copyWith(autoApprovalMode: autoApprovalMode);
  }

  void setSosSystemEnabled(bool sosSystemEnabled) {
    state = state.copyWith(sosSystemEnabled: sosSystemEnabled);
  }

  void setSystemMaintenance(bool systemMaintenance) {
    state = state.copyWith(systemMaintenance: systemMaintenance);
  }
}

class SettingsPageState {
  final bool isLoading;
  final bool autoApprovalMode;
  final bool sosSystemEnabled;
  final bool systemMaintenance;

  SettingsPageState({
    required this.isLoading,
    required this.autoApprovalMode,
    required this.sosSystemEnabled,
    required this.systemMaintenance,
  });

  SettingsPageState copyWith({
    bool? isLoading,
    bool? autoApprovalMode,
    bool? sosSystemEnabled,
    bool? systemMaintenance,
  }) {
    return SettingsPageState(
      isLoading: isLoading ?? this.isLoading,
      autoApprovalMode: autoApprovalMode ?? this.autoApprovalMode,
      sosSystemEnabled: sosSystemEnabled ?? this.sosSystemEnabled,
      systemMaintenance: systemMaintenance ?? this.systemMaintenance,
    );
  }
}

final settingsPageProvider =
    StateNotifierProvider<SettingsPageNotifier, SettingsPageState>((ref) {
      return SettingsPageNotifier();
    });

// Family provider to track each settings card's expanded state independently
final settingsCardExpandedProvider = StateProvider.family<bool, String>(
  (ref, cardId) => false,
);
