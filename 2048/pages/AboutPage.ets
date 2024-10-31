@Entry
@Component
struct AboutPage {
  @State message: string = '2048'
  build() {
    Row() {
      Column(){
          Column(){
            Text("游戏介绍")
              .width("100%")
              .height("100%")
              .fontSize(40)
              .textAlign(TextAlign.Center)
          }
          .width("90%")
          .height('10%')
          Column(){
            Text('2048是一款比较流行的数字游戏，每次可以选择上下左右其中一个方向去滑动，每滑动一次，所有的数字方块都会往滑动的方向靠拢外，系统也会在空白的地方乱数出现一个数字方块，相同数字的方块在靠拢、相撞时会相加,每次相加会获得对应的分数。不断的叠加最终拼凑出2048这个数字就算成功。')
              .width("100%")
              .height("100%")
              .fontSize(25)
              .textAlign(TextAlign.Center)
          }
          .width("90%")
          .height('40%')
      }
      .width('100%')
    }
    .height('100%')
    .backgroundImage($rawfile('bg.png'))
    .backgroundImageSize(ImageSize.Cover)
  }
}