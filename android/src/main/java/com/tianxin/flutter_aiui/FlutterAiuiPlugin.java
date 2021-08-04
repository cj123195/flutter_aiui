package com.tianxin.flutter_aiui;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterAiuiPlugin
 */
public class FlutterAiuiPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private AIUIWrapper aiuiWrapper;
    private Context context;
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_aiui");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case Constant.INIT:
                if (aiuiWrapper == null) {
                    aiuiWrapper = new AIUIWrapper(context, activity, channel, result, call);
                } else {
                    aiuiWrapper.initAIUIAgent(call.argument("config"), result);
                }
                break;
            case Constant.START_SPEAK:
                aiuiWrapper.startSpeak(result, call.arguments());
                break;
            case Constant.END_SPEAK:
                aiuiWrapper.endSpeak();
                result.success(null);
                break;
            case Constant.PAUSE_SPEAK:
                aiuiWrapper.onPause();
                result.success(null);
                break;
            case Constant.RESUME_SPEAK:
                aiuiWrapper.onResume(result, call.arguments());
                result.success(null);
                break;
            case Constant.WRITE_TEXT: {
                if (call.argument("text") == null) {
                    result.error(null, "文字不能为空", null);
                } else {
                    aiuiWrapper.writeText(Objects.requireNonNull(call.argument("text")),
                            call.argument("config"));
                    result.success(null);
                }
            }
            break;
            case Constant.DISPOSE:
                aiuiWrapper.destroyAgent(result);
                result.success(null);
                break;
            case Constant.SET_PARAM:
                aiuiWrapper.setParameters(call.arguments());
                result.success(null);
                break;
            case Constant.START_TTS:
                aiuiWrapper.startTTs(call.argument("text"), call.argument("config"),
                        Objects.equals(call.argument("resume"), true));
                result.success(null);
                break;
            case Constant.STOP_TTS:
                aiuiWrapper.stopTTS();
                result.success(null);
                break;
            case Constant.PAUSE_TTS:
                aiuiWrapper.pauseTTS();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {

    }
}
