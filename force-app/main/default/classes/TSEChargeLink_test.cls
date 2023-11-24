@isTest public class TSEChargeLink_test {

    static TestMethod void test() {
        test.startTest();
 		TSEChargeLink dbs = new TSEChargeLink();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }
}