import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/local_auth_config.dart';

class PrivacyPolicyWebViewScreen extends StatefulWidget {
  final String url;

  const PrivacyPolicyWebViewScreen({
    super.key,
    this.url = LocalAuthConfig.privacyPolicyUrl,
  });

  @override
  State<PrivacyPolicyWebViewScreen> createState() => _PrivacyPolicyWebViewScreenState();
}

class _PrivacyPolicyWebViewScreenState extends State<PrivacyPolicyWebViewScreen> {
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
      ..addJavaScriptChannel(
        LocalAuthConfig.jsChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          _handlePayload(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.scheme == LocalAuthConfig.customScheme) {
              final payload = uri.queryParameters['payload'];
              if (payload == null || payload.trim().isEmpty) {
                if (mounted) {
                  Navigator.of(context).pop(false);
                }
                return NavigationDecision.prevent;
              }
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
          onPageFinished: (_) async {
            await _installBridgeShims();
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
          },
        ),
      );

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

  void _handlePayload(String raw) {
    if (_acknowledged) {
      return;
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final parsed = _parseAckPayload(trimmed);
    if (parsed) {
      _acknowledged = true;
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
    }
  }

  bool _parseAckPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded['acknowledged'] == true) {
        return true;
      }
    } catch (_) {
    }

    final normalized = payload
        .replaceAllMapped(
          RegExp(r'([{,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:'),
          (m) => '${m.group(1)}"${m.group(2)}":',
        )
        .replaceAll(':true', ': true')
        .replaceAll(':false', ': false');

    try {
      final decoded = jsonDecode(normalized);
      final ok = decoded is Map && decoded['acknowledged'] == true;
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> _installBridgeShims() async {
    const script = """
      (() => {
        try {
          const toJsonPayload = (payload) => {
            if (typeof payload === 'string') return payload;
            try { return JSON.stringify(payload); } catch (_) { return '{"acknowledged":false}'; }
          };

          const forwardToFlutter = (payload) => {
            try {
              const data = toJsonPayload(payload ?? {"acknowledged": true});
              if (window.closeWebView && typeof window.closeWebView.postMessage === 'function') {
                window.closeWebView.postMessage(data);
                return true;
              }
            } catch (_) {}
            return false;
          };

          window.webkit = window.webkit || {};
          window.webkit.messageHandlers = window.webkit.messageHandlers || {};
          window.webkit.messageHandlers.closeWebView = {
            postMessage: (payload) => forwardToFlutter(payload)
          };

          window.flutter_inappwebview = window.flutter_inappwebview || {};
          if (typeof window.flutter_inappwebview.callHandler !== 'function') {
            window.flutter_inappwebview.callHandler = (name, payload) => {
              if (name === 'closeWebView') forwardToFlutter(payload);
            };
          }

          const closeWithAckViaFallback = () => {
            const encoded = encodeURIComponent('{"acknowledged":true}');
            window.location.href = 'chickenhotrecipes://close?payload=' + encoded;
          };

          const triggerAck = () => {
            const sent = forwardToFlutter({"acknowledged": true});
            if (!sent) closeWithAckViaFallback();
          };

          const triggerDismiss = () => {
            window.location.href = 'chickenhotrecipes://close';
          };

          const isAcceptButton = (text) => {
            const t = (text || '').toLowerCase().trim();
            return t.includes('i have read this policy and want to close');
          };

          const isCloseButton = (text) => {
            const t = (text || '').toLowerCase().trim();
            return t === 'close';
          };

          document.addEventListener('click', (event) => {
            const el = event.target && event.target.closest
              ? event.target.closest('button,a,[role="button"]')
              : null;
            if (!el) return;
            const txt = el.innerText || el.textContent || '';

            if (isAcceptButton(txt)) {
              event.preventDefault();
              event.stopPropagation();
              triggerAck();
            } else if (isCloseButton(txt)) {
              event.preventDefault();
              event.stopPropagation();
              triggerDismiss();
            }
          }, true);
        } catch (_) {}
      })();
    """;

    try {
      await _controller.runJavaScript(script);
    } catch (_) {
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
