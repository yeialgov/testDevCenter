@isTest public class CaseBusinessHours_Test {
    
    static testMethod void test() {
        insert new Case();
        Database.executeBatch(new CaseBusinessHours());
    }
}