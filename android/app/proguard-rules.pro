# Flutter-specific ProGuard rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# SQLite
-keep class org.sqlite.** { *; }
-keep class net.sqlcipher.** { *; }

# Keep speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# Keep permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep overlay window
-keep class flutter.overlay.window.** { *; }

# Keep add_2_calendar
-keep class com.javih.add_to_calendar.** { *; }

# Keep printing
-keep class net.nfet.flutter.printing.** { *; }

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
