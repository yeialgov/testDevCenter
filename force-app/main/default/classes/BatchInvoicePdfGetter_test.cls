@isTest(seeAllData=true) public class BatchInvoicePdfGetter_test {

    static TestMethod void test() {
        database.executeBatch(new BatchInvoicePdfGetter());
    }
}