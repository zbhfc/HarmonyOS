@CustomDialog
export struct CustomMonthPickerDialog{
  @Link yearValue:string
  @Link monthValue:string
  @Link searchValue:string
  controller:CustomDialogController
  cancel:()=>void
  confirm?:(yearValue:string,monthValue:string,searchValue:string)=>void
  build(){
    Column(){
      Text('请输入待查询年月').fontSize(20).margin({top:10,bottom:10})
      Row(){
        TextInput({placeholder:'',text:this.yearValue}).height(40).width(100)
          .onChange((value:string)=>{
            this.yearValue=value
          })
        Text('年').fontSize(20).margin({top:10,bottom:10})
        TextInput({placeholder:'',text:this.monthValue}).height(40).width(100)
          .onChange((value:string)=>{
            this.monthValue=value
          })
        Text('月').fontSize(20).margin({top:10,bottom:10})
      }
      Flex({justifyContent:FlexAlign.SpaceAround}){
        Button('取消')
          .onClick(()=>{
            this.controller.close()
            this.cancel
          }).backgroundColor(0xffffff).fontColor(Color.Red)
        Divider().vertical(true).height(22).color('#ff647a91').opacity(0.6).margin({left:8,right:8})
        Button('确认')
          .onClick(()=>{
            this.searchValue=this.yearValue+'-'+this.monthValue
            this.controller.close()
            this.confirm(this.yearValue,this.monthValue,this.searchValue)
          }).backgroundColor(0xffffff).fontColor(Color.Black)
      }.margin({bottom:10})
    }
  }
}