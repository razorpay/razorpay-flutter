class Error {
  String? errorCode;
  String? errorDescription;
  String? errorReason;
  String? errorStep;
  String? errorSource;
  Error({ this.errorCode,  this.errorDescription, this.errorReason, this.errorStep, this.errorSource});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      errorCode: json['errorCode'] ,
      errorDescription: json['errorDescription'] ,
      errorReason: json['errorReason'] ,
      errorStep: json['errorSource'] ,
      errorSource: json['errorStep']
    );
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