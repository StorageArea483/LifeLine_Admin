import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class NgoInfoNotifier extends StateNotifier<NgoInfoState> {
  NgoInfoNotifier() : super(const NgoInfoState(isLoading: false, ngos: []));

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setNgos(List<Map<String, dynamic>> ngos) {
    if (listEquals(state.ngos, ngos)) return;
    state = state.copyWith(ngos: ngos);
  }
}

class NgoInfoState {
  final bool isLoading;
  final List<Map<String, dynamic>> ngos;

  const NgoInfoState({this.isLoading = false, this.ngos = const []});

  NgoInfoState copyWith({bool? isLoading, List<Map<String, dynamic>>? ngos}) {
    return NgoInfoState(
      isLoading: isLoading ?? this.isLoading,
      ngos: ngos ?? this.ngos,
    );
  }
}

final ngoPageProvider = StateNotifierProvider<NgoInfoNotifier, NgoInfoState>((
  ref,
) {
  return NgoInfoNotifier();
});
