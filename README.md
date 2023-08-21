# flutter_aiui

Flutter plugin that allows you to use iFlytek's AIUI on Android.

## Key Features

- Speech recognition
- Semantics understanding
- Speech synthesis
- Wakeup

### IOS
Xcode 7,8 has Bitcode enabled by default, and Bitcode requires support from all class libraries that the project relies on. The AIUI SDK currently does not support Bitcode, and developers need to disable this setting. Simply search for Bitcode in `Targets ->Build Settings`, find the corresponding option, and set it to NO. As shown in the following figure:
<img src="https://aiui.xfyun.cn/doc/assets/img/ios_setting_bitcode.2e7d9abd.png" width="350">

Add the following keys to your`Info.plist`file, located in`<project root>/ios/Runner/Info.plist`:
```
<key>NSMicrophoneUsageDescription</key>
<string></string>
<key>NSLocationUsageDescription</key>
<string></string>
<key>NSLocationAlwaysUsageDescription</key>
<string></string>
<key>NSContactsUsageDescription</key>
<string></string>
```

### Android

- Update your minimum SDK version to 24 in android/app/build.gradle.
```
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 19 // Change this
        ...
    }
    ...
}
```

- Add the following permissions to your `AndroidManifest.xml`, located in `<project root>/android/app/src/main/AndroidManifest.xml`

```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```
Note: To avoid confusion during packaging or generating APK, please add the following code to proguard.cfg:
```
-dontoptimize
-keep class com.iflytek.**{*;}
-keepattributes Signature
```

- Add `android:requestLegacyExternalStorage=true` of application in `AndroidManifest.xml`.
```
<application
        ...
        android:requestLegacyExternalStorage="true">
      ...
</application>      
```

- Copy the `assets` folder from the resources downloaded from iFlytek's AIUI application platform to `<project root>/android/app/src/main`

## Usage



#### Create agent
To use AIUI functionality, you must first create an AIUI agent.
```dart
final AiuiParams _params = AiuiParams(
    appId: appId,
    global: GlobalParams(scene: 'main_box'),
    speech: SpeechParams(wakeupMode: WakeupMode.vtn),
  );
await FlutterAiui().initAgent(_params);
```

Note: To use the wakeup function, simply set the wakeupMode of AiuiParam's speech parameter to WakeupMode.vtn and reinitialize the Agent

#### Destroy agent
```dart
FlutterAiui().destroyAgent();
```

#### Add listener
Using a listener to listen for AIUI events
```dart
FlutterAiui().addListener(AiuiEventListener(onResult: () => {}));
```

#### Remove listener
```dart
FlutterAiui().removeListener();
```

#### Set parameter
```dart
FlutterAiui().setParams(paramsJson);
```

#### Start recording
```dart
FlutterAiui().startRecordAudio();
```

#### Stop recording
```dart
FlutterAiui().stopRecordAudio();
```

#### Identifying text
```dart
FlutterAiui().writeText('xxxxx');
```

#### Start tts
```dart
FlutterAiui().startTTS();
```

#### End tts
```dart
FlutterAiui().stopTTS();
```

## Contribution

Users are encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or by improving the documentation wherever it’s found to be lacking.

If you wish to make a change,[open a Pull Request](https://github.com/mikaoj/BSImagePicker/pull/new) even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

## License

MIT

---

> GitHub @cj123195 ·
>


