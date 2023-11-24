/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-16-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ParseJson {

    public class removeLicenceJson{
        public String productGeneration;
        public Integer quantity;
        public String billingPeriod;
        public String startDate;
        public String endDate;
        public String status;
        public String subLineItemId;
        public String subLineItemAccount;
        public String subLineItemProduct;
    }

        
    public static List<ParseJson.removeLicenceJson> parseRemovingLicence(String json) {
        return (List<ParseJson.removeLicenceJson>) System.JSON.deserialize(json, List<ParseJson.removeLicenceJson>.class);
    }
}