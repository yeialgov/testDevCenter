@isTest public class PortalToken_test {

    static TestMethod void test() {
        String et = PortalToken.encryptToken('123');
        String ep = PortalToken.encryptPlain('123');
        PortalToken.decryptPlain(ep);
        //PortalToken.refreshToken(et);
    }
}