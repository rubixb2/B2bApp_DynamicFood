import 'package:flutter/material.dart';

// Renk Paleti
class AppColors {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF8900EE);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color dangerColor = Color(0xFFB00020);
  static const Color confirmColor = Color(0xFF4CAF50);
  static const Color neutralColor = Color(0xFF9E9E9E);
  static const Color textColor = Color(0xFF333333);
  static const Color textColorWhite = Color(0xFFffffff);

  /*Primary (Ana): 0xFF6200EE (Mor)
Secondary (İkincil): 0xFF03DAC6 (Turkuaz)
Danger (Tehlike): 0xFFB00020 (Kırmızı)
Confirm (Onay): 0xFF4CAF50 (Yeşil)
Neutral (Nötr): 0xFF9E9E9E (Gri)*/
}

// Metin Stilleri
class AppTextStyles {
  static const TextStyle list1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle list2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static const TextStyle list3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );



  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );
  static const TextStyle bodyTextBold = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle buttonTextBlack = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle buttonTextWhite = TextStyle(
    fontSize: 16,
    color: AppColors.textColorWhite,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyTextBold2 = TextStyle(
    fontSize: 13,
    color: AppColors.textColor,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subText = TextStyle(
    fontSize: 13,
    color: AppColors.textColor,
  );
}

// Buton Stilleri
class AppButtonStyles {
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
  static final ButtonStyle confimButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.confirmColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
  static final ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.dangerColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
  static final ButtonStyle notrButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.neutralColor,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
