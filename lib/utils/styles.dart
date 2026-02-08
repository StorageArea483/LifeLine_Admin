import 'package:flutter/material.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryMaroon,
        secondary: AppColors.accentRose,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.softBackground,
      fontFamily: 'SFPro',
    );
  }
}

class SimpleDecoration {
  static BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration container() {
    return const BoxDecoration(color: Colors.white);
  }

  static BoxDecoration table() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

class AppDecorations {
  static const double cardRadius = 12;
  static const double textFieldRadius = 8;
  static const double primaryButtonRadius = 8;
  static const double submitButtonRadius = 8;

  static const LinearGradient pageLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7E8EC), Color(0xFFFFFBFC)],
  );
}

class AppText {
  static const TextStyle base = TextStyle(fontFamily: 'SFPro');

  static final TextStyle appHeader = base.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.darkCharcoal,
  );

  static final TextStyle welcomeTitle = base.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: AppColors.darkCharcoal,
  );

  static final TextStyle formTitle = base.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.darkCharcoal,
  );

  static final TextStyle subtitle = base.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static final TextStyle formDescription = base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static final TextStyle fieldLabel = base.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.darkCharcoal,
  );

  static final TextStyle small = base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static final TextStyle link = base.copyWith(
    fontSize: 14,
    color: AppColors.primaryMaroon,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle submitButton = base.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.white,
  );

  static final TextStyle textFieldHint = base.copyWith(
    color: AppColors.textSecondary,
  );
}

class AppButtons {
  static final ButtonStyle submit = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryMaroon,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDecorations.submitButtonRadius),
    ),
    foregroundColor: Colors.white,
  );
}

class AppContainers {
  static const BoxDecoration pageContainer = BoxDecoration(
    gradient: AppDecorations.pageLinearGradient,
  );
}

class AppTextFields {
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppText.textFieldHint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.textFieldRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
}

class AppSizes {
  static const double submitButtonHeight = 48;
  static const double iconSize = 24;
}
