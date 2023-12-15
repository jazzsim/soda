import 'dart:convert';

class HttpServer {
    final String url;
    final String username;
    final String password;

    HttpServer({
        required this.url,
        required this.username,
        required this.password,
    });

    HttpServer copyWith({
        String? url,
        String? username,
        String? password,
    }) => 
        HttpServer(
            url: url ?? this.url,
            username: username ?? this.username,
            password: password ?? this.password,
        );

    factory HttpServer.fromRawJson(String str) => HttpServer.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory HttpServer.fromJson(Map<String, dynamic> json) => HttpServer(
        url: json["url"],
        username: json["username"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "username": username,
        "password": password,
    };
}
