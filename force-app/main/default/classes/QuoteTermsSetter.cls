/**
 * @author keylight
 */
public with sharing class QuoteTermsSetter {/*
	@TestVisible private Map<ID, Integer> quoteTermMonths;
	private List<zqu__Quote__c> quotes;

	public QuoteTermsSetter(Map<ID, Integer> quoteTermMonths) {
		this.quoteTermMonths = quoteTermMonths;
		this.quotes = [SELECT Id FROM zqu__Quote__c WHERE Id IN :quoteTermMonths.keySet()];
	}

	public List<zqu__Quote__c> updateQuoteTerms() {		
		for (zqu__Quote__c quote : this.quotes) {
			Integer months = this.quoteTermMonths.get(quote.Id);
			if (months <= 1 ) {
				quote.zqu__Subscription_Term_Type__c = 'Evergreen';
			} else {
				quote.zqu__Subscription_Term_Type__c = 'Termed';
				quote.zqu__InitialTerm__c = months;
				quote.zqu__RenewalTerm__c = months;
				quote.zqu__AutoRenew__c = true;
			}
		}
		return this.quotes;
	}*/
}