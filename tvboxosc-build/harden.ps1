$ErrorActionPreference = 'Stop'

$appGradle = 'app/build.gradle'
$gradle = Get-Content -LiteralPath $appGradle -Raw
$gradle = $gradle.Replace('    api fileTree(dir: "libs", include: ["*.jar"])' + "`n", '')
$gradle = $gradle.Replace("    implementation files('libs\\thunder.jar')" + "`n", '')
$gradle = $gradle.Replace("dependencies {", "dependencies {`n    implementation files('libs/xwalk_shared_library-23.53.589.4.aar')")
Set-Content -LiteralPath $appGradle -Value $gradle -Encoding UTF8

$rootGradlePath = 'build.gradle'
$rootGradle = Get-Content -LiteralPath $rootGradlePath -Raw
$mirrorBlock = @'
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
'@
$rootGradle = $rootGradle.Replace('        gradlePluginPortal()', $mirrorBlock + "`n        gradlePluginPortal()")
Set-Content -LiteralPath $rootGradlePath -Value $rootGradle -Encoding UTF8

$crosswalkBase = 'https://raw.githubusercontent.com/o0HalfLife0o/crosswalk/master/releases/crosswalk/android/maven2/org/xwalk/xwalk_shared_library/23.53.589.4'
$crosswalkDir = 'app/libs'
New-Item -ItemType Directory -Path $crosswalkDir -Force | Out-Null
Invoke-WebRequest -Uri "$crosswalkBase/xwalk_shared_library-23.53.589.4.aar" -OutFile "$crosswalkDir/xwalk_shared_library-23.53.589.4.aar"

$playerGradlePath = 'player/build.gradle'
$playerGradle = Get-Content -LiteralPath $playerGradlePath -Raw
$playerGradle = [regex]::Replace($playerGradle, '(?m)^\s*api "com\.google\.android\.exoplayer:extension-rtmp:[^"]+"\r?\n?', '')
Set-Content -LiteralPath $playerGradlePath -Value $playerGradle -Encoding UTF8

$exoHelperPath = 'player/src/main/java/xyz/doikki/videoplayer/exo/ExoMediaSourceHelper.java'
$exoHelper = Get-Content -LiteralPath $exoHelperPath -Raw
$exoHelper = [regex]::Replace($exoHelper, '(?m)^import com\.google\.android\.exoplayer2\.ext\.rtmp\.RtmpDataSourceFactory;\r?\n', '')
$exoHelper = $exoHelper.Replace('            return new RtmpDataSourceFactory();', '            return mHttpDataSourceFactory;')
Set-Content -LiteralPath $exoHelperPath -Value $exoHelper -Encoding UTF8

$manifestPath = 'app/src/main/AndroidManifest.xml'
$manifest = Get-Content -LiteralPath $manifestPath -Raw
$manifest = $manifest.Replace(
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android"',
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools"'
)
$permissions = @(
    'android.permission.READ_PHONE_STATE',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.REQUEST_INSTALL_PACKAGES',
    'android.permission.GET_TASKS'
)
foreach ($permission in $permissions) {
    $pattern = '(?m)^\s*<uses-permission android:name="' + [regex]::Escape($permission) + '"\s*/>\r?\n?'
    $manifest = [regex]::Replace($manifest, $pattern, '')
}
$removeNodes = ($permissions | ForEach-Object {
    '    <uses-permission android:name="' + $_ + '" tools:node="remove" />'
}) -join "`n"
$manifest = $manifest.Replace(
    '    <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />',
    '    <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />' + "`n" + $removeNodes
)
Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8

$thunderPath = 'app/src/main/java/com/github/tvbox/osc/util/thunder/Thunder.java'
@'
package com.github.tvbox.osc.util.thunder;

import android.content.Context;

/** Disables the opaque bundled Thunder/magnet implementation. */
public final class Thunder {
    private Thunder() {}

    public interface ThunderCallback {
        void status(int code, String info);
        void list(String playList);
        void play(String url);
    }

    public static void parse(Context context, String url, ThunderCallback callback) {
        if (callback != null) callback.status(-1, "Unsupported link type");
    }

    public static boolean play(String url, ThunderCallback callback) {
        return false;
    }

    public static boolean isSupportUrl(String url) {
        return false;
    }
}
'@ | Set-Content -LiteralPath $thunderPath -Encoding UTF8

if (Test-Path 'app/libs/thunder.jar') {
    Remove-Item -LiteralPath 'app/libs/thunder.jar'
}
