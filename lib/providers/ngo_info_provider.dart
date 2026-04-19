import 'package:flutter_riverpod/legacy.dart';

class NgoInfoNotifier extends StateNotifier<NgoInfoState> {
  NgoInfoNotifier()
    : super(
        const NgoInfoState(
          isLoading: false,
          isSearching: false,
          ngos: [],
          allNgos: [],
          blockedNgos: {},
        ),
      );

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setIsSearching(bool searching) {
    state = state.copyWith(isSearching: searching);
  }

  void addNgo(Map<String, dynamic> ngo) {
    state = state.copyWith(ngos: [...state.ngos, ngo]);
  }

  void addAllNgos(Map<String, dynamic> allNgos) {
    state = state.copyWith(allNgos: [...state.allNgos, allNgos]);
  }

  void addBlockedNgo(String blockedNgo) {
    state = state.copyWith(blockedNgos: {...state.blockedNgos, blockedNgo});
  }
}

class NgoInfoState {
  final bool isLoading;
  final bool isSearching;
  final List<Map<String, dynamic>> ngos;
  final List<Map<String, dynamic>> allNgos;
  final Set<String> blockedNgos;

  const NgoInfoState({
    this.isLoading = false,
    this.isSearching = false,
    this.ngos = const [],
    this.allNgos = const [],
    this.blockedNgos = const {},
  });

  NgoInfoState copyWith({
    bool? isLoading,
    bool? isSearching,
    List<Map<String, dynamic>>? ngos,
    List<Map<String, dynamic>>? allNgos,
    Set<String>? blockedNgos,
  }) {
    return NgoInfoState(
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      ngos: ngos ?? this.ngos,
      allNgos: allNgos ?? this.allNgos,
      blockedNgos: blockedNgos ?? this.blockedNgos,
    );
  }
}

final ngoPageProvider = StateNotifierProvider<NgoInfoNotifier, NgoInfoState>((
  ref,
) {
  return NgoInfoNotifier();
});
