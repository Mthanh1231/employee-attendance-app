class CccdInfo {
  final String? place;
  final String? date;
  final String? home;
  final String? cccdName;
  final String? img;
  final String? na;
  final String? id;
  final String? s;
  final String? ddnd;
  final String? tg;

  CccdInfo({
    this.place,
    this.date,
    this.home,
    this.cccdName,
    this.img,
    this.na,
    this.id,
    this.s,
    this.ddnd,
    this.tg,
  });

  factory CccdInfo.fromJson(Map<String, dynamic>? json) => CccdInfo(
        place: json?['place'],
        date: json?['date'],
        home: json?['home'],
        cccdName: json?['cccd_name'],
        img: json?['img'],
        na: json?['na'],
        id: json?['id'],
        s: json?['s'],
        ddnd: json?['ddnd'],
        tg: json?['tg'],
      );
}
