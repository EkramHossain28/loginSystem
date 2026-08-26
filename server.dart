import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8082);
  print('Server running on http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) async {
  final path = request.uri.path;
  final method = request.method;

  // Serve static files
  if (method == 'GET') {
    String filePath = 'public${path == '/' ? '/login.html' : path}';
    final file = File(filePath);
    if (await file.exists()) {
      request.response.headers.contentType = ContentType.html;
      request.response.add(await file.readAsBytes());
      await request.response.close();
      return;
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('404 Not Found');
      await request.response.close();
      return;
    }
  }

  // Handle login POST
  if (method == 'POST' && path == '/login') {
    final body = await utf8.decoder.bind(request).join();
    final params = Uri.splitQueryString(body);
    final username = params['username'] ?? '';
    final password = params['password'] ?? '';

    // Hardcoded credentials – replace with database check in real app
    if (username == 'guest' && password == '0000') {
      // Redirect to ind3 page
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set('Location', '/welcome.html');
    } else {
      // Redirect back to login with error flag
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set('Location', '/login.html?error=1');
    }
    await request.response.close();
  }
}
