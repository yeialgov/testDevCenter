@isTest public class CockpitController_Test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        insert new Contact(AccountId=a.Id, Email='test@test.com', Lastname='test');
        system.debug(CockpitController.getActiveDevices(a.Id));
        system.debug(CockpitController.getMRR(a.Id));
        system.debug(CockpitController.getNPS(a.Id));
    }
}