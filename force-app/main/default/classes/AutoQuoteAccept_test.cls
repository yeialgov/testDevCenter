@isTest public class AutoQuoteAccept_test {
    static TestMethod void test() {
        test.startTest();
 		AutoQuoteAccept dbs = new AutoQuoteAccept();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }
    static TestMethod void test2() {
        test.startTest();
 		system.enqueueJob(new EnqueueAQA());
        test.stopTest();
    }
}