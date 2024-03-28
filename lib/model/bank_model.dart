class Bank {
  String? bankPlaceholderUrl;
  String? id;
  String? ifsc;
  String? logo;
  bool? upi;
  String? name;

  Bank({
    this.bankPlaceholderUrl,
    this.id,
    this.ifsc,
    this.logo,
    this.upi,
    this.name,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankPlaceholderUrl: json['bankPlaceholderUrl'],
      id: json['id'],
      ifsc: json['ifsc'],
      logo: json['logo'],
      upi: json['upi'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankPlaceholderUrl': bankPlaceholderUrl,
      'id': id,
      'ifsc': ifsc,
      'logo': logo,
      'upi': upi,
      'name': name,
    };
  }
}
