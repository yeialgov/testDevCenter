@isTest
public class queryToolController_test {

    static testMethod void test() {
        insert new Account(name='test1');
        insert new Account(name='test2');
        queryToolController qtc = new queryToolController();
        qtc.queryString = 'SELECT COUNT(Id) cnt FROM Account';
        qtc.executeQuery();
        system.assertEquals(2,(Integer)((Map<String,Object>)((List<Object>)JSON.deserializeUntyped(qtc.jsonStr))[0]).get('cnt'));
    }
}