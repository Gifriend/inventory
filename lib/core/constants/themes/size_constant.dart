import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/core/utils/utils.dart';

enum ScreenDensity { ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi }

// [INFO]
// Constant for sizes to be used in the app with respecting 8 pixel rules
class BaseSize {
  // [INFO]
  // Sizes that related with width
  static double get w2 => 2.0.w;
  static double get w4 => 4.0.w;
  static double get w8 => 8.0.w;
  static double get w12 => 12.0.w;
  static double get w16 => 16.0.w;
  static double get w20 => 20.0.w;
  static double get w24 => 24.0.w;
  static double get w28 => 28.0.w;
  static double get w32 => 32.0.w;
  static double get w36 => 36.0.w;
  static double get w40 => 40.0.w;
  static double get w48 => 48.0.w;
  static double get w52 => 52.0.w;
  static double get w56 => 56.0.w;
  static double get w64 => 64.0.w;
  static double get w72 => 72.0.w;
  static double get w80 => 80.0.w;
  static double get w96 => 96.0.w;
  static double get w6 => 6.0.w;
  static double get w3 => 3.0.w;

  // [INFO]
  // Sizes that related with height
  static double get h4 => 4.0.h;
  static double get h8 => 8.0.h;
  static double get h12 => 12.0.h;
  static double get h16 => 16.0.h;
  static double get h18 => 18.0.h;
  static double get h20 => 20.0.h;
  static double get h24 => 24.0.h;
  static double get h28 => 28.0.h;
  static double get h32 => 32.0.h;
  static double get h36 => 36.0.h;
  static double get h40 => 40.0.h;
  static double get h48 => 48.0.h;
  static double get h52 => 52.0.h;
  static double get h56 => 56.0.h;
  static double get h64 => 64.0.h;
  static double get h72 => 72.0.h;
  static double get h80 => 80.0.h;
  static double get h96 => 96.0.h;
  static double get h6 => 6.0.h;

  // [INFO]
  // Sizes that related with radius
  static double get radiusSm => 6.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 24.r;
  static double get radiusXl => 30.r;

  /// [INFO]
  /// Sizes for custom width or height outside the 8 pixel rules
  static double customWidth(double value) => value.w;

  static double customHeight(double value) => value.h;

  static double customRadius(double value) => value.r;

  static double customFontSize(double value) => value.sp;
}

/// [INFO]
/// Constant for gaps to be used in the app with respecting 8 pixel rules
class Gap {
  /// [INFO]
  /// Gaps that related with width
  static SizedBox get w4 => SizedBox(width: BaseSize.w4);
  static SizedBox get w8 => SizedBox(width: BaseSize.w8);
  static SizedBox get w12 => SizedBox(width: BaseSize.w12);
  static SizedBox get w16 => SizedBox(width: BaseSize.w16);
  static SizedBox get w20 => SizedBox(width: BaseSize.w20);
  static SizedBox get w24 => SizedBox(width: BaseSize.w24);
  static SizedBox get w28 => SizedBox(width: BaseSize.w28);
  static SizedBox get w32 => SizedBox(width: BaseSize.w32);
  static SizedBox get w36 => SizedBox(width: BaseSize.w36);
  static SizedBox get w40 => SizedBox(width: BaseSize.w40);
  static SizedBox get w48 => SizedBox(width: BaseSize.w48);
  static SizedBox get w52 => SizedBox(width: BaseSize.w52);
  static SizedBox get w56 => SizedBox(width: BaseSize.w56);
  static SizedBox get w64 => SizedBox(width: BaseSize.w64);
  static SizedBox get w72 => SizedBox(width: BaseSize.w72);
  static SizedBox get w80 => SizedBox(width: BaseSize.w80);

  static SizedBox get w3 => SizedBox(width: BaseSize.w3);

  /// [INFO]
  /// Gaps that related with height
  static SizedBox get h4 => SizedBox(height: BaseSize.h4);
  static SizedBox get h8 => SizedBox(height: BaseSize.h8);
  static SizedBox get h12 => SizedBox(height: BaseSize.h12);
  static SizedBox get h16 => SizedBox(height: BaseSize.h16);
  static SizedBox get h20 => SizedBox(height: BaseSize.h20);
  static SizedBox get h24 => SizedBox(height: BaseSize.h24);
  static SizedBox get h28 => SizedBox(height: BaseSize.h28);
  static SizedBox get h32 => SizedBox(height: BaseSize.h32);
  static SizedBox get h36 => SizedBox(height: BaseSize.h36);
  static SizedBox get h40 => SizedBox(height: BaseSize.h40);
  static SizedBox get h48 => SizedBox(height: BaseSize.h48);
  static SizedBox get h52 => SizedBox(height: BaseSize.h52);
  static SizedBox get h56 => SizedBox(height: BaseSize.h56);
  static SizedBox get h64 => SizedBox(height: BaseSize.h64);
  static SizedBox get h72 => SizedBox(height: BaseSize.h72);
  static SizedBox get h80 => SizedBox(height: BaseSize.h80);

  static SizedBox get h6 => SizedBox(height: BaseSize.h6);

  /// [INFO]
  /// Gaps for custom width or height outside the 8 pixel rules
  static SizedBox customGapWidth(double value) => SizedBox(width: value.w);

  static SizedBox customGapHeight(double value) => SizedBox(height: value.h);

  /// [INFO]
  /// to get BuildContext.viewPadding.bottom
  /// used for give the empty space to fill the Bottom Outside SafeArea
  static dynamic bottomPadding(BuildContext context) {
    return customGapHeight(context.bottomPadding);
  }
}

final horizontalScreenPadding = EdgeInsets.symmetric(horizontal: BaseSize.w12);
