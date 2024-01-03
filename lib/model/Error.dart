class Error {
  String? errorCode;
  String? errorDescription;
  String? errorReason;
  String? errorStep;
  String? errorSource;
  Error(
      {this.errorCode,
      this.errorDescription,
      String? errorReason,
      String? errorStep,
      String? errorSource}
      ): errorReason = errorReason ?? "sdk_error",
        errorStep = errorStep ?? "",
        errorSource = errorSource ?? "unknown_source";

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
        errorCode: json['errorCode'],
        errorDescription: json['errorDescription'],
        errorReason: json['errorReason'] as String?,
        errorStep: json['errorSource'] as String?,
        errorSource: json['errorStep'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'errorDescription': errorDescription,
      'errorReason': errorReason,
      'errorSource': errorSource,
      'errorStep': errorStep
    };
  }
}
