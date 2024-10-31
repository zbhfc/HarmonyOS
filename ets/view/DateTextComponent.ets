@Component
export default struct DateText{
  @Prop title:string;
  fontSize:number|string|Resource='16vp';
  fontWeight:number|FontWeight|string=500;
  fontFamily:string|Resource='HarmonyHeiTi-Bold';
  fontColor:ResourceColor='#FF000000';
  build(){
    Text(this.title)
      .fontSize(this.fontSize)
      .fontWeight(this.fontWeight)
      .fontColor(this.fontColor)
      .fontFamily(this.fontFamily)
  }
}