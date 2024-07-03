import { window } from '@kit.ArkUI'

@Entry
@Component
struct Advertisement {
  @State time: number = 5
  timer: number = -1
  aboutToAppear() {
    // 必须重置才能改动画的内容
    this.timer = setInterval(() => {
      if (this.time <= 0) {
        clearInterval(this.timer)
        window.findWindow("ad_win").destroyWindow()
        return
      }
      this.time -= 1
    }, 1000)
  }

  aboutToDisappear() {
    clearInterval(this.timer)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image($r('app.media.003')).objectFit(ImageFit.Fill)
      Button(`跳过${this.time}`)
        .onClick(() => {
          window.findWindow("ad_win").destroyWindow()
        })
        .margin(
          {
            right: 20,
            top: JSON.parse(AppStorage.get("topHeight"))
          }
        )
        .backgroundColor('#ccc')
        .fontColor('#fff')
    }
    .width('100%')
    .height('100%')

  }
}