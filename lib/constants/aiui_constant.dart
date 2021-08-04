class AIUIConstant {
  static const int EVENT_RESULT = 1;
  static const int EVENT_ERROR = 2;
  static const int EVENT_STATE = 3;
  static const int EVENT_WAKEUP = 4;
  static const int EVENT_SLEEP = 5;
  static const int EVENT_VAD = 6;
  static const int EVENT_CMD_RETURN = 8;
  static const int EVENT_PRE_SLEEP = 10;
  static const int EVENT_START_RECORD = 1;
  static const int EVENT_STOP_RECORD = 12;
  static const int EVENT_CONNECTED_TO_SERVER = 13;
  static const int EVENT_SERVER_DISCONNECTED = 14;
  static const int EVENT_TTS = 15;

  static const int VAD_BOS = 0;
  static const int VAD_VOL = 1;

  static const int TTS_SPEAK_BEGIN = 1;
  static const int TTS_SPEAK_COMPLETED = 5;
  static const int TTS_SPEAK_PAUSED = 2;
  static const int TTS_SPEAK_PROGRESS = 4;
  static const int TTS_SPEAK_RESUMED = 3;
}
