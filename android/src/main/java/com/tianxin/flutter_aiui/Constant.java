package com.tianxin.flutter_aiui;

public class Constant {
    public static final String INIT = "init";
    public static final String DISPOSE = "dispose";
    public static final String SET_PARAM = "setParams";

    public static final String START_SPEAK = "startSpeak";
    public static final String END_SPEAK = "endSpeak";
    public static final String WRITE_TEXT = "writeText";
    public static final String RESUME_SPEAK = "resumeSpeak";
    public static final String PAUSE_SPEAK = "pauseSpeak";

    public static final String START_TTS = "startTts";
    public static final String STOP_TTS = "stopTts";
    public static final String PAUSE_TTS = "pauseTts";

    public static final String SYNC_QUERY = "syncQuery";
    
    public static final String IS_WAKEUP_ENABLE = "isWakeUpEnable";
    public static final String VOLUME = "volume";

    public static final String AGENT_CREATED = "onAgentCreated";
    public static final String AGENT_DESTROYED = "onAgentDestroyed";

    public static final String ERROR = "onError";
    public static final String EVENT = "onEvent";

    public static final String NO_AGENT_ERROR_MESSAGE = "AIUIAgent为空，请先创建";
}
