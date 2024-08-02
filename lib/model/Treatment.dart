import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

enum TreatmentType { eigenuebung, laufanalyse }

@immutable
class Treatment extends Equatable {
  final String name;
  final String date;
  final TreatmentType type;
  final String information;
  final List<Attachment> videos;
  final Attachment pdf;

  Treatment({this.name, this.date, this.type, this.information, this.videos, this.pdf});

  Treatment.fromJson(Map<String, dynamic> jsonObj)
      : name = jsonObj['name'],
        date = jsonObj['datum'],
        type = (jsonObj['acf_fc_layout'] == "eigenuebung")
            ? TreatmentType.eigenuebung
            : TreatmentType.laufanalyse,
        information = removeAllHtmlTags(jsonObj['information']),
        videos = (jsonObj['video'] is List)
            ? [Attachment.fromJson(jsonObj['video'][0])]
            : (jsonObj['video'] is Map)
                ? [Attachment.fromJson(jsonObj['video'])]
                : [Attachment.empty()],
        pdf = (jsonObj['pdf'] is Map)
            ? Attachment.fromJson(jsonObj['pdf'])
            : Attachment.empty();

  toJson() {
    final jsonObj = Map<String, dynamic>();
    jsonObj['acf_fc_layout'] =
        (type == TreatmentType.eigenuebung) ? "eigenuebung" : "laufanalyse";
    jsonObj["name"] = name;
    jsonObj["datum"] = date;
    jsonObj["information"] = information;
    jsonObj["video"] = videos[0].toJson();
    jsonObj["pdf"] = pdf.toJson();

    return jsonObj;
  }

  @override
  List<Object> get props => [name, date, type, information, videos, pdf];

  @override
  String toString() => "Treatment {$type: $name, date: $date}";

  String get readableType =>
      (type == TreatmentType.eigenuebung) ? "Eigenübung" : "Laufanalyse";
}

enum AttachmentType { pdf, video, empty }

@immutable
class Attachment extends Equatable {
  final int id;
  final String title;
  final String url;
  final AttachmentType type;

  final int width;
  final int height;

  //final String mimeType;

  String get fileName => url.split("/").last;
  double get aspectRatio => width / height;

  Attachment(
      {this.id = -1, this.title = "", this.url = "", @required this.type, this.width = -1, this.height = -1});

  factory Attachment.fromJson(Map<String, dynamic> jsonObj) {
    if (jsonObj['videofile'] != null) {
      jsonObj = jsonObj['videofile'] as Map;
    }
    return Attachment(
        id: jsonObj['id'],
        title: jsonObj['title'],
        url: jsonObj['url'],
        width: jsonObj['width'] is String? int.parse(jsonObj['width']) : jsonObj['width'] ?? -1,
        height: jsonObj['height'] is String? int.parse(jsonObj['height']) : jsonObj['height'] ?? -1,
        type: (jsonObj['type'] == "video")
            ? AttachmentType.video
            : AttachmentType.pdf);
  }

  toJson() {
    if (type == AttachmentType.empty) return 'false';

    final jsonObj = Map<String, dynamic>();
    jsonObj['ID'] = id;
    jsonObj['id'] = id;
    jsonObj['filename'] = fileName;
    jsonObj['url'] = url;
    jsonObj['title'] = title;
    jsonObj['name'] = title;
    if (type == AttachmentType.video) {
      jsonObj['mime_type'] = 'video/mp4';
      jsonObj['type'] = "video";
      jsonObj["width"] = width > 0 ? width : 1920;
      jsonObj["height"] = height > 0 ? height : 1080;
    } else {
      jsonObj['mime_type'] = 'application/pdf';
      jsonObj['type'] = "application";
    }
    return jsonObj;
  }

  Attachment.empty() : this(type: AttachmentType.empty);

  bool get notEmpty => type != AttachmentType.empty;

  @override
  List<Object> get props => [id, title, url, type];

  @override
  String toString() => "Attachment {$type, id: $id}";
}

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}
