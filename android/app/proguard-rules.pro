# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }

# Keep Lifecycle Observer (Fixed)
-keep class androidx.lifecycle.** { *; }

# Keep classes with @Keep annotation
-keepattributes *Annotation*

# Prevent removing generic types
-keepattributes Signature
