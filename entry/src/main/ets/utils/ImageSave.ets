import { request } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';

export default class ImageSave {
  static async saveFile(fileName: string, url: string, callBack: (path: string) => void) {
    try {
      // 卡片的图片 不能用线上的 只能用内存目录下的图片
      let tempDir = getContext().getApplicationContext().tempDir;
      // 判断如果图片存在就不用下载了
      if (fileIo.listFileSync(tempDir).includes(fileName)) {
        return callBack(tempDir + "/" + fileName)
      }
      // 下载方法
      const task = await request.downloadFile(getContext(), {
        filePath: tempDir + "/" + fileName, // 存储路径
        url // 要下载的地址
      })
      task.on("complete", () => {
        let newPath = tempDir + "/" + fileName
        callBack(newPath)
      })
      task.on("fail", () => {
        AlertDialog.show({
          message: "下载异常"
        })
      })
    } catch (error) {
      AlertDialog.show({
        message: error.message
      })
    }

  }
}