@isTest public class ContactMerge_test {

    static TestMethod void test() {
        Contact c1 = new Contact(lastname = 'test');
        insert c1;
        Contact c2 = new Contact(lastname = 'test', merge_into__c = c1.id);
        insert c2;
        database.executebatch(new contactmerge());
    }
}