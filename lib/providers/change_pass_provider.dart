import 'package:flutter_riverpod/legacy.dart';

class ChangePassNotifier extends StateNotifier<ChangePassState> {
  ChangePassNotifier()
    : super(
        const ChangePassState(
          obscureNewPassword: false,
          obscureConfirmPassword: false,
          isLoading: false,
        ),
      );

  void toggleObscureNewPassword() {
    state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);
  }

  void toggleObscureConfirmPassword() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void setIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}

class ChangePassState {
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isLoading;

  const ChangePassState({
    this.obscureNewPassword = false,
    this.obscureConfirmPassword = false,
    this.isLoading = false,
  });

  ChangePassState copyWith({
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? isLoading,
  }) {
    return ChangePassState(
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final changePassProvider =
    StateNotifierProvider.autoDispose<ChangePassNotifier, ChangePassState>(
      (ref) => ChangePassNotifier(),
    );
