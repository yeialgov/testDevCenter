@isTest
public class SalesforceUrlManagerTest {
	@isTest static void runs_get_salesforce_instance_url() {
		SalesforceUrlManager.getSalesforceInstanceUrl();
	}

	@isTest static void should_return_null() {
		List<SFUrls__c> urls = new List<SFUrls__c>();
		String result = SalesforceUrlManager.getBaseUrl(urls);
		System.assertEquals(null, result);
	}

	@isTest static void should_return_base_url() {
		String baseUrl = 'salesforce.com';
		SFUrls__c url = new SFUrls__c(BaseUrl__c = baseUrl);
		List<SFUrls__c> urls = new List<SFUrls__c>();
		urls.add(url);
		String result = SalesforceUrlManager.getBaseUrl(urls);
		System.assertEquals(baseUrl, result);
	}
}