({
    runInit : function(component, helper) {
        var action0 = component.get("c.getAcctMgmtPerm");
        action0.setCallback(this, function(response0){
            var AcctMgmtPerm = response0.getReturnValue();
            component.set("v.isAcctMgmt", AcctMgmtPerm);
            var action = component.get("c.getCatalog");
            var Opportunity = component.get("v.Opportunity");
            action.setParams({
                "Curr": Opportunity.Account.CurrencyIsoCode,
                "AccountZId": Opportunity.AccountId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("===>>CATALOG<<===");
                    console.log(response.getReturnValue());
                    var Catalog = JSON.parse(response.getReturnValue()).Catalog;
                    for (var x=0; x<Catalog.length; x++) {
                        Catalog[x]["Num"] = 0;
                        if (Catalog[x].Products__r != null) {
                            for (var bb=0; bb<Catalog[x].Products__r.records.length; bb++) {
                                var P = Catalog[x].Products__r.records[bb];
                                var ProdLoc = [];
                                if (P.LocalizedAvailability__c != null) ProdLoc = P.LocalizedAvailability__c.replace(" ","").split(",");
                                Catalog[x].Products__r.records[bb].Display = (
                                    P.IsActive 
                                    && (
                                        P.VisibleToAll__c
                                        || (
                                            P.VisibleToAcctMgmt__c && AcctMgmtPerm
                                        )
                                    )
                                    && (
                                        ProdLoc.includes(Opportunity.Account.BillingCountryCode)
                                        || ProdLoc.length == 0
                                        || (
                                            P.VisibleToAcctMgmt__c && AcctMgmtPerm
                                        )
                                    )
                                    && (
                                        P.Lead_Source_Restriction__c == null
                                        || P.Lead_Source_Restriction__c == Opportunity.DiscountEligible__c
                                    )
                                );
                            }
                        }
                    }
                    component.set("v.Catalog", Catalog);
                    component.set("v.SLIs", JSON.parse(response.getReturnValue()).SLIs);
                    component.set("v.Defaults", JSON.parse(component.get("v.PresetValue")));
                    component.set("v.IsAmendment", JSON.parse(response.getReturnValue()).SLIs.length > 0);
                    /*$A.createComponent("c:QuoteSubtotaler", {
                        "Currency": Opportunity.Account.CurrencyIsoCode,
                        "Opportunity": Opportunity,
                        "isAcctMgmt": AcctMgmtPerm,
                        "IsAmendment": JSON.parse(response.getReturnValue()).SLIs.length > 0
                    }, function(newSubtotaler, status, errorMessage){
                        var body = component.get("v.body");
                        body.push(newSubtotaler);
                        component.set("v.body", body);
                    });*/
                }
                component.set("v.ShowSpinner",false);
            });
            $A.enqueueAction(action);
        });
        $A.enqueueAction(action0);
    }
})