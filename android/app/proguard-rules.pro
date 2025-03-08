# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }

# Keep classes with @Keep annotation
-keepattributes *Annotation*

# Prevent removing generic types
-keepattributes Signature
