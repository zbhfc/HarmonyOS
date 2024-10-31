/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import AccountTable from '../common/database/tables/AccountTable';
import AccountData from '../viewmodel/AccountData';
import CommonConstants from '../common/constants/CommonConstants';
import { DialogComponent } from '../view/DialogComponent';
import { ImageList } from '../viewmodel/AccountList';
import Logger from '../common/utils/Logger';
import DateText from '../view/DateTextComponent';
import CashText from '../view/CashTextComponent';
import { DateFormat, dateFormat } from '../common/utils/Utils';
import { ScrollData } from '../viewmodel/ScrollData';
import { CustomMonthPickerDialog } from '../view/CustomMonthPickerController';
import Prompt from '@system.prompt';
import prompt from '@ohos.promptAction';
import { CustomSearchDialog } from '../view/CustomSearchDialog';
import router from '@ohos.router'
import { CustomPieChart } from '../view/chart';
const THEME_NAMES:string[]=['所有账单','年度账单','月度账单','日账单','测试数据']
@Entry
@Component
struct MainPage {
  @State accounts: Array<AccountData> = [];
  @State scroll_accounts:Array<ScrollData>=[];
  @State searchText: string = '';
  @State isEdit: boolean = false;
  @State isInsert: boolean = true;
  @State isTested: boolean = false;
  @State yearValue: string = '';
  @State monthValue: string = '';
  @State searchValue: string = '';
  @State submitValue: string = '';
  @State cur_search_text: string = '';
  @State today_incomeValue: number = 0;
  @State today_outcomeValue: number = 0;
  @State today_earningValue: number = 0;
  @State newAccount: AccountData = {
    id: 0,
    accountType: 0,
    typeText: '',
    amount: 0,
    date: '',
    year: '',
    month: '',
    reminder: ''
  };
  @State index: number = -1;
  private deleteWidth=100
  private downX=0
  private scroll2DeleteData:ScrollData=null
  selected_date:Date;
  private select:number=8
  private years:string []=['2015','2016','2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030']//年份选择
  controller:TextInputController=new TextInputController()


  private AccountTable = new AccountTable(() => {
  });
  private deleteList: Array<AccountData> = [];
  searchController: SearchController = new SearchController();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DialogComponent({
      isInsert: $isInsert,
      newAccount: $newAccount,
      confirm: (isInsert: boolean, newAccount: AccountData) => this.accept(isInsert, newAccount)
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });
  accept(isInsert: boolean, newAccount: AccountData): void {
    if (isInsert) {
      Logger.info(`${CommonConstants.INDEX_TAG}`, `The account inserted is:  ${JSON.stringify(newAccount)}`);
      this.AccountTable.insertData(newAccount, (id: number) => {
        newAccount.id = id;
        this.accounts.push(newAccount);
        this.scroll_accounts.push({accountData:newAccount,scroller:new Scroller()})
      });
      if(newAccount!=null){
        if(newAccount.accountType===0)this.today_outcomeValue+=this.newAccount.amount;
        else this.today_incomeValue+=this.newAccount.amount;
        this.today_earningValue=this.today_incomeValue-this.today_outcomeValue;
      }
    } else {
      this.AccountTable.updateData(newAccount, () => {
      });
      let list = this.accounts;
      this.accounts = [];
      list[this.index] = newAccount;
      this.accounts = list;
      this.index = -1;
    }
  }
  accountData2ScrollData(accounts:AccountData[]){
    this.scroll_accounts=[]
    for(let i=0;i<accounts.length;++i){
      this.scroll_accounts.push({accountData:accounts[i],scroller:new Scroller()})
    }
  }
  calculate(account:AccountData[]){
    this.today_outcomeValue=0;
    this.today_incomeValue=0;
    this.today_earningValue=0;
    for(let i=0;i<account.length;++i){
      if(account[i].accountType===0){
        this.today_outcomeValue+=account[i].amount;
      }
      else{
        this.today_incomeValue+=account[i].amount;
      }
    }
    this.today_earningValue=this.today_incomeValue-this.today_outcomeValue;
  }
  aboutToAppear() {
    this.AccountTable.getRdbStore(() => {
      this.AccountTable.query('', (result: AccountData[]) => {
        this.accounts = result;
        this.initSearchDate()
        this.accountData2ScrollData(this.accounts)
        this.calculate(this.accounts)
        this.cur_search_text='所有账单'
      }, true);
    });
  }
  initSearchDate(){
    let cur_date=new Date()
    this.cur_search_text=DateFormat(cur_date.getTime())
  }
  selectListItem(item: AccountData) {
    this.isInsert = false;
    this.index = this.accounts.indexOf(item);
    this.newAccount = {
      id: item.id,
      accountType: item.accountType,
      typeText: item.typeText,
      amount: item.amount,
      date: item.date,
      year: item.year,
      month: item.month,
      reminder: item.reminder
    };
  }
  CustomMonthPickerController:CustomDialogController=new CustomDialogController({
    builder:CustomMonthPickerDialog({
      yearValue:$yearValue,
      monthValue:$monthValue,
      searchValue:$searchValue,
      confirm:(yearValue:string,monthValue:string,searchValue:string)=>this.customAccept(yearValue,
      monthValue,
      searchValue)
    }),
    autoCancel:true,
    alignment:DialogAlignment.Bottom,
    offset:{dx:0,dy:-10},
    gridCount:4,
    customStyle:false
  })
  searchDialogController:CustomDialogController=new CustomDialogController({
    builder:CustomSearchDialog({
      confirm:(submitValue:string)=>this.customSearchAccept(submitValue),
      submitValue:$submitValue,
    }),
    autoCancel:true,
    alignment:DialogAlignment.Bottom,
    gridCount:4,
    customStyle:false
  })
  customSearchAccept(submitValue:string){
    if(this.submitValue!=''){
      this.AccountTable.queryType(submitValue,(result:AccountData[])=>{
        this.accounts=result
        this.calculate(this.accounts)
        this.accountData2ScrollData(this.accounts)
      },false)
      this.cur_search_text='搜索结果'
    }
  }
  aboutToDisappear(){
    delete this.dialogController
    this.dialogController=undefined
  }
  customAccept(yearValue:string,monthValue:string,searchValue:string){
    if(yearValue==''||monthValue==''){
      prompt.showToast({message:'不能为空',bottom:CommonConstants.PROMPT_BOTTOM});
    }else{
      this.cur_search_text=yearValue+'年'+monthValue+'月'
      this.searchValue=searchValue
      if(this.searchValue!=''){
        this.AccountTable.queryMonth(String(this.searchValue),(result:AccountData[])=>{
          this.accounts=result
          this.calculate(this.accounts)
          this.accountData2ScrollData(this.accounts)
        },false);
      }
    }
  }
  deleteListItem() {
    for (let i = 0; i < this.deleteList.length; i++) {
      if(this.deleteList[i].accountType===0)this.today_outcomeValue-=this.newAccount.amount;
      else this.today_incomeValue-=this.newAccount.amount;
      this.today_earningValue=this.today_incomeValue-this.today_outcomeValue;
      let index = this.accounts.indexOf(this.deleteList[i]);
      this.accounts.splice(index, 1);
      this.AccountTable.deleteData(this.deleteList[i], () => {
      });
    }
    this.deleteList = [];
    this.isEdit = false;
  }
  @Builder CustomItem(item:ScrollData) {
    Scroll(item.scroller) {
      Row() {
        Row() {
          Image(ImageList[item.accountData.typeText])
            .width('40vp')
            .aspectRatio(CommonConstants.FULL_SIZE)
            .margin({ right: '16vp' })
            .onClick(() => {
              //this.selectListItem(item.accountData);
              //this.dialogController.open();
            })
          if (!this.isEdit) {
            Column() {
              Text(item.accountData.typeText)
                .height('22vp')
                .fontSize('16vp')
              Text(item.accountData.date + ' ')
                .fontSize('12vp')
                .fontColor('#FF13A6D0')
                .align(Alignment.Start)
                .flexGrow(CommonConstants.FULL_SIZE)
            }
            .alignItems(HorizontalAlign.Start)

            Divider()
              .vertical(true)
              .height(22)
              .color('#FF000000')
              .opacity(0.6)
              .margin({ left: 8, right: 8 })
            Text('备注: ' + item.accountData.reminder.toString())
              .fontSize('12vp')
              .fontColor('#FFA6A8AB')
              .align(Alignment.BottomEnd)
              .flexGrow(CommonConstants.FULL_SIZE)
            Blank()
              .layoutWeight(1)
            Text(item.accountData.accountType === 0 ? '-' + item.accountData.amount.toString() : '+' + item.accountData.amount.toString())
              .fontSize('16vp')
              .fontColor(item.accountData.accountType === 0 ? '#FF6A9F40' : '#FFF54D38')
              .align(Alignment.End)
              .flexGrow(CommonConstants.FULL_SIZE)
          }
          else {
            Row() {
              Column() {
                Text(item.accountData.typeText)
                  .height('22vp')
                  .fontSize('16vp')
                Text(item.accountData.date + ' ')
                  .fontSize('12vp')
                  .fontColor('#FF13A6D0')
                  .align(Alignment.Start)
                  .flexGrow(CommonConstants.FULL_SIZE)
              }
              .alignItems(HorizontalAlign.Start)

              Divider()
                .vertical(true)
                .height(22)
                .color("FF000000")
                .opacity(0.6)
                .margin({ left: 8, right: 8 })
              Text('备注: ' + item.accountData.reminder.toString())
                .fontColor('#FFA6A0AB')
                .fontSize('12vp')
                .align(Alignment.BottomEnd)
                .flexGrow(CommonConstants.FULL_SIZE)
              Toggle({ type: ToggleType.Checkbox })
                .onChange((isOn) => {
                  if (isOn) {
                    this.deleteList.push(item.accountData)
                  } else {
                    let index = this.deleteList.indexOf(item.accountData);
                    this.deleteList.splice(index, 1);
                  }
                })
            }
            .align(Alignment.End)
            .flexGrow(CommonConstants.FULL_SIZE)
            .justifyContent(FlexAlign.End)
          }
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: '12vp', right: '12vp' })
        .onClick(()=>{
          if(this.scroll2DeleteData!=null){
            this.scroll2DeleteData.scroller.scrollTo({xOffset:0,yOffset:0,
            animation:{duration:100,curve:Curve.Linear}})
            this.scroll2DeleteData=null
            return
          }
        })
        Button(){
          Text('删除')
            .fontSize(15)
            .fontColor(Color.White)
        }
        .type(ButtonType.Normal)
        .height(65)
        .backgroundColor(Color.Red)
        .onClick(()=>{
          if(item.accountData.accountType===0)this.today_outcomeValue-=item.accountData.amount
          else this.today_incomeValue-=item.accountData.amount
          this.today_earningValue=this.today_incomeValue-this.today_outcomeValue
          this.scroll_accounts.splice(this.scroll_accounts.indexOf(item),1)
          this.accounts.splice(this.accounts.indexOf(item.accountData),1)
          this.AccountTable.deleteData(item.accountData, () => {
          });
          //this.deleteList.push(item.accountData)
          //this.deleteListItem()
          if(this.scroll2DeleteData!=null){
            this.scroll2DeleteData.scroller.scrollTo({xOffset:0,yOffset:0,
            animation:{duration:100,curve:Curve.Linear}})
            this.scroll2DeleteData=null
          }
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .onTouch((event: TouchEvent) => {
      if (this.scroll2DeleteData != null && this.scroll2DeleteData != item) {
        this.scroll2DeleteData.scroller.scrollTo({ xOffset: 0, yOffset: 0,
          animation: { duration: 100, curve: Curve.Linear } })
      }
      switch (event.type){
        case TouchType.Down:
          this.downX=event.touches[0].x
          break
        case TouchType.Up:
          let xOffset=event.touches[0].x-this.downX
          if(xOffset==0){
            return
          }
          var toxOffset=0
          this.scroll2DeleteData=null
          if(Math.abs(xOffset)>vp2px(this.deleteWidth)/2&&xOffset<0){
            toxOffset=vp2px(this.deleteWidth)
            this.scroll2DeleteData=item
          }
          item.scroller.scrollTo({xOffset:toxOffset,yOffset:0,
          animation:{duration:300,curve:Curve.Linear}})
          this.downX=0
          break
      }
    })
    /*Button(){
      Text('删除')
        .fontSize(15)
        .fontColor(Color.White)
    }
    .type(ButtonType.Normal)
    .height(55)
    .backgroundColor(Color.Red)
    .onClick(()=>{

    })*/
  }
  /*build() {
    Stack() {
      Column() {
        Row() {
          Text('记账本')
            .height($r('app.float.component_size_SP'))
            .fontSize($r('app.float.font_size_L'))
            .margin({ left: $r('app.float.font_size_L') })

          Image($rawfile('ic_public_edit.svg'))
            .width($r('app.float.component_size_S'))
            .aspectRatio(CommonConstants.FULL_SIZE)
            .margin({ right: $r('app.float.font_size_L') })
            .onClick(() => {
              this.isEdit = true;
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })

        Row() {
          Search({
            value: this.searchText,
            placeholder: CommonConstants.SEARCH_TEXT,
            controller: this.searchController
          })
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.radius_size_M'))
            .borderWidth($r('app.float.border_size_S'))
            .borderColor($r('app.color.border_color'))
            .placeholderFont({ size: $r('app.float.font_size_M') })
            .textFont({ size: $r('app.float.font_size_M') })
            .backgroundColor(Color.White)
            .onChange((searchValue: string) => {
              this.searchText = searchValue;
            })
            .onSubmit((searchValue: string) => {
              if (searchValue === '') {
                this.AccountTable.query('', (result: AccountData[]) => {
                  this.accounts = result;
                }, true);
              } else {
                this.AccountTable.query('', (result: AccountData[]) => {
                  this.accounts = result;
                }, false);
              }
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
        .margin({ top: $r('app.float.edge_size_S'), bottom: $r('app.float.edge_size_S') })

        Row() {
          List({ space: CommonConstants.FULL_SIZE }) {
            ForEach(this.accounts, (item: AccountData) => {
              ListItem() {
                Row() {
                  Image(ImageList[item.typeText])
                    .width($r('app.float.component_size_M'))
                    .aspectRatio(CommonConstants.FULL_SIZE)
                    .margin({ right: $r('app.float.edge_size_MP') })

                  Text(item.typeText)
                    .height($r('app.float.component_size_SM'))
                    .fontSize($r('app.float.font_size_M'))

                  Blank()
                    .layoutWeight(1)

                  if (!this.isEdit) {
                    Text(item.accountType === 0 ? '-' + item.amount.toString() : '+' + item.amount.toString())
                      .fontSize($r('app.float.font_size_M'))
                      .fontColor(item.accountType === 0 ? $r('app.color.pay_color') : $r('app.color.main_color'))
                      .align(Alignment.End)
                      .flexGrow(CommonConstants.FULL_SIZE)
                  } else {
                    Row() {
                      Toggle({ type: ToggleType.Checkbox })
                        .onChange((isOn) => {
                          if (isOn) {
                            this.deleteList.push(item);
                          } else {
                            let index = this.deleteList.indexOf(item);
                            this.deleteList.splice(index, 1);
                          }
                        })
                    }
                    .align(Alignment.End)
                    .flexGrow(CommonConstants.FULL_SIZE)
                    .justifyContent(FlexAlign.End)
                  }

                }
                .width(CommonConstants.FULL_WIDTH)
                .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
              }
              .width(CommonConstants.FULL_WIDTH)
              .height($r('app.float.component_size_LM'))
              .onClick(() => {
                this.selectListItem(item);
                this.dialogController.open();
              })
            })
          }
          .width(CommonConstants.FULL_WIDTH)
          .borderRadius($r('app.float.radius_size_L'))
          .backgroundColor(Color.White)
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
        .margin({ top: $r('app.float.edge_size_SM') })

      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)

      if (!this.isEdit) {
        Button() {
          Image($rawfile('add.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .position({ x: CommonConstants.EDIT_POSITION_X, y: CommonConstants.EDIT_POSITION_Y })
        .onClick(() => {
          this.isInsert = true;
          this.newAccount = { id: 0, accountType: 0, typeText: '', amount: 0, date:'2023年11月10日' , year:'',month:'',reminder:'' };
          this.dialogController.open();
        })
      }

      if (this.isEdit) {
        Button() {
          Image($rawfile('delete.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .backgroundColor($r('app.color.background_color'))
        .markAnchor({ x: $r('app.float.mark_anchor'), y: CommonConstants.MINIMUM_SIZE })
        .position({ x: CommonConstants.DELETE_POSITION_X, y: CommonConstants.DELETE_POSITION_Y })
        .onClick(() => {
          this.deleteListItem();
        })
      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.background_color'))
  }
}*/
  build() {
    Column(){
      List({space:CommonConstants.FULL_SIZE,initialIndex:0}) {
        ListItem(){
          Row(){
            Text('记账本')
              .height("33vp")
              .fontSize('24vp')
              .margin({left:'24vp'})
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({top:'12vp',bottom:'11vp'})
        }
        ListItem(){
          Row(){
            DateText({
              title:this.cur_search_text,
              fontSize:$r('app.float.font_size_M'),
              fontFamily:'HarmonyHeiTi-Bold',
              fontWeight:500
            })
          }
          .width(CommonConstants.FULL_WIDTH)
          .padding({left:$r('app.float.edge_size_M'),right:$r('app.float.edge_size_M')})
          .margin({top:$r('app.float.edge_size_S'),bottom:$r('app.float.edge_size_S')})
        }
        ListItem(){
          Column(){
            CashText({
              amount:'结余: '+this.today_earningValue.toString(),
              fontSize:$r('app.float.font_size_L'),
              fontFamily:'HarmonyHeiTi_Bold',
              fontWeight:500
            })
            Row(){
              CashText({
                amount:'收入: '+this.today_incomeValue.toString(),
                fontSize:$r('app.float.font_size_L'),
                fontFamily:'HarmonyHeiTi_Bold',
                fontWeight:500
              })
              CashText({
                amount:'支出: '+this.today_outcomeValue.toString(),
                fontSize:$r('app.float.font_size_L'),
                fontFamily:'HarmonyHeiTi_Bold',
                fontWeight:500
              })
            }
          }
          .width('100%')
          .height('25%')
          .backgroundImage($rawfile('111.png'),ImageRepeat.NoRepeat)
          .backgroundImageSize(ImageSize.Cover)
          .alignItems(HorizontalAlign.Start)
        }
        ForEach(this.scroll_accounts,(item:ScrollData)=>{
          ListItem(){
            this.CustomItem(item)
          }
          .width(CommonConstants.FULL_WIDTH)
          .height('56vp')
        })
      }
      .borderRadius('24vp')
      .backgroundColor(Color.White)
      .width(CommonConstants.FULL_WIDTH)
      if (!this.isEdit) {
        Button() {
          Image($rawfile('add.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .position({ x: CommonConstants.EDIT_POSITION_X, y: CommonConstants.EDIT_POSITION_Y })
        .onClick(() => {
          this.isInsert = true;
          this.newAccount = { id: 0, accountType: 0, typeText: '', amount: 0, date:'2023年11月10日' , year:'2023',month:'2023-11',reminder:'' };
          this.dialogController.open();
        })
        Button(){
          Image($rawfile('search.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .position({x:'60%',y: CommonConstants.EDIT_POSITION_Y})
        .bindMenu([
          {
            value:THEME_NAMES[0],
            action:()=>{
              this.cur_search_text='所有账单'
              this.AccountTable.query('',(result:AccountData[])=>{
                this.accounts=result
                this.accountData2ScrollData(this.accounts)
                this.calculate(this.accounts)
              },true);
              this.index=-1
            }
          },
          {
            value:THEME_NAMES[1],
            action:()=>{
              TextPickerDialog.show({
                range:this.years,
                selected:this.select,
                onAccept:(year_text:TextPickerResult)=>{
                  this.select=year_text.index
                  this.cur_search_text=year_text.value+'年'
                  this.AccountTable.queryYear(String(year_text.value),(result:AccountData[])=>{
                    this.accounts=result;
                    this.calculate((this.accounts))
                    this.accountData2ScrollData(this.accounts)
                  },false);
                }
              })
            }
          },
          {
            value:THEME_NAMES[2],
            action:()=>{
              if(this.CustomMonthPickerController!=undefined){
                this.CustomMonthPickerController.open()
              }
            }
          },
          {
            value:THEME_NAMES[3],
            action:()=>{
              DatePickerDialog.show({
                start:new Date('2015-1-1'),
                end:new Date('2100-12-31'),
                selected:this.selected_date,
                onAccept:(value:DatePickerResult)=>{
                  this.newAccount.date=value.year.toString()+'年'
                  +(value.month+1).toString()+'月'
                  +value.day.toString()+'日';
                  this.newAccount.year=value.year.toString();
                  this.newAccount.month=value.month.toString();
                  this.cur_search_text=value.year.toString()+'年'+(value.month+1).toString()+'月'
                  +value.day.toString()+'日';
                  this.AccountTable.query(String(this.newAccount.date),(result:AccountData[])=>{
                    this.accounts=result;
                    this.accountData2ScrollData(this.accounts)
                    this.calculate(this.accounts)
                  },false);
                }
              })
            }
          }
        ])
        Button(){
          Image($rawfile('find.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .position({x:'40%',y: CommonConstants.EDIT_POSITION_Y})
        .onClick(()=>{
          this.searchDialogController.open()
        })
        Button(){
          Image($rawfile('show.png'))
        }
        .width($r('app.float.component_size_MP'))
        .height($r('app.float.component_size_MP'))
        .position({x:'20%',y: CommonConstants.EDIT_POSITION_Y})
        .onClick(()=>{
          router.pushUrl({
            url: 'pages/showPage',
            params:{
              data:this.accounts,
              title:this.cur_search_text
            }
          },router.RouterMode.Standard)
        })
      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#FFE8E7F1')
  }
}