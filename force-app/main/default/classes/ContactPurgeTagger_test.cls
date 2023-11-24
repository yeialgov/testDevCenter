@isTest public class ContactPurgeTagger_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Test.setCreatedDate(a.id, Datetime.now().addYears(-2));
        insert new Contact( AccountId = a.Id, LastName = 'test' );
        ContactPurgeTagger b = new ContactPurgeTagger(); 
        database.executebatch(b);
        system.schedule('Test', '0 0 23 * * ?', new ContactPurgeTagger_scheduler());
    }
}