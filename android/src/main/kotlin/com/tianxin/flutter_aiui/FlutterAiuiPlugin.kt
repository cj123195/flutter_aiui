package com.tianxin.flutter_aiui

import android.Manifest
import android.app.Activity
import android.content.Context
import android.os.Build
import androidx.core.app.ActivityCompat
import com.iflytek.aiui.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledThreadPoolExecutor

/** FlutterAiuiPlugin */
class FlutterAiuiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var aiuiWrapper: AIUIWrapper? = null
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var scheduledExecutorService: ScheduledExecutorService

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_aiui")
        channel.setMethodCallHandler(this)
        scheduledExecutorService = ScheduledThreadPoolExecutor(1)
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != Constant.INIT_AGENT && aiuiWrapper == null) {
            result.error(Constant.AGENT_NOT_CREATE, "AiuiWrapper未初始化", null)
            return
        }
        when (call.method) {
            Constant.INIT_AGENT -> {
                if (aiuiWrapper == null) {
                    aiuiWrapper = AIUIWrapper(
                        context = context,
                        channel = channel,
                        executorService = scheduledExecutorService,
                    )
                }
                aiuiWrapper!!.initAgent(call.arguments as String?, result)
            }
            Constant.DESTROY_AGENT -> aiuiWrapper!!.destroyAgent(result)
            Constant.SET_PARAMS -> aiuiWrapper!!.setParams(
                call.arguments as String,
                result,
            )
            Constant.START_RECORD_AUDIO -> aiuiWrapper!!.startRecordAudio(
                call.arguments as String?,
                result
            )
            Constant.PAUSE_RECORD_AUDIO -> aiuiWrapper!!.pauseRecordAudio(
                call.arguments as String?,
                result
            )
            Constant.RESUME_RECORD_AUDIO -> aiuiWrapper!!.resumeRecordAudio(
                call.arguments as String?,
                result
            )
            Constant.STOP_RECORD_AUDIO -> aiuiWrapper!!.stopRecordAudio(
                call.arguments as String?,
                result
            )
            Constant.WRITE_TEXT -> aiuiWrapper!!.writeText(
                call.arguments as HashMap<String, Any>,
                result
            )
            Constant.START_TTS -> aiuiWrapper!!.startTTS(
                call.arguments as HashMap<String, Any>,
                false,
                result
            )
            Constant.PAUSE_TTS -> aiuiWrapper!!.pauseTTS(result)
            Constant.RESUME_TTS -> aiuiWrapper!!.startTTS(null, true, result)
            Constant.STOP_TTS -> aiuiWrapper!!.stopTTS(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        requestPermissions()
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
    }

    private fun requestPermissions() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val permissions = arrayOf(
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.RECORD_AUDIO,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.INTERNET
                )
                ActivityCompat.requestPermissions(activity, permissions, 0x0010
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
