@isTest
public class TestPortalUser {

    static testmethod void test1() {
        user u = [select id from user where ProfileId ='00e5J000000tWC6QAM'];
system.debug('u '+u);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        system.debug(' devRecordTypeId '+devRecordTypeId);

system.runAs(u){
    account a = new account();
    a.name = 'test';
    a.RecordTypeId = devRecordTypeId;
    insert a;
    system.debug('a'+a.id+' '+a.OwnerId);
    
    List<UserRecordAccess> lstUserRecordAccess = [SELECT RecordId,MaxAccessLevel,HasAllAccess, 
                                                     HasDeleteAccess, 
                                                     HasEditAccess,
                                                     HasReadAccess, 
                                                     HasTransferAccess 
                                                FROM UserRecordAccess 
                                                WHERE UserId =: u.id 
                                                 AND RecordId =: a.id];
    system.debug('lstUserRecordAccess '+lstUserRecordAccess);
    
    opportunity op = new opportunity();
    op.name = 'test opp';
    op.AccountId = a.Id;
    insert op;
    system.debug('op '+op);
    
}
    }
}