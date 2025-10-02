import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppConstants.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              message!,
              style: TextStyle(
                color: AppConstants.secondaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final String? loadingText;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.loadingText,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppConstants.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(loadingText!),
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppConstants.paddingSmall),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}