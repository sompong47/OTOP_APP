import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final Color? iconColor;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
            ],
            Text(
              message,
              style: TextStyle(
                color: AppConstants.secondaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? retryText;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'ไม่สามารถเชื่อมต่อได้',
      message: 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต\nแล้วลองใหม่อีกครั้ง',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: retryText,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onGoBack;
  final String? goBackText;

  const NotFoundWidget({
    super.key,
    this.title,
    this.message,
    this.onGoBack,
    this.goBackText,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: title ?? 'ไม่พบข้อมูล',
      message: message ?? 'ไม่พบข้อมูลที่คุณต้องการ',
      icon: Icons.search_off,
      iconColor: AppConstants.secondaryColor,
      onRetry: onGoBack ?? () => Navigator.of(context).pop(),
      retryText: goBackText ?? 'กลับ',
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? 'เริ่มต้น'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (widget.onError != null) {
        widget.onError!(details.exception, details.stack ?? StackTrace.empty);
      }
      setState(() {
        _hasError = true;
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ??
          AppErrorWidget(
            title: 'เกิดข้อผิดพลาด',
            message: 'แอปพลิเคชันประสบปัญหา\nกรุณารีสตาร์ทแอป',
            onRetry: () {
              setState(() {
                _hasError = false;
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    return widget.child;
  }
}