$ErrorActionPreference = 'Stop'

$appGradle = 'app/build.gradle'
$gradle = Get-Content -LiteralPath $appGradle -Raw
$gradle = $gradle.Replace('    api fileTree(dir: "libs", include: ["*.jar"])' + "`n", '')
$gradle = $gradle.Replace("    implementation files('libs\\thunder.jar')" + "`n", '')
Set-Content -LiteralPath $appGradle -Value $gradle -Encoding UTF8

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
