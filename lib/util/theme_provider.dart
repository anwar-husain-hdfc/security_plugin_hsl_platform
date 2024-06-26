import 'package:flutter/material.dart';

class ThemeGlobal extends ChangeNotifier {
  ThemeGlobal(this.isDarkThemeEnabled) {
    if (isDarkThemeEnabled)
      activateDarkMode();
    else
      activateDefaultMode();
    toastBG = Color(0xffeeeeee).withOpacity(.9);
  }

  Color? textColor;
  Color? bgColor;
  Color? iconColor;
  Color? cursorColor;
  Color? toastBG;
  Color? scaffoldBG;
  Color? foregroundTint;
  Color circularProgressIndicator = Colors.black;
  Color? dropdownBG;

  Color WHITE_COLOR = const Color(0xffffffff);
  Color APP_COLOR = const Color(0xff0085FF);
  Color BUTTON_LOADED_COLOR = const Color(0xff006AFB);
  Color APP_COLOR_100 = const Color(0x1f0085FF);
  Color HEADING_COLOR = const Color(0xff161d28);
  Color BODY_TEXT_COLOR = const Color(0xff030f23);
  Color NAVY_BLUE = const Color(0xff0a1c63);
  Color BUY_BUTTON_COLOR = const Color(0xff0EB479);
  Color BUY_COLOR = const Color(0xff087B59);
  Color TEXT_GREEN_COLOR = const Color(0xff028737);
  Color LIGHT_GREEN = const Color(0xff087B59).withOpacity(0.12);
  Color GREEN_300 = const Color(0xff25A8A0);
  Color GREEN = const Color(0xff028737);
  Color SELL_COLOR = const Color(0xffDE2020);
  Color LIGHT_RED = const Color(0xffDE2020).withOpacity(0.12);
  Color ORANGE_COLOR = const Color(0xffFF5C00);
  Color LIGHT_ORANGE = const Color(0xffFF5C00).withOpacity(0.12);
  Color DARK_ORANGE = const Color(0xffDD5000);
  Color PURPLE_COLOR = const Color(0xff481B98);
  Color DARK_PURPLE = const Color(0xff3C64B1);
  Color LIGHT_PURPLE = const Color(0xff9872DC).withOpacity(0.16);
  Color PINK_COLOR = const Color(0xffCD2174);
  Color LIGHT_PINK = const Color(0xffCD2174).withOpacity(0.12);
  Color YELLOW = const Color(0xffFB9716);
  Color LIGHT_GREY = const Color(0xff001833).withOpacity(0.4);
  Color GREY = const Color(0xff333333);
  static const SELL_COLOR_100 = const Color(0x1fe63939);
  static const DIALOG_BG = const Color(0x5f000000);
  Color GREY_300 = const Color(0xffd1d6dc);
  Color SELL_COLOR_300 = const Color(0x29DE2020);
  Color BLUE_900 = const Color(0xff01060F);
  Color BLUE_200 = const Color(0xff65AAFB);
  static const BLUE_300 = const Color(0xff25CAD1);
  static const GREY_900 = const Color(0xff161D28);
  static const GREY_400 = const Color(0xff2E3B47);
  static const PURPLE_100 = const Color(0xff7272EE);
  static const PURPLE_500 = const Color(0xff5855FF);
  static const PURPLE_600 = const Color(0xff9D55E4);
  static const PURPLE_700 = const Color(0xff550F8B);
  static const YELLOW_100 = const Color(0xffFFEEDD);
  static const YELLOW_200 = const Color(0xffF1D8BF);
  static const BLUE_100 = const Color(0xffD2FFF7);
  static const GREEN_200 = const Color(0xff309280);
  static const GREY_50 = const Color(0xff808387);
  static const GREY_30 = const Color(0xffb3b4b7);
  static const BG_GREY = const Color(0xfff4f4f4);
  static const DARK_GREY = const Color(0xff01060F);
  static const CYAN = const Color(0xff00C9F2);
  static const ORANGE_TEXT = const Color.fromRGBO(235, 129, 5, 1);
  static const SCAFFOLD_BG_GREY = const Color(0xffF1F1F1);
  Color DARK_BLUE = const Color(0xff246BBE);
  Color LIGHT_BLUE = const Color(0xff4095E1);
  Color COMPARE_MF_BACKGROUND = const Color(0xffFAFAFA);
  ThemeData? themeData;

  bool isDarkThemeEnabled;

/// order status colors value
  static const ORDER_SUCCESS = const Color(0xff087B59);
  static const ORDER_REJECTED = const Color(0xffDE2020);
  static const ORDER_MODIFIED = const Color(0xff246BBE);
  static const ORDER_PENDING = const Color(0xffFB9716);
  static const ORDER_CANCELLED = const Color(0xffDE2020);

   /// option chain UI colors
  Color OC_TAB_INDICATOR = const Color(0xFF2850E7);
  Color OC_ITM_COLOR = const Color(0xFFFFFBF4);
  Color OC_ITM_CALL = const Color(0xFFF5C6AE);
  Color OC_ITM_PUT = const Color(0xFFAECC8B);
  
 /// Transaction History Order Type Color
  static const PENDING_TSCT = const Color.fromRGBO(251, 148, 72, 1);
  static const INVESTED_TSCT = const Color.fromRGBO(0, 133, 255, 1);
  static const REJECTED_TSCT = const Color.fromRGBO(238, 79, 79, 1);



  /*Future<void> changeColor() async {
    isDarkThemeEnabled = !isDarkThemeEnabled;
    await (await SharedPreferences.getInstance())
        .setBool(ApiConstants.DARK_MODE, isDarkThemeEnabled);
    if (isDarkThemeEnabled)
      activateDarkMode();
    else
      activateDefaultMode();

    notifyListeners();
  }*/

  void activateDarkMode() {
    textColor = Colors.white;
    // bgColor = Color(0xff00243E);
    // bgColor = Color(0xff032b3c);
    bgColor = Color(0xff002033);

    iconColor = Colors.white;
    cursorColor = Colors.white;
    // scaffoldBG = Color(0xff002f48);
    scaffoldBG = Color(0xff002440);

    // lightBG = Color(0xff173d55);
    foregroundTint = Colors.black.withOpacity(0.4);
    dropdownBG = Colors.white;

    themeData = _themeData(ThemeData.dark(), textColor, bgColor, iconColor);
  }

  void activateDefaultMode() {
    textColor = Color(0xff001B33);
    bgColor = Color(0xffFAFAFA);
    iconColor = Colors.grey[800];
    cursorColor = Colors.grey[800];
    scaffoldBG = Color(0xffFAFAFA);
    foregroundTint = Color(0xffFAFAFA).withOpacity(0.4);
    dropdownBG = Color(0xffe0e1ed).withOpacity(1);
    circularProgressIndicator = APP_COLOR;

    final theme = ThemeData(
      useMaterial3: false,
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(width: 1.5, color: this.APP_COLOR),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.transparent));
    themeData = _themeData(theme, textColor, bgColor, iconColor);
  }
}

ThemeData _themeData(
    ThemeData base, Color? textColor, Color? bgColor, Color? iconColor) {
  TextTheme _appTextTheme(TextTheme base) {
    return _textTheme(base, textColor!);
  }

  return base.copyWith(
    textTheme: _appTextTheme(
      base.textTheme,
    ),
    scaffoldBackgroundColor: bgColor,
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: iconColor,
        ),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: bgColor),
  );
}

TextTheme _textTheme(TextTheme base, Color textColor) {
  return base.copyWith(
    displayLarge: base.displayLarge!.copyWith(
        inherit: true,
        fontSize: 34.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.3),
    displayMedium: base.displayMedium!.copyWith(
        inherit: true,
        fontSize: 28.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.3),
    displaySmall: base.displaySmall!.copyWith(
        inherit: true,
        fontSize: 22.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.3),
    headlineMedium: base.headlineMedium!.copyWith(
        inherit: true,
        fontSize: 18.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.3),
    headlineSmall: base.headlineSmall!.copyWith(
        inherit: true,
        fontSize: 16.0,
        color: textColor,
        fontFamily: 'Satoshi',
        height: 1.3),
    titleLarge: base.titleLarge!.copyWith(
        inherit: true,
        fontSize: 14.0,
        color: textColor.withOpacity(0.6),
        fontFamily: 'Satoshi',
        height: 1.4),
    titleMedium: base.titleMedium!.copyWith(
        inherit: true,
        fontSize: 12.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.4),
    titleSmall: base.titleSmall!.copyWith(
        inherit: true,
        fontSize: 14.0,
        color: textColor.withOpacity(0.8),
        fontFamily: 'Satoshi',
        height: 1.4),
    bodyLarge: base.bodyLarge!.copyWith(
        inherit: true,
        fontSize: 13.0,
        color: textColor,
        fontFamily: 'Satoshi',
        height: 1.4),
    bodyMedium: base.bodyMedium!.copyWith(
        inherit: true,
        fontSize: 11.0,
        color: textColor,
        fontFamily: 'Satoshi',
        height: 1.4),
  );
}
