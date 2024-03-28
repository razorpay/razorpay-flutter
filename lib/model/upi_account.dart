class UpiAccount {
  String? accountNumber;
  String? bankLogoUrl;
  String? bankName;
  String? bankPlaceholderUrl;
  String? ifsc;
  int? pinLength;

  UpiAccount({
    this.accountNumber,
    this.bankLogoUrl,
    this.bankName,
    this.bankPlaceholderUrl,
    this.ifsc,
    this.pinLength,
  });

  factory UpiAccount.fromJson(Map<String, dynamic> json) => UpiAccount(
        accountNumber: json['account_number'],
        bankLogoUrl: json['bank_logo_url'],
        bankName: json['bank_name'],
        bankPlaceholderUrl: json['bankPlaceholderUrl'],
        ifsc: json['ifsc'],
        pinLength: json['pinLength'],
      );

  Map<String, dynamic> toJson() => {
        'account_number': accountNumber,
        'bank_logo_url': bankLogoUrl,
        'bank_name': bankName,
        'bankPlaceholderUrl': bankPlaceholderUrl,
        'ifsc': ifsc,
        'pinLength': pinLength,
      };
}
