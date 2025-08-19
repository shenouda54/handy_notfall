# Play Core Library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter specific rules
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.engine.** { *; }
-dontwarn io.flutter.embedding.**

# Prevent obfuscation of classes that are referenced by Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }