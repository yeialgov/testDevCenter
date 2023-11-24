@isTest
public class SalesConsoleControllerTest {

    @isTest static void test1() {
        Lead la = new Lead(lastname='test', company='test');
        insert la;
        Lead lb = new Lead(lastname='test2', company='test2');
        insert lb;
        String s = SalesConsoleController.getConsoleItems();
    }
}