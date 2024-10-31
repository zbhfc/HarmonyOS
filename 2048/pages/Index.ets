import router from '@ohos.router'
import image from '@ohos.multimedia.image'
@Entry
@Component
struct Index {
  build() {
    Row(){
      Column(){
        Column(){
          Text("2048")
            .width("100%")
            .height("100%")
            .fontSize(100)
            .textAlign(TextAlign.Center)
            .fontColor(0xB96A38)
            .fontWeight(FontWeight.Bolder)
        }
        .width("90%")
        .height('15%')
        .margin("5%")
        Column(){
          Text("开始游戏")
            .fontSize(60)
            .textAlign(TextAlign.Center)
            .fontColor(0xB96A38)
            .fontWeight(FontWeight.Bolder)
            .textAlign(TextAlign.Center)
            .border({ width: 5, color: 0xB96A38, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              router.pushUrl({url:'pages/GamePage'})
            })
        }
        .width("90%")
        .height('15%')
        .margin("5%")
        .justifyContent(FlexAlign.Center)
        Column(){
          Text("游戏介绍")
            .fontSize(60)
            .textAlign(TextAlign.Center)
            .fontColor(0xB96A38)
            .fontWeight(FontWeight.Bolder)
            .textAlign(TextAlign.Center)
            .border({ width: 5, color: 0xB96A38, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              router.pushUrl({url:"pages/AboutPage"})
            })
        }
        .width("90%")
        .height('15%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .height("100%")
    .backgroundImage($rawfile('bg.png'))
    .backgroundImageSize(ImageSize.Cover)
  }
}