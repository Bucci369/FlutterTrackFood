import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final onPrimaryColor = textColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: CupertinoButton(
          onPressed: isLoading ? null : onPressed,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildChild(primaryColor),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: CupertinoButton.filled(
        onPressed: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: _buildChild(onPrimaryColor),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CupertinoActivityIndicator(
          color: CupertinoColors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOutlined ? color : null,
              letterSpacing: -0.41,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isOutlined ? color : null,
        letterSpacing: -0.41,
      ),
    );
  }
}
