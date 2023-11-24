public class TSE_Bestellbestaetigung_controller {
    public String AccountName { get; set; } public String CustomerNumber { get; set; }
    public Boolean ShowPage { get; set; }
    public TSE_Bestellbestaetigung_controller() {
        ShowPage = false;
        String EncPId = ApexPages.currentPage().getParameters().get('param');
        String PId = '';
        try { PId = PortalToken.decryptPlain(EncPId); } catch(exception e) {}
        try {
            P148Letter__c p = [SELECT Id, CustomerId__c, LegalCompanyName__c FROM P148Letter__c WHERE Id = :PId][0];
	        AccountName = p.LegalCompanyName__c; CustomerNumber = p.CustomerId__c; ShowPage = true;
        } catch(exception e) {}
    }
}