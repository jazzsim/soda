class ThumbnailImage {
  final String thumbnail;

  ThumbnailImage({
    required this.thumbnail,
  });

  factory ThumbnailImage.fromJson(Map<String, dynamic> json) => ThumbnailImage(
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "thumbnail": thumbnail,
      };
}
