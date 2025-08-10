export class Account {
  static PasswordHash(PasswordHash: any) {
      throw new Error('Method not implemented.');
  }
  UserId : number ;
  Username : string ;
  Email : string ;
  PasswordHash : string ;
  CreatedAt? : Date ;
  UserImg : string ;
  LastLogin? : Date ;
  UsedCapacity : number ;
  Capacity : number ;   

}
