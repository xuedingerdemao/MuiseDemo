import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SONG_KEY } from '../constants';
import rpc from '@ohos.rpc';
import { formBindingData, formProvider } from '@kit.FormKit';
import { AvPlayerManager } from '../utils/AvPlayerManager';
import { AvSessionManager } from '../utils/AvSessionManager';
import FormIdManager from '../utils/FormIdManager';
import SongManager from '../utils/SongManager';

class Params implements rpc.Parcelable {
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }
}

class ParamsForm {
  formId: string = ""
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AvPlayerManager.init() // 直接初始化播放器
    AvSessionManager.init(this.context)

    this.callee.on("getFormId", (data) => {
      const res = JSON.parse(data.readString()) as ParamsForm
      FormIdManager.addFormId(res.formId).then(() => {
        AvPlayerManager.pushImage() // 硬推一次
      }) // 加入formId
      // 先推一次
      // formProvider.updateForm(res.formId, formBindingData.createFormBindingData({
      //   song: AvPlayerManager.currentSong // 当前歌曲推过去
      // }))
      return new Params() // 只是为了不报错
    })
    this.callee.on("prev", (data) => {
      AvPlayerManager.prevPlay()
      return new Params() // 只是为了不报错
    })
    this.callee.on("next", (data) => {
      AvPlayerManager.nextPlay()
      return new Params() // 只是为了不报错
    })
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    const win = await windowStage.getMainWindow()
    win.setWindowLayoutFullScreen(true)
    AppStorage.setOrCreate("topHeight", px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      .topRect.height))
    AppStorage.setOrCreate("bottomHeight", px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      .bottomRect.height))
    const childWin = await windowStage.createSubWindow("ad_win") // 创建广告子窗口
    await childWin.showWindow()
    await childWin.setUIContent("pages/Start/Start")
    FormIdManager.context = this.context // 给首选项存储formId的首选项赋值上下文
    // 从首选项读取缓存的播放列表
    SongManager.context = this.context
    const currentSong = await SongManager.getSong() // 给播放器
    currentSong.isPlay = false // 不论什么情况 肯定都是关着呢
    AvPlayerManager.currentSong = currentSong // 并没有给到duration
    if(AvPlayerManager.currentSong.url) {
      AvPlayerManager.player!.url = AvPlayerManager.currentSong.url // 会自动播放
      AppStorage.setOrCreate("firstplay", 1) // 首次播放
    }
    AppStorage.setOrCreate(SONG_KEY, AvPlayerManager.currentSong) // 更新全局状态
    windowStage.loadContent("pages/Index/Index")
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
