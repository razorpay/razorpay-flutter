import 'account_credentials.dart';
import 'bank_model.dart';

class BankAccount {
  AccountCredentials? creds;
  String? maskedAccountNumber;
  Bank? bank;
  String? beneficiaryName;
  String? id;
  String? ifsc;
  String? type;

  BankAccount({
    this.creds,
    this.maskedAccountNumber,
    this.bank,
    this.beneficiaryName,
    this.id,
    this.ifsc,
    this.type,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        creds: AccountCredentials.fromJson(json['creds']),
        maskedAccountNumber: json['masked_account_number'],
        bank: Bank.fromJson(json['bank']),
        beneficiaryName: json['beneficiary_name'],
        id: json['id'],
        ifsc: json['ifsc'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'creds': creds?.toJson(),
        'masked_account_number': maskedAccountNumber,
        'bank': bank?.toJson(),
        'beneficiary_name': beneficiaryName,
        'id': id,
        'ifsc': ifsc,
        'type': type,
      };
}
