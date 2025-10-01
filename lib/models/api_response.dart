class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T? data}) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: data ?? json['data'],
      errors: json['errors'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'status_code': statusCode,
    };
  }

  // Helper methods
  bool get isSuccess => success;
  bool get hasError => !success;
  bool get hasData => data != null;
  bool get hasMessage => message != null && message!.isNotEmpty;

  // Static factory methods for common responses
  static ApiResponse<T> success<T>({
    T? data,
    String? message,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  static ApiResponse<T> error<T>({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  static ApiResponse<T> loading<T>() {
    return ApiResponse<T>(
      success: false,
      message: 'Loading...',
    );
  }
}

// Pagination response
class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final int? next;
  final int? previous;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      results: (json['results'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      hasNext: json['next'] != null,
      hasPrevious: json['previous'] != null,
    );
  }
}

// Error response details
class ErrorDetail {
  final String field;
  final String message;
  final String? code;

  ErrorDetail({
    required this.field,
    required this.message,
    this.code,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'] ?? '',
      message: json['message'] ?? json['detail'] ?? '',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      if (code != null) 'code': code,
    };
  }
}

// Network response wrapper
class NetworkResponse {
  final int statusCode;
  final Map<String, String> headers;
  final dynamic body;
  final bool isSuccess;

  NetworkResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.isSuccess,
  });

  factory NetworkResponse.fromHttpResponse(
    int statusCode,
    Map<String, String> headers,
    dynamic body,
  ) {
    return NetworkResponse(
      statusCode: statusCode,
      headers: headers,
      body: body,
      isSuccess: statusCode >= 200 && statusCode < 300,
    );
  }
}