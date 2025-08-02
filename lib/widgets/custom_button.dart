import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final ButtonVariant variant;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.variant = ButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppConstants.primaryColor,
              foregroundColor: textColor ?? Colors.white,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    borderRadius ??
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: AppConstants.buttonStyle.copyWith(
                      color: textColor ?? Colors.white,
                    ),
                  ),
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppConstants.primaryColor,
              side: BorderSide(color: borderColor ?? AppConstants.primaryColor),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    borderRadius ??
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? AppConstants.primaryColor,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppConstants.buttonStyle.copyWith(
                      color: textColor ?? AppConstants.primaryColor,
                    ),
                  ),
          ),
        );
      case ButtonVariant.text:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? AppConstants.primaryColor,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    borderRadius ??
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? AppConstants.primaryColor,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppConstants.buttonStyle.copyWith(
                      color: textColor ?? AppConstants.primaryColor,
                    ),
                  ),
          ),
        );
    }
  }

  Color? get borderColor => backgroundColor ?? AppConstants.primaryColor;
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppConstants.primaryColor,
          side: BorderSide(color: borderColor ?? AppConstants.primaryColor),
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppConstants.primaryColor,
                  ),
                ),
              )
            : Text(
                text,
                style: AppConstants.buttonStyle.copyWith(
                  color: textColor ?? AppConstants.primaryColor,
                ),
              ),
      ),
    );
  }
}
