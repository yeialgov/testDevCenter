@isTest(seeAllData=true) public class DoubleOptIn_test {

    static TestMethod void test() {
        insert new Lead(lastname='test',company='test',lac_id__c='110',salutation='Herr',phone='+4915144445555',email='test@test.com',city='test',country='germany',street='test',postalcode='12345');
        insert new Contact(lastname='test',email='test@test.com');
        DoubleOptIn.init();
    }
}