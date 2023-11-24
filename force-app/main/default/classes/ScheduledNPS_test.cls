@isTest
public class ScheduledNPS_test {
    static TestMethod void test() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new ScheduledNPS());
    }
}