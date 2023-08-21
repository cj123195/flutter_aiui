package com.tianxin.flutter_aiui

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.AssetManager
import android.util.Log
import com.iflytek.aiui.*
import com.tianxin.flutter_aiui.FucUtil.copyAssetFolder
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class AIUIWrapper(
    context: Context,
    channel: MethodChannel,
    executorService: ScheduledExecutorService,
) {
    private var mContext: Context = context

    private var mChannel: MethodChannel = channel

    private val mExecutorService: ScheduledExecutorService = executorService

    // AIUI代理
    private var mAIUIAgent: AIUIAgent? = null

    // AIUI当前状态
    private var mCurrentState = AIUIConstant.STATE_IDLE

    // 等待清除历史的标志，在CONNECT_SERVER时处理
    private var mPendingHistoryClear = false

    // 是否支持唤醒
    private var isWakeUpEnable = false

    /// 是否正在录音
    private var mAudioRecording = false

    /// 获取是否使用唤醒功能
    private fun getWakeupEnabled(config: JSONObject): Boolean {
        val wakeupMode = config.optJSONObject("speech")?.optString("wakeup_mode")
        return "off" != wakeupMode && null != wakeupMode
    }

    /// 处理Ivw资源
    @SuppressLint("SdCardPath")
    private fun processIvwRes(config: JSONObject): String {
        val resPath = config.optJSONObject("ivw")?.optString("res_path")
        var path: String? = null
        if (resPath != null && resPath.isNotEmpty()) {
            val index = resPath.indexOf("/vtn")
            if (index != -1) {
                path = resPath.substring(0, index)
            }
        }
        if (path == null) {
            path = "/sdcard/AIUI/ivw"
            config.optJSONObject("ivw")?.put("res_path", path)
        }
        copyAssetFolder(mContext, "ivw", path)
        return config.toString()
    }

    /**
     * 加载AIUI参数
     */
    private fun getAIUIParams(config: String?): String? {
        var params: String? = ""
        val assetManager: AssetManager = mContext.resources.assets
        try {
            params = if (config == null) {
                val ins = assetManager.open("cfg/aiui_phone.cfg")
                val buffer = ByteArray(ins.available())
                ins.read(buffer)
                ins.close()
                String(buffer)
            } else {
                config
            }
            val paramsJson = JSONObject(params)
            isWakeUpEnable = getWakeupEnabled(paramsJson)
            if (isWakeUpEnable) {
                params = processIvwRes(paramsJson)
            }
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        return params
    }

    /**
     * 初始化AIUIAgent
     *
     * @param arguments 参数
     */
    fun initAgent(
        arguments: String?,
        result: MethodChannel.Result,
    ) {
        //销毁增加延迟，避免与onChatResume中startRecordAudio间隔过近（异步成功）导致的destroy时不能销毁录音机问题
        if (mAIUIAgent != null) {
            mExecutorService.schedule({
                if (mAIUIAgent != null) {
                    val temp: AIUIAgent = mAIUIAgent!!
                    mAIUIAgent = null
                    Log.d("AIUIWrapper", "start Destroy AIUIAgent")
                    temp.destroy()
                }
                try {
                    Thread.sleep(300)
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }

                createAgent(arguments, result)
            }, 300, TimeUnit.MILLISECONDS)
        } else {
            //首次启动，设置清除历史标记
            mPendingHistoryClear = true
            createAgent(arguments, result)
        }
    }

    /**
     * 根据AIUI配置创建AIUIAgent
     *
     * @param arguments 参数
     */
    private fun createAgent(arguments: String?, result: MethodChannel.Result) {
        mAudioRecording = false
        val config = getAIUIParams(arguments)

        //为每一个设备设置对应唯一的SN（最好使用设备硬件信息(mac地址，设备序列号等）生成），以便正确统计装机量，避免刷机或者应用卸载重装导致装机量重复计数
        val deviceId: String = DeviceUtils.getDeviceId(mContext)
        AIUISetting.setSystemInfo(AIUIConstant.KEY_SERIAL_NUM, deviceId)
        mAIUIAgent = AIUIAgent.createAgent(mContext, config, mAIUIListener)

        try {
            Thread.sleep(300)
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }

        //唤醒模式自动开始录音
        if (isWakeUpEnable) {
            startRecordAudio(null, result)
        } else {
            result.success(null)
        }
    }

    /**
     * 销毁AIUI代理
     */
    fun destroyAgent(result: MethodChannel.Result) {
        if (null != mAIUIAgent) {
            mAIUIAgent!!.destroy()
            mAIUIAgent = null
            result.success(true)
        }
    }

    /**
     * 设置参数
     *
     * @param config 配置信息
     */
    fun setParams(config: String, result: MethodChannel.Result) {
        sendMessage(AIUIMessage(AIUIConstant.CMD_SET_PARAMS, 0, 0, config, null), result)
    }

    /**
     * 开始录音
     */
    fun startRecordAudio(config: String?, result: MethodChannel.Result?) {
        if (!mAudioRecording) {
            val params = config ?: "sample_rate=16000,data_type=audio,tag=audio-tag,dwa=wpgs"
            val message = AIUIMessage(AIUIConstant.CMD_START_RECORD, 0, 0, params, null)
            sendMessage(message, result)
            mAudioRecording = true
        }
    }

    /**
     * 停止录音
     */
    fun stopRecordAudio(config: String?, result: MethodChannel.Result) {
        if (mAudioRecording) {
            sendMessage(
                AIUIMessage(
                    AIUIConstant.CMD_STOP_RECORD,
                    0, 0, config ?: "data_type=audio,sample_rate=16000", null
                ),
                result
            )
            mAudioRecording = false
        }
    }

    /**
     * 继续录音
     * 恢复到前台后，如果是唤醒模式下重新开启录音
     */
    fun resumeRecordAudio(config: String?, result: MethodChannel.Result) {
        if (isWakeUpEnable) {
            startRecordAudio(config, result)
        } else {
            result.success(null)
        }
    }

    /**
     * 暂停录音
     * 唤醒模式下录音常开，pause时停止录音，避免不再前台时占用录音
     */
    fun pauseRecordAudio(config: String?, result: MethodChannel.Result) {
        if (isWakeUpEnable) {
            stopRecordAudio(config, result)
        } else {
            result.success(null)
        }
    }

    /**
     * 文本语义
     *
     * @param arguments["text"] 需要识别的文本
     * @param arguments["config"] 配置信息
     */
    fun writeText(arguments: HashMap<String, Any>, result: MethodChannel.Result) {
        // 在输入参数中设置tag，则对应结果中也将携带该tag，可用于关联输入输出
        val params = arguments["config"] as String? ?: "data_type=text,tag=text-tag"
        val textData = (arguments["text"] as String).toByteArray(StandardCharsets.UTF_8)
        sendMessage(
            AIUIMessage(
                AIUIConstant.CMD_WRITE, 0, 0,
                params, textData
            ),
            result
        )
    }

    /**
     * 语音合成
     *
     * @param arguments["text"] 合成文本
     * @param arguments["config"] 配置信息
     * @param resume 是否为继续合成
     */
    fun startTTS(arguments: HashMap<String, Any>?, resume: Boolean, result: MethodChannel.Result) {
        if (resume) {
            sendMessage(
                AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.PAUSE, 0, null, null),
                result
            )
        }
        if (!resume) {
            val tag = "@" + System.currentTimeMillis()
            val params = arguments!!["config"] as String?
                ?: ("vcn=x2_xiaojuan" +  //合成发音人
                        ",speed=50" +  //合成速度
                        ",pitch=50" +  //合成音调
                        ",volume=50" +  //合成音量
                        ",ent=x_tts" +  //合成音量
                        ",tag=" + tag) //构建合成参数
            //合成tag，方便追踪合成结束，暂未实现
            val message = AIUIMessage(
                AIUIConstant.CMD_TTS, AIUIConstant.START, 0,
                params, (arguments["text"] as String).toByteArray()
            )
            sendMessage(message, result)
        } else {
            sendMessage(
                AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.RESUME, 0, null, null),
                result
            )
        }
    }

    /**
     * 暂停合成
     */
    fun pauseTTS(result: MethodChannel.Result) {
        sendMessage(AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.PAUSE, 0, null, null), result)
    }

    /**
     * 停止合成播放
     */
    fun stopTTS(result: MethodChannel.Result) {
        sendMessage(AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.CANCEL, 0, "", null), result)
    }

    /**
     * AIUI 监听器
     */
    private val mAIUIListener = AIUIListener { event: AIUIEvent ->
        if (event.eventType == AIUIConstant.EVENT_STATE) {
            mCurrentState = event.arg1
        } else if (event.eventType == AIUIConstant.EVENT_ERROR) {
            val errorCode = event.arg1
            if (errorCode == 20006) {
                mAudioRecording = false
            }
        }

        val data = HashMap<String, Any?>()
        if (event.data != null) {
            val keys = event.data.keySet()
            for (key in keys) {
                data[key] = event.data[key]
            }
        }
        val arguments = HashMap<String, Any>()
        arguments["arg1"] = event.arg1
        arguments["arg2"] = event.arg2
        arguments["eventType"] = event.eventType
        arguments["info"] = event.info
        arguments["data"] = data
        mChannel.invokeMethod(Constant.ON_EVENT, arguments)
    }

    /**
     * 发送AIUI消息
     *
     * @param message 消息内容
     */
    private fun sendMessage(message: AIUIMessage?, result: MethodChannel.Result?) {
        if (mAIUIAgent != null) {
            //确保AIUI处于唤醒状态
            if (mCurrentState != AIUIConstant.STATE_WORKING && !isWakeUpEnable) {
                mAIUIAgent!!.sendMessage(
                    AIUIMessage(AIUIConstant.CMD_WAKEUP, 0, 0, "", null)
                )
            }
            mAIUIAgent!!.sendMessage(message)
            result?.success(null)
        } else {
            result?.error(Constant.AGENT_NOT_CREATE, "AIUI代理尚未创建", null)
        }
    }
}