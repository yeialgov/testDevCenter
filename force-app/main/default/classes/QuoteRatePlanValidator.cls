/**
 * @author keylight
 */
public with sharing class QuoteRatePlanValidator {/*
	@TestVisible private List<zqu__QuoteRatePlanCharge__c> ratePlanCharges;
	private Map<ID, Integer> baseMonths;
	private Map<ID, Integer> addOnMonths;
	private Set<ID> quoteIds;

	public QuoteRatePlanValidator(List<zqu__QuoteRatePlanCharge__c> ratePlanCharges) {
		this.ratePlanCharges = ratePlanCharges;
		this.quoteIds = this.findQuoteIds();
		this.calculateTermMonths();
	}

	public void validateQuotes() {
		for (ID quoteId : this.quoteIds) {
			if (this.baseMonths.containsKey(quoteId) && this.addOnMonths.containsKey(quoteId) && this.baseMonths.get(quoteId) != this.addOnMonths.get(quoteId) && this.addOnMonths.get(quoteId) > 1) {
				for (zqu__QuoteRatePlanCharge__c charge : ratePlanCharges) {
					charge.addError('Your POS Device license term does not match your POS Base license selection. Please try again!');	
				}
			}
		}
	}

	public Map<ID, Integer> getQuoteTermMonths() {
		return this.baseMonths;
	}

	@TestVisible private Set<ID> findQuoteIds() {
		Set<ID> ratePlanIds = new Set<ID>();
		for (zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : this.ratePlanCharges) {
			ratePlanIds.add(quoteRatePlanCharge.zqu__QuoteRatePlan__c);
		}
		Set<ID> quoteIds = new Set<ID>();
		List<zqu__QuoteRatePlan__c> tempQuoteRatePlans = [SELECT zqu__Quote__c FROM zqu__QuoteRatePlan__c WHERE Id IN :ratePlanIds];
		for (zqu__QuoteRatePlan__c tempQuoteRatePlan : tempQuoteRatePlans) {	
			quoteIds.add(tempQuoteRatePlan.zqu__Quote__c);
		}
		return quoteIds;
	}

	private void calculateTermMonths() {
		List<zqu__QuoteRatePlanCharge__c> baseCharges = [SELECT Id, zqu__Period__c, zqu__SpecificBillingPeriod__c, zqu__QuoteRatePlan__r.zqu__Quote__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :this.quoteIds AND zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.RatePlanType__c = 'POS Base License'];
		List<zqu__QuoteRatePlanCharge__c> addOnCharges = [SELECT Id, zqu__Period__c, zqu__SpecificBillingPeriod__c, zqu__QuoteRatePlan__r.zqu__Quote__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :this.quoteIds AND zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.RatePlanType__c = 'POS Add-on License'];
		this.baseMonths = new Map<ID,Integer>();
		this.addOnMonths = new Map<ID,Integer>();
		this.setMonths(this.baseMonths, baseCharges);
		this.setMonths(this.addOnMonths, addOnCharges);
	}

	private void setMonths(Map<ID, Integer> monthType, List<zqu__QuoteRatePlanCharge__c> charges) {
		for (zqu__QuoteRatePlanCharge__c charge: charges) {
			String quoteId = charge.zqu__QuoteRatePlan__r.zqu__Quote__c;
			if (!monthType.containsKey(quoteId)) {
				monthType.put(quoteId, 0);
			}
			Integer month = 0;
			if (charge.zqu__Period__c == 'Month') {
				month = 1;
			} else if (charge.zqu__Period__c == 'Annual') {
				month = 12;
			} else if (charge.zqu__SpecificBillingPeriod__c != null) {
				month = Integer.valueOf(charge.zqu__SpecificBillingPeriod__c);
			}
			monthType.put(quoteId, Math.max(month, monthType.get(quoteId)));
		}
	}*/
}