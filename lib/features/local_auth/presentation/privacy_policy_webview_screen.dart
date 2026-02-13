import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/local_auth_config.dart';

/// Displays the Privacy Policy in a WebView.
///
/// Listens for an acknowledgment signal from the page via:
///   A) **JS bridge** — the page calls `closeWebView.postMessage('{"acknowledged":true}')`
///   C) **Custom URL scheme** — the page navigates to
///      `chickenhotrecipes://close?payload={"acknowledged":true}`
///
/// Note: Android JSInterface (option B) is intentionally skipped — iOS-only project.
///
/// Returns `true` via `Navigator.pop` when acknowledged, `false` otherwise.
class PrivacyPolicyWebViewScreen extends StatefulWidget {
  final String url;

  const PrivacyPolicyWebViewScreen({
    super.key,
    this.url = LocalAuthConfig.privacyPolicyUrl,
  });

  @override
  State<PrivacyPolicyWebViewScreen> createState() =>
      _PrivacyPolicyWebViewScreenState();
}

class _PrivacyPolicyWebViewScreenState
    extends State<PrivacyPolicyWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      // --- A) JS bridge: primary signal path ---
      ..addJavaScriptChannel(
        LocalAuthConfig.jsChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          _handlePayload(message.message);
        },
      )

      // --- Navigation delegate: loading states + C) custom scheme fallback ---
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // C) Intercept custom URL scheme: chickenhotrecipes://close?payload=...
          final uri = Uri.tryParse(request.url);
          if (uri != null &&
              uri.scheme == LocalAuthConfig.customScheme) {
            final payload =
                uri.queryParameters['payload'] ?? '';
            _handlePayload(payload);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (_) {
          if (mounted) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          }
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (error) {
          // Ignore sub-resource errors (images, css, etc.)
          if (error.isForMainFrame ?? true) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          }
        },
      ));

    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  /// Parses the acknowledgment payload from either JS bridge or custom scheme.
  /// Accepts only `{"acknowledged": true}` (robust parsing).
  void _handlePayload(String raw) {
    if (_acknowledged) return; // already processed
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;

    final parsed = _parseAckPayload(trimmed);
    if (parsed == true) {
      _acknowledged = true;
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  bool _parseAckPayload(String payload) {
    // First, attempt strict JSON parsing.
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded['acknowledged'] == true) {
        return true;
      }
    } catch (_) {
      // Fall through to tolerant parsing.
    }

    // Tolerant format support, e.g. {acknowledged:true}
    final normalized = payload
        .replaceAllMapped(
          RegExp(r'([{,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:'),
          (m) => '${m.group(1)}"${m.group(2)}":',
        )
        .replaceAll(':true', ': true')
        .replaceAll(':false', ': false');
    try {
      final decoded = jsonDecode(normalized);
      return decoded is Map && decoded['acknowledged'] == true;
    } catch (_) {
      return false;
    }
  }

  void _closeWithoutAck() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _closeWithoutAck,
        ),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _hasError ? _buildErrorView(theme, colorScheme) : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return SafeArea(
      top: false,
      child: WebViewWidget(controller: _controller),
    );
  }

  Widget _buildErrorView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't open the Privacy Policy.\nPlease check your connection and try again.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _closeWithoutAck,
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _loadPage,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
