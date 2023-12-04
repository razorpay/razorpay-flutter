class Error {
  String? errorCode;
  String? errorDescription;
  Error({ this.errorCode,  this.errorDescription});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      errorCode: json['errorCode'] ,
      errorDescription: json['errorDescription']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'errorDescription': errorDescription
    };
  }

}