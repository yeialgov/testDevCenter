@isTest
public class CaseHandlerTest {
    
    @isTest static void test1() {
        Id rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name = 'Case: Onboarding' LIMIT 1].Id;
        Case c = new Case(RecordTypeId = rt);
        insert c;
        c.Assign_Me__c = true;
        update c;
        c.Delete__c = true;
        update c;
    }
}