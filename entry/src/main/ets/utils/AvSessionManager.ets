import AvSession from '@ohos.multimedia.avsession';
import { songItemType } from '../models';
import { AvPlayerManager } from './AvPlayerManager';

export class AvSessionManager {
  static session: AvSession.AVSession // 单例 媒体会话对象
  static controller: AvSession.AVSessionController // 控制器
  static async init (context: Context) {
    // 拿到会话对象
    AvSessionManager.session = await AvSession.createAVSession(context, "bgPlay", "audio")
    AvSessionManager.controller = await AvSessionManager.session.getController() // 拿到控制器
    AvSessionManager.registerEvent()
  }
  // 设置一些封面信息
  static async setAvMetaData (song: songItemType) {
    await AvSessionManager.session.setAVMetadata({
      assetId: song.id,
      title: song.name,
      artist: song.author,
      author: song.author,
      duration: AvPlayerManager.currentSong.duration,
      mediaImage: song.img
    })
  }
  // 不断的设置播放信息
  static async setAVPlayBackState () {
    AvSessionManager.session.setAVPlaybackState({
      state: AvPlayerManager.currentSong.isPlay ? AvSession.PlaybackState.PLAYBACK_STATE_PLAY
              : AvSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: AvPlayerManager.currentSong.time, // 播到第几秒
        updateTime: new Date().getTime()
      },
      speed: 1,
      duration: AvPlayerManager.currentSong.duration
    })
  }

  // 注册会话对象传递过来的
  static registerEvent () {
    AvSessionManager.session.on("play", () => {
     AvPlayerManager.singlePlay(AvPlayerManager.currentSong.playList[AvPlayerManager.currentSong.playIndex])
    })
    AvSessionManager.session.on("pause", () => {
      AvPlayerManager.pause()
    })
    AvSessionManager.session.on("playPrevious", () => {
      AvPlayerManager.prevPlay()
    })
    AvSessionManager.session.on("playNext", () => {
      AvPlayerManager.nextPlay()
    })
    AvSessionManager.session.on("seek", (time) => {
      AvPlayerManager.player?.seek(time)
    })
    AvSessionManager.session.activate() // 激活这些注册
  }
}