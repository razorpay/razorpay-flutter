class AccountCredentials {
  Upipin? upipin;
  Atmpin? atmpin;
  Sms? sms;

  AccountCredentials({
    this.upipin,
    this.atmpin,
    this.sms,
  });

  factory AccountCredentials.fromJson(Map<String, dynamic> json) =>
      AccountCredentials(
        atmpin: json['atmpin'] != null ? Atmpin.fromJson(json['atmpin']) : null,
        upipin: json['upipin'] != null ? Upipin.fromJson(json['upipin']) : null,
        sms: json['sms'] != null ? Sms.fromJson(json['sms']) : null,
      );

  Map<String, dynamic> toJson() => {
        'upipin': upipin?.toJson(),
        'atmpin': atmpin?.toJson(),
        'sms': sms?.toJson(),
      };
}

class Upipin {
  int? length;
  bool? set;

  Upipin({
    this.length,
    this.set,
  });

  factory Upipin.fromJson(Map<String, dynamic> json) => Upipin(
        length: json['length'],
        set: json['set'],
      );

  Map<String, dynamic> toJson() => {
        'length': length,
        'set': set,
      };
}

class Atmpin {
  bool? set;
  int? length;

  Atmpin({this.set, this.length});
  factory Atmpin.fromJson(Map<String, dynamic> json) {
    return Atmpin(
      set: json['set'],
      length: json['length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set': set,
      'length': length,
    };
  }
}

class Sms {
  bool? set;
  int? length;

  Sms({this.set, this.length});

  factory Sms.fromJson(Map<String, dynamic> json) => Sms(
        set: json['set'],
        length: json['length'],
      );

  Map<String, dynamic> toJson() => {
        'set': set,
        'length': length,
      };
}
