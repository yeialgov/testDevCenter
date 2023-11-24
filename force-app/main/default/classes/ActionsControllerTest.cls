@isTest
public class ActionsControllerTest {

    @isTest static void Test1() {
        Account a = new Account(name='test');
        insert a;
        ActionsController.createNewOpportunity(a.Id, 'AccountName');
        Lead l = new Lead(lastname='test',Company='test');
        insert l;
        ActionsController.quickConvertLead(l.Id);
    }
}