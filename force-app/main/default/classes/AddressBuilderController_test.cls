@isTest public class AddressBuilderController_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        AddressBuilderController.SyncAddress(a.Id, 'test', null);
        AddressBuilderController.SyncAddress(a.Id, 'test', 'SHIP');
        AddressBuilderController.SyncAddress(a.Id, 'test', 'BILL');
        AddressBuilderController.SyncAddress(a.Id, 'test', 'ALL');
        AddressBuilderController.ChangeSyncType(a.Id, 'BILL-VENUE', 'BILL', '["VENUE"]');
    }
}