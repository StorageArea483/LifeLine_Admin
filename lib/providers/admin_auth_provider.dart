import 'package:flutter_riverpod/legacy.dart';

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  AdminAuthNotifier()
    : super(
        const AdminAuthState(
          obscureTextField: false,
          obscurePassword: false,
          isLoading: false,
        ),
      );

  void toggleObscureTextField() {
    state = state.copyWith(obscureTextField: !state.obscureTextField);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

class AdminAuthState {
  final bool obscureTextField;
  final bool obscurePassword;
  final bool isLoading;

  const AdminAuthState({
    this.obscureTextField = false,
    this.obscurePassword = false,
    this.isLoading = false,
  });

  AdminAuthState copyWith({
    bool? obscureTextField,
    bool? obscurePassword,
    bool? isLoading,
  }) {
    return AdminAuthState(
      obscureTextField: obscureTextField ?? this.obscureTextField,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final adminAuthPageProvider =
    StateNotifierProvider.autoDispose<AdminAuthNotifier, AdminAuthState>((ref) {
      return AdminAuthNotifier();
    });
