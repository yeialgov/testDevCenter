@isTest public class DeleteDemo_test {

 static testMethod void test() {
 // Define User   
    Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
    User u =new User( Alias = 'newUser1' ,
        Email ='newusersafa@testorg.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', 
        UserName='newusersafa@testorg.com',
        ProfileId=p.Id,
        TimeZoneSidKey    = 'America/Los_Angeles');     
      insert u;  
 
    
// Retrieve permission set    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Delete_Events'];
       
// Assign permission set to the user       
    PermissionSetAssignment psa = new PermissionSetAssignment( 
    AssigneeId = u.Id,
    PermissionSetId = ps.Id);
   //insert psa;
     System.RunAs(u){
  test.startTest();
 Account a = new Account(name='test');
        insert a; 
//Define event    
    Event evt  = new Event(DurationInMinutes=60, OwnerId =u.Id, Subject='test', WhatId = a.Id, ActivityDateTime= Datetime.valueof('2008-12-01 12:00:00'));
    insert evt;
  
    
    try{ delete evt; } catch(exception e){}
    
test.stopTest();
 }}
}