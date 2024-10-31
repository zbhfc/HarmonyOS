@Component
export default struct CashText{
  @Prop amount:string;
  fontSize:number|string|Resource='12vp';
  fontWeight:number|FontWeight|string=500;
  fontFamily:string|Resource='HarmonyHeiTi-Bold';
  fontColor:ResourceColor='#FFFFFF';
  build(){
    Text(this.amount)
      .fontSize(this.fontSize)
      .fontWeight(this.fontWeight)
      .fontColor(this.fontColor)
      .fontFamily(this.fontFamily)
      .baselineOffset(-50)
      .textAlign(TextAlign.Start)
  }
}