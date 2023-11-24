@isTest public class UpsellCampaign_test {

    static testMethod void test() {
        Contact co = new Contact(lastname='test',email='test@test.com');
        insert co;
        Campaign ca = new Campaign(name='test');
        insert ca;
        CampaignMember cm = new CampaignMember(ContactId=co.Id, CampaignId=ca.Id);
        insert cm;
        apexpages.currentpage().getparameters().put('coId',co.Id);
        apexpages.currentpage().getparameters().put('cmId',cm.Id);
        UpsellCampaign.init();
    }
}