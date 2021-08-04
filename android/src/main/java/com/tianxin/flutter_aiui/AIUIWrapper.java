package com.tianxin.flutter_aiui;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import com.iflytek.aiui.AIUIAgent;
import com.iflytek.aiui.AIUIConstant;
import com.iflytek.aiui.AIUIListener;
import com.iflytek.aiui.AIUIMessage;
import com.iflytek.aiui.AIUISetting;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Objects;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AIUIWrapper {
    private final Context mContext;
    private final Activity mActivity;
    private MethodChannel mChannel;
    private AIUIAgent mAIUIAgent;


    //AIUI当前状态
    private int mCurrentState = AIUIConstant.STATE_IDLE;

    //等待清除历史的标志，在CONNECT_SERVER时处理
    private boolean mPendingHistoryClear;

    //AIUI当前录音状态，避免连续两次startRecordAudio时的录音失败
    public boolean mAudioRecording = false;

    private boolean isWakeUpEnable;
    private final String wakeUpText;

    private String getAIUIParams() {
        String params = "";

        AssetManager assetManager = mContext.getResources().getAssets();
        try {
            InputStream ins = assetManager.open("cfg/aiui_phone.cfg");
            byte[] buffer = new byte[ins.available()];

//            int no_bytes_read = ins.read(buffer);
            ins.close();

            params = new String(buffer);

            JSONObject paramsJson = new JSONObject(params);

            JSONObject vadParams = paramsJson.optJSONObject("vad");
            if (vadParams != null) {
                vadParams.put("vad_eos", "1000");
            }

            JSONObject speechParams = paramsJson.optJSONObject("speech");
            if (speechParams != null) {
                speechParams.put("interact_mode", "continuous");
            }

            params = paramsJson.toString();
        } catch (IOException | JSONException e) {
            e.printStackTrace();
        }

        return params;
    }

    public AIUIWrapper(Context context, Activity activity, MethodChannel channel, MethodChannel.Result result, MethodCall call) {
        mContext = context;
        mActivity = activity;
        mChannel = channel;

        wakeUpText = call.argument("wakeUpText");
        try {
            isWakeUpEnable = Objects.equals(call.argument("isWakeUpEnable"), true);
        } catch (NullPointerException e) {
            isWakeUpEnable = false;
        }

        String config = call.argument("config") == null ? getAIUIParams() : (String) call.argument("config");

        initializeMSCIfExist(context, call.argument("config"));

        // 请求权限
        requestPermissions();

        mPendingHistoryClear = true;
        initAIUIAgent(config, result);
    }

    /**
     * 根据AIUI配置创建AIUIAgent
     */
    public void initAIUIAgent(String config, MethodChannel.Result result) {
        if (mAIUIAgent != null) {
            AIUIAgent temp = mAIUIAgent;
            mAIUIAgent = null;
            temp.destroy();
        }

        mAudioRecording = false;
        AIUISetting.setSystemInfo(AIUIConstant.KEY_SERIAL_NUM, "fake_sn");
        mAIUIAgent = AIUIAgent.createAgent(mContext, config, mAIUIListener);

        mChannel.invokeMethod(Constant.AGENT_CREATED, null);

        //唤醒模式自动开始录音
        if (isWakeUpEnable) {
            startSpeak(result, null);
        } else {
            result.success(null);
        }

    }

    /**
     * 销毁
     */
    public void destroyAgent(MethodChannel.Result result) {
        if (null != mAIUIAgent) {
            mAIUIAgent.destroy();
            mAIUIAgent = null;
            mChannel.invokeMethod(Constant.AGENT_DESTROYED, null);
            result.success(true);
        }
    }

    /**
     * 初始化唤醒服务
     */
    private void initializeMSCIfExist(Context context, String config) {
        try {
            JSONObject json = new JSONObject(config);
            JSONObject login = json.getJSONObject("login");
            Class<?> UtilityClass = Objects.requireNonNull(getClass().getClassLoader()).loadClass("com.iflytek.cloud.SpeechUtility");
            Method createMethod = UtilityClass.getDeclaredMethod("createUtility", Context.class, String.class);
            createMethod.invoke(null, context, "appid="
                    + login.optString("appid") + ",engine_start=ivw");
        } catch (ClassNotFoundException | IllegalAccessException | NoSuchMethodException | InvocationTargetException ignored) {
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 设置参数
     *
     * @param config 配置信息
     */
    public void setParameters(String config) {
        if (config != null) {
            sendMessage(new AIUIMessage(AIUIConstant.CMD_SET_PARAMS, 0, 0, config, null));
        }
    }

    /**
     * 开始语音解析
     */
    public void startSpeak(MethodChannel.Result result, String config) {
        if (mAudioRecording) {
            resultError(result, null, "录音已开始，请勿重复录制");
            return;
        }

        if (null == mAIUIAgent) {
            resultError(result, null, null);
            return;
        }

        if (null == wakeUpText) {
            resultError(result, "23002", "唤醒词不能为空");
            return;
        }

        stopTTS();

        String params = null == config ? "sample_rate=16000,data_type=audio,tag=audio-tag,dwa=wpgs" : config;
        AIUIMessage startRecord = new AIUIMessage(AIUIConstant.CMD_START_RECORD, 0, 0, params, null);

        sendMessage(startRecord);

        mAudioRecording = true;

        result.success(null);
    }

    /**
     * 停止说话
     */
    public void endSpeak() {
        if (mAudioRecording) {
            sendMessage(new AIUIMessage(AIUIConstant.CMD_STOP_RECORD, 0, 0, "data_type=audio,sample_rate=16000", null));
            mAudioRecording = false;
        }
    }

    /**
     * 继续
     * 恢复到前台后，如果是唤醒模式下重新开启录音
     */
    public void onResume(MethodChannel.Result result, String config) {
        if (isWakeUpEnable) {
            startSpeak(result, config);
        }
    }

    /**
     * 暂停
     * 唤醒模式下录音常开，pause时停止录音，避免不再前台时占用录音
     */
    public void onPause() {
        if (isWakeUpEnable) {
            endSpeak();
        }
    }

    /**
     * 文本语义
     *
     * @param text   需要识别的文本
     * @param config 配置信息
     */
    public void writeText(String text, String config) {
        stopTTS();

        // 在输入参数中设置tag，则对应结果中也将携带该tag，可用于关联输入输出
        String params = null == config ? "data_type=text,tag=text-tag" : config;
        byte[] textData = text.getBytes(StandardCharsets.UTF_8);

        sendMessage(new AIUIMessage(AIUIConstant.CMD_WRITE, 0, 0,
                params, textData));

    }

    // 开始语音播报
    public void startTTs(String text, String config, boolean resume) {
        if(!resume) {
            sendMessage(new AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.PAUSE, 0, null, null));
        }


        if(!resume) {
            String tag = "@" + System.currentTimeMillis();

            String params = config == null ? "vcn=x2_xiaojuan" +  //合成发音人
                    ",speed=50" +  //合成速度
                    ",pitch=50" +  //合成音调
                    ",volume=50" +  //合成音量
                    ",ent=x_tts" +  //合成音量
                    ",tag=" + tag : config;//构建合成参数
//合成tag，方便追踪合成结束，暂未实现
            AIUIMessage startTts = new AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.START, 0,
                    params, text.getBytes());
            sendMessage(startTts);
        }

    }

    /**
     * 暂停合成
     */
    public void pauseTTS() {
        sendMessage(new AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.PAUSE, 0, null, null));
    }

    /**
     * 停止合成播放
     */
    public void stopTTS() {
        sendMessage(new AIUIMessage(AIUIConstant.CMD_TTS, AIUIConstant.CANCEL, 0, "", null));
    }

    /**
     * 发送AIUI消息
     *
     * @param message 消息内容
     */
    public void sendMessage(AIUIMessage message) {
        if (mAIUIAgent != null) {
            //确保AIUI处于唤醒状态
            if (mCurrentState != AIUIConstant.STATE_WORKING && !isWakeUpEnable) {
                mAIUIAgent.sendMessage(new AIUIMessage(AIUIConstant.CMD_WAKEUP, 0, 0, "", null));
            }

            mAIUIAgent.sendMessage(message);
        }
    }

    /**
     * 事件监听
     */
    private final AIUIListener mAIUIListener = event -> {
        if (event.eventType == AIUIConstant.EVENT_STATE) {
            mCurrentState = event.arg1;
        } else if (event.eventType == AIUIConstant.EVENT_CONNECTED_TO_SERVER) {
            if (mPendingHistoryClear) {
                mPendingHistoryClear = false;
                //需要在CONNECT_TO_SERVER后才能发送清除历史指令，清除云端的交互历史
                sendMessage(new AIUIMessage(AIUIConstant.CMD_CLEAN_DIALOG_HISTORY, 0, 0, null, null));
            }
        } else if(event.eventType == AIUIConstant.EVENT_SLEEP) {
            Log.d("TAG", "Sleep: ");
        } else if(event.eventType == AIUIConstant.EVENT_WAKEUP) {
            Log.d("TAG", "Wake_Up: ");
        }

        JSONObject json = new JSONObject();
        if (event.data != null) {
            Set<String> keys = event.data.keySet();
            for (String key : keys) {
                try {
                    json.put(key, JSONObject.wrap(event.data.get(key)));
                } catch (JSONException e) {
                    //Handle exception here
                }
            }
        }

        HashMap<String, java.io.Serializable> map = new HashMap<>();
        map.put("arg1", event.arg1);
        map.put("arg2", event.arg2);
        map.put("eventType", event.eventType);
        map.put("info", event.info);
        map.put("data", json.toString());

        mChannel.invokeMethod(Constant.EVENT, map);
    };

    /**
     * 错误返回
     *
     * @param result  为空时调用错误通道
     * @param code    错误代码，为空时默认 NO_AGENT_ERROR_CODE
     * @param message 错误信息，为空时默认 NO_AGENT_ERROR_MESSAGE
     */
    public void resultError(MethodChannel.Result result, String code, String message) {
        String msg = null == message ? Constant.NO_AGENT_ERROR_MESSAGE : message;
        if (null == result) {
            HashMap<String, String> param = new HashMap<>();
            param.put("errorCode", code);
            param.put("errorMessage", msg);
            mChannel.invokeMethod(Constant.ERROR, param);
        } else {
            result.error(code, msg, null);
        }
    }

    /**
     * 申请权限
     */
    private void requestPermissions() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                ActivityCompat.requestPermissions(mActivity, new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_SETTINGS,
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.INTERNET}, 0x0010);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}


