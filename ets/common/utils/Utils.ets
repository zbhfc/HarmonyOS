const YEAR:string='年';
const Month:string='月';
const Day:string='日';

export function padTo2Digits(num:number){
  return num.toString().padStart(2,'0');
}
export function  dateTostr(date:Date){
  return date.toDateString();
}
export function dateFormat(date:Date){
  return date.getFullYear()+YEAR+padTo2Digits(date.getMonth()-1)+Month+padTo2Digits(date.getDate())+Day;
}

export function DateFormat(timestamp:number){
  let tempDate=new Date(timestamp);
  return dateFormat(tempDate);
}