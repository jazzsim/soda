import 'package:soda/modals/http_server.dart';
import 'package:soda/modals/thumbnail_image.dart';

import '../base_client.dart';
import '../modals/page_content.dart';

class ServerApi {
  Future<PageContent> getContent(HttpServer server) async {
    final res = await BaseClient().post('scrape', server);
    if (res != null) {
      return PageContent.fromJson(res);
    }
    throw Exception();
  }

  Future<ThumbnailImage> getThumbnail(String url, String filename) async {
    final res = await BaseClient().get('thumbnail', query: {'url': url, 'filename': filename});
    if (res != null) {
      return ThumbnailImage.fromJson(res);
    }
    throw Exception();
  }
}
