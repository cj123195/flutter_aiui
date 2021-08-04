class AIUIChannel {
  static const String INIT = "init";
  static const String DISPOSE = "dispose";
  static const String SET_PARAM = "setParams";

  static const String START_SPEAK = "startSpeak";
  static const String END_SPEAK = "endSpeak";
  static const String WRITE_TEXT = "writeText";
  static const String RESUME_SPEAK = "resumeSpeak";
  static const String PAUSE_SPEAK = "pauseSpeak";

  static const String START_TTS = "startTts";
  static const String STOP_TTS = "stopTts";
  static const String PAUSE_TTS = "pauseTts";

  static const String SYNC_QUERY = "syncQuery";

  static const String EVENT = "onEvent";
  static const String ERROR = "onERROR";
  static const String AGENT_CREATED = "onAgentCreated";
  static const String AGENT_DESTROYED = "onAgentDestroyed";
}