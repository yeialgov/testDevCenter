({
	changeAmt : function(component, event, helper) {
		var Amt = component.get("v.Amt");
        var SLI = component.get("v.SLI");
        var SubValue = 1;
        if (SLI.Product__r.Type__c == 'OneTime') SubValue = SLI.Quantity__c;
        Amt -= SubValue;
        if (Amt < 0) Amt = SLI.Quantity__c;
        component.set("v.Amt", Amt);
        var appEvent = $A.get("e.c:NewQuoteItem");
        var prod = {};
        prod.Id = SLI.Id;
        prod.Name = SLI.Product__r.Name;
        prod.ProdId = SLI.Product__c;
        prod.ZuoraId__c = SLI.Product__r.ZuoraId__c;
        prod.Num = -Amt;
        if (prod.Num == 0) prod.Num = null;
        appEvent.setParams({"message":JSON.stringify(prod)});
        appEvent.fire();
	}
})