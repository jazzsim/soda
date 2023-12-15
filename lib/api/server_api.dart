import 'package:soda/modals/http_server.dart';

import '../base_client.dart';
import '../modals/page_content.dart';

class ServerApi {
  /* GET */
  // search API
  Future<PageContent> getContent(HttpServer server) async {
    final res = await BaseClient().post('scrape', server );
    if (res != null) {
      return PageContent.fromJson(res);
    }
    throw Exception();
  }
}
