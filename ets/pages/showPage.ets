import router from '@ohos.router'
import { CustomPieChart, PicChartElement } from '../view/chart'
import AccountData from '../viewmodel/AccountData'
@Entry
@Component
struct ShowPage {
  @State message: string = 'Hello World'
  private picChartElements: PicChartElement[] = []
  private picChartElements2: PicChartElement[] = []
  private accounts: AccountData[]=router.getParams()?.['data']
  private col:string[]=['#ff9421','#ffd100','#4cd041','#4cd0ee','#999999','#ED1C24','#00CCCC','#4169E1','#EED202','#FF6700','#FF6FFF']
  private text:string=router.getParams()?.['title']
  private c1:Boolean=false
  private c2:Boolean=false
  aboutToAppear(){
    for(let i=0;i<this.accounts.length;++i){//饼图数据导入
      if(this.accounts[i].accountType==0)
      {
        this.c1=true
        for(let j=0;j<this.picChartElements.length;++j)
        {
          if(this.picChartElements[j].element==this.accounts[i].typeText)
          {
            this.c1=false
          }
        }
        if(this.c1)
        this.picChartElements.push(new PicChartElement(this.accounts[i].typeText,this.accounts[i].amount,this.col[this.picChartElements.length]))
        else
        {
          for(let j=0;j<this.picChartElements.length;++j){
            if(this.picChartElements[j].element==this.accounts[i].typeText){//合并相同支出
              this.picChartElements[j].quantity+=this.accounts[i].amount
            }
          }
        }
      }
      else
      {
        this.c2=true
        for(let j=0;j<this.picChartElements2.length;++j)
          if(this.picChartElements2[j].element==this.accounts[i].typeText)
            this.c2=false
        if(this.c2)
          this.picChartElements2.push(new PicChartElement(this.accounts[i].typeText,this.accounts[i].amount,this.col[this.picChartElements.length]))
        else
          for(let j=0;j<this.picChartElements2.length;++j)
            if(this.picChartElements2[j].element==this.accounts[i].typeText)//合并相同收入
              this.picChartElements2[j].quantity+=this.accounts[i].amount
      }
    }
  }
  build() {
      Column() {
        Text(this.text)
          .height("55vp")
          .fontSize('50vp')
          .margin({left:'24vp'})
        CustomPieChart({picChartElements: this.picChartElements})
            .position({x:'3%',y:'10%'})
        Text('支出')
          .height("35vp")
          .fontSize('30vp')
          .margin({left:'24vp'})
          .position({x:'45%',y:'40%'})
        CustomPieChart({picChartElements: this.picChartElements2})
          .position({x:'3%',y:'45%'})
        Text('收入')
          .height("35vp")
          .fontSize('30vp')
          .margin({left:'24vp'})
          .position({x:'45%',y:'75%'})
        Button("返回")
        .fontSize(30)
        .onClick(()=>{
          router.back()
        })
        .position({x:'22%',y: "85%"})
        .width("60%")
      }
      .width('100%')
  }
}