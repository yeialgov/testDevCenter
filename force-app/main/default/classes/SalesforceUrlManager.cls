public class SalesforceUrlManager {
	public static String getSalesforceInstanceUrl() {
		List<SFUrls__c> urls = [SELECT BaseUrl__c FROM SFUrls__c WHERE Name='Salesforce' LIMIT 1];
		return SalesforceUrlManager.getBaseUrl(urls);
    }

    @TestVisible
    private static String getBaseUrl(List<SFUrls__c> urls) {
    	if (urls.isEmpty()) return null;
		SFUrls__c url = urls[0];
        return url.BaseUrl__c;
    }
}