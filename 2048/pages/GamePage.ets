import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
@Entry
@Component
struct GamePage {
  @State message: string = 'Hello World'
  @State score:number=0
  @State dir:number=2048
  @State lose:boolean=false//判断游戏是否结束
  @State move:boolean=false//判断当前操作是否有方块移动
  @State select:number=7
  @State version:string[]=['32','64','128','256','512','1024','2048']
  @State ck:boolean=false
  @State used:number[][]=[[],[],[],[]]
  @State cnt:number=0
  @State map:number[][]=[[],[],[],[]]
  @State Image:string[]=[]
  update(){//随机生成一个2，然后更新界面
    let k=0
    if(this.cnt%4==0) {//此处采取的生成方法是循环从四个角开始遍历，找到空白格则生成一个2
      for(let i=0;i<4;++i) {
        for (let j = 0;j < 4; ++j)
          if (this.map[i][j] == 0) {
            this.map[i][j] = 2;
            k = 1
            break
          }
        if(k==1)break
      }
    }
    if(this.cnt%4==1)
      for(let i=0;i<4;++i)
      {
        for(let j=3;j>=0;--j)
          if(this.map[i][j]==0) {
            this.map[i][j]=2;
            k=1
            break
          }
        if(k==1)break
      }
    if(this.cnt%4==2)
      for(let i=3;i>=0;--i)
      {
        for(let j=0;j<4;++j)
          if(this.map[i][j]==0) {
            this.map[i][j]=2;
            k=1
            break
          }
        if(k==1)break
      }
    if(this.cnt%4==3)
      for(let i=3;i>=0;--i)
      {
        for(let j=3;j>=0;--j)
          if(this.map[i][j]==0) {
            this.map[i][j]=2;
            k=1
            break
          }
        if(k==1)break
      }

    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j){
        this.Image[i*4+j]=this.map[i][j].toString()+'.png'//更新图片
      }
  }
  check(){//检查所有格子是否被填满
    this.ck=false
    for(let i=0;i<4;++i){
      for(let j=0;j<4;++j)
        if(this.map[i][j]==0){
          this.ck=true
          break
        }
    }
    return this.ck
  }
  up(){//向上操作
    for(let i=0;i<4;++i)//used数组是为防止一个格子被连加两遍
      for(let j=0;j<4;++j)
        this.used[i][j]=0
    this.move=false
    for(let i=1;i<4;++i)//从上到下枚举
    {
      for(let j=0;j<4;++j) {
        if(this.map[i][j]!=0){//先找空格
          let ii=i
          for(let k=1;k<i;++k){
            if(this.map[k][j]==0){
              this.map[k][j]=this.map[i][j]
              this.map[i][j]=0
              ii=k
              this.move=true
              break
            }
          }
          if(this.map[ii-1][j]==this.map[ii][j]&&this.used[ii-1][j]==0) {//再看能不能合并
            this.score+=this.map[ii][j]*2
            this.map[ii-1][j]=this.map[ii][j]*2
            this.map[ii][j]=0
            this.used[ii-1][j]=1;
            this.move=true
          }
          else if(this.map[ii-1][j]==0){//最上面一格没看，特殊判断
            this.map[ii-1][j]=this.map[ii][j]
            this.map[ii][j]=0
            this.move=true
          }
        }
      }
    }
    if(this.move)//有移动则要更新
    {
      this.cnt++
      this.update()
    }
    if(!this.move&&!this.check()){//没有移动且满了，则失败
      this.lose=true
    }
  }
  down(){//同up，不多赘述
    this.move=false
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j)
        this.used[i][j]=0
    for(let i=2;i>=0;--i) {
      for(let j=0;j<4;++j) {
        if(this.map[i][j]!=0){
          let ii=i
          for(let k=2;k>i;--k){
            if(this.map[k][j]==0){
              this.map[k][j]=this.map[i][j]
              this.map[i][j]=0
              ii=k
              this.move=true
              break
            }
          }
          if(this.map[ii+1][j]==this.map[ii][j]&&this.used[ii+1][j]==0) {
            this.score+=this.map[ii][j]*2
            this.map[ii+1][j]=this.map[ii][j]*2
            this.map[ii][j]=0
            this.used[ii+1][j]=1
            this.move=true
          }
          else if(this.map[ii+1][j]==0){
            this.map[ii+1][j]=this.map[ii][j]
            this.map[ii][j]=0
            this.move=true
          }
        }
      }
    }
    if(this.move)
    {
      this.cnt++
      this.update()
    }
    if(!this.move&&!this.check()){
      this.lose=true
    }
  }
  left(){//同up，不多赘述
    this.move=false
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j)
        this.used[i][j]=0
    for(let j=1;j<4;++j){
      for(let i=0;i<4;++i){
        if(this.map[i][j]!=0){
          let jj=j
          for(let k=1;k<j;++k){
            if(this.map[i][k]==0){
              this.map[i][k]=this.map[i][j];
              this.map[i][j]=0
              jj=k
              this.move=true
              break
            }
          }
          if(this.map[i][jj-1]==this.map[i][jj]&&this.used[i][jj-1]==0){
            this.score+=this.map[i][jj]*2;
            this.map[i][jj-1]=this.map[i][jj]*2
            this.map[i][jj]=0
            this.used[i][jj-1]=1
            this.move=true
          }
          else if(this.map[i][jj-1]==0){
            this.map[i][jj-1]=this.map[i][jj]
            this.map[i][jj]=0;
            this.move=true
          }
        }
      }
    }
    if(this.move)
    {
      this.cnt++
      this.update()
    }
    if(!this.move&&!this.check()){
      this.lose=true
    }
  }
  right(){//同up，不多赘述
    this.move=false
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j)
        this.used[i][j]=0
    for(let j=2;j>=0;--j){
      for(let i=0;i<4;++i){
        if(this.map[i][j]!=0){
          let jj=j
          for(let k=3;k>j;--k){
            if(this.map[i][k]==0){
              this.map[i][k]=this.map[i][j]
              this.map[i][j]=0
              jj=k
              this.move=true
              break
            }
          }
          if(this.map[i][jj+1]==this.map[i][jj]&&this.used[i][jj+1]==0){
            this.score+=this.map[i][jj]*2
            this.map[i][jj+1]=this.map[i][jj]*2
            this.map[i][jj]=0
            this.used[i][jj+1]=1
            this.move=true
          }
          else if(this.map[i][jj+1]==0){
            this.map[i][jj+1]=this.map[i][jj]
            this.map[i][jj]=0
            this.move=true
          }
        }
      }
    }
    if(this.move)
    {
      this.cnt++
      this.update()
    }
    if(!this.move&&!this.check()){
      this.lose=true
    }
  }
  aboutToAppear(){//初始化，左上角赋为2，分数清零
    this.score=0
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j)
        this.map[i][j]=0;
    this.map[0][0]=2;
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j){
        this.Image[i*4+j]=this.map[i][j].toString()+'.png'
      }
  }
  Checkwin(){//检查是否达到目标
    for(let i=0;i<4;++i)
      for(let j=0;j<4;++j)
        if(this.map[i][j]==this.dir)
          return 1
    return 0
  }
  build() {
    Column() {
      Text('2048')
        .fontSize(60)
        .fontColor(0xB96A38)
        .fontWeight(FontWeight.Bold)
      Text('当前分数:'+this.score.toString())
        .fontSize(50)
      Grid(){
        ForEach(this.Image,(pic:string)=>{//枚举每张图片
          GridItem(){
            Image($rawfile(pic))
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .border({ width: 5,color: 0xB96A38, radius: 5, style: BorderStyle.Dashed })
      .height('50%').margin({ bottom: '5%' }).padding(5)
      .columnsGap(1)
      .rowsGap(1)
      .gesture(GestureGroup(GestureMode.Exclusive,//手势判断
        PanGesture({ direction: PanDirection.Left }).onActionEnd(() => {
          this.left()
          if(this.lose){//输了则弹出提示，且重新开始
            this.lose=false
            promptAction.showDialog({
              title: '游戏失败',
              message: '当前方向不可移动，游戏失败',
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
          if(this.Checkwin()){//达到目标弹出提示，重新开始
            promptAction.showDialog({
              title: '成功通关',
              message: '恭喜你合成了'+this.dir.toString(),
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
        }),
        PanGesture({ direction: PanDirection.Right }).onActionEnd(() => {
          this.right()
          if(this.lose){
            this.lose=false
            promptAction.showDialog({
              title: '游戏失败',
              message: '当前方向不可移动，游戏失败',
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
          if(this.Checkwin()){
            promptAction.showDialog({
              title: '成功通关',
              message: '恭喜你合成了'+this.dir.toString(),
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
        }),
        PanGesture({ direction: PanDirection.Up }).onActionEnd(() => {
          this.up()
          if(this.lose){
            this.lose=false
            promptAction.showDialog({
              title: '游戏失败',
              message: '当前方向不可移动，游戏失败',
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
          if(this.Checkwin()){
            promptAction.showDialog({
              title: '成功通关',
              message: '恭喜你合成了'+this.dir.toString(),
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
        }),
        PanGesture({ direction: PanDirection.Down }).onActionEnd(() => {
          this.down()
          if(this.lose){
            this.lose=false
            promptAction.showDialog({
              title: '游戏失败',
              message: '当前方向不可移动，游戏失败',
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
          if(this.Checkwin()){
            promptAction.showDialog({
              title: '成功通关',
              message: '恭喜你合成了'+this.dir.toString(),
              buttons: [{ text: '确认',color: '#000000' }],
            }).then(data => {
              if(data.index == 0) {
                this.aboutToAppear()
              }
            })
          }
        })
      ))
      Row(){
          Text("重置游戏")
            .margin({right: 10})
            .width('45%')
            .height('100%')
            .fontSize(36)
            .fontColor(0xB96A38)
            .fontWeight(FontWeight.Bolder)
            .textAlign(TextAlign.Center)
            .border({ width: 5, color: 0xB96A38, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              this.aboutToAppear()
            })
          Text("难度选择")
            .width('45%')
            .height('100%')
            .fontSize(36)
            .fontColor(0xB96A38)
            .fontWeight(FontWeight.Bolder)
            .textAlign(TextAlign.Center)
            .border({ width: 5, color: 0xB96A38, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              TextPickerDialog.show({//采用自定义的文本选择来选择难度
                range:this.version,
                selected:this.select,
                onAccept:(version:TextPickerResult)=>{
                  this.select=version.index
                  this.dir=Number(version.value)
                }
              })
            })
      }
      .width('100%')
      .height('10%')
      .justifyContent(FlexAlign.Center)
    }
    .height('100%')
    .width('100%')
    .backgroundImage($rawfile('bg.png'))
    .backgroundImageSize(ImageSize.Cover)
  }
}