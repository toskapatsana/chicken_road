/// Configuration constants for the local auth module.
/// Adjust these when reusing this module in another project.
class LocalAuthConfig {
  LocalAuthConfig._();

  /// URL for the Privacy Policy page displayed in the WebView.
  static const String privacyPolicyUrl =
      'https://lighthousecreativecircle.site/8mfZ9XKz';

  /// Custom URL scheme the WebView page can use to signal acknowledgment.
  /// The page navigates to: chickenhotrecipes://close?payload={"acknowledged":true}
  static const String customScheme = 'chickenhotrecipes';

  /// Name of the JavaScript channel the page posts messages to.
  static const String jsChannelName = 'closeWebView';

  /// SharedPreferences key for the local profile JSON.
  static const String profileStorageKey = 'local_user_profile';
}
