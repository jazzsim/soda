// To parse this JSON data, do
//
//     final pageContent = pageContentFromJson(jsonString);

import 'dart:convert';

PageContent pageContentFromJson(String str) => PageContent.fromJson(json.decode(str));

String pageContentToJson(PageContent data) => json.encode(data.toJson());

class PageContent {
    final List<String> folders;
    final List<FileElement> files;

    PageContent({
        required this.folders,
        required this.files,
    });

    PageContent copyWith({
        List<String>? folders,
        List<FileElement>? files,
    }) => 
        PageContent(
            folders: folders ?? this.folders,
            files: files ?? this.files,
        );

    factory PageContent.fromJson(Map<String, dynamic> json) => PageContent(
        folders: List<String>.from(json["folders"].map((x) => x)),
        files: List<FileElement>.from(json["files"].map((x) => FileElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "folders": List<dynamic>.from(folders.map((x) => x)),
        "files": List<dynamic>.from(files.map((x) => x.toJson())),
    };
}

class FileElement {
    final String media;
    final String filename;

    FileElement({
        required this.media,
        required this.filename,
    });

    FileElement copyWith({
        String? media,
        String? filename,
    }) => 
        FileElement(
            media: media ?? this.media,
            filename: filename ?? this.filename,
        );

    factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        media: json["media"],
        filename: json["filename"],
    );

    Map<String, dynamic> toJson() => {
        "media": media,
        "filename": filename,
    };
}
