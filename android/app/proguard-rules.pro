# Keep Flutter utility classes accessed reflectively by JNI-based plugins.
# Without these rules R8 strips io.flutter.util.PathUtils in release builds,
# which causes path_provider and similar plugins to throw ClassNotFoundException.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.**
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

