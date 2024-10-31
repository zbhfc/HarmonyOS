class BasicDataSource implements IDataSource{
  private listeners:DataChangeListener[]=[]

  public totalCount():number{
    return 0
  }
  public getData(number):undefined|Object{
    return undefined
  }

}