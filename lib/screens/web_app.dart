import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/loading_overlay.dart';

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late final WebViewController controller;
  double loadingProgress = 0;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      // ✅ ADD THESE TWO LINES
      ..enableZoom(false)
      ..clearCache() // clears stale/broken cache on startup
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              loadingProgress = progress / 100;
            });
          },
          // ✅ ADD THIS — handles the cache miss by reloading without cache
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
            if (error.description.contains('ERR_CACHE_MISS')) {
              controller.reload();
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://bills.mojo-pay.com/login'),
        // ✅ ADD HEADERS to prevent caching issues
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      );
  }

  //

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // ✅ handle list instead of single result
      final isConnected = results.any((r) => r != ConnectivityResult.none);

      if (!mounted) return;

      if (!isConnected && _isConnected) {
        setState(() => _isConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Text('No internet connection'),
              ],
            ),
            backgroundColor: Color.fromARGB(255, 204, 20, 32),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (isConnected && !_isConnected) {
        setState(() => _isConnected = true);
        controller.reload();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi, color: Colors.white),
                SizedBox(width: 10),
                Text('Back online'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          await controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // ✅ Show offline message when no connection
              if (!_isConnected)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                WebViewWidget(controller: controller),

              if (loadingProgress < 1.0 && _isConnected)
                LoadingOverlay(progress: loadingProgress),
            ],
          ),
        ),
      ),
    );
  }
}
