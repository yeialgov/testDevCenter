({
    Click : function(component, event, helper) {
        var Account = component.get("v.Account");
        var Winner = component.get("v.Winner");
        var SyncType = component.get("v.Sync");
        var Confirmed = true;
        var Losers = [];
        if (Winner != null) {
            if (SyncType == "ALL") {
                var Current = Account.AddressSyncType__c.split("-");
                if (Current.indexOf(Winner) == -1) {
                    Losers = Current;
                } else {
                    switch (Account.AddressSyncType__c) {
                        case "BILL-SHIP": Losers = ["VENUE"]; break;
                        case "BILL-VENUE": Losers = ["SHIP"]; break;
                        case "SHIP-VENUE": Losers = ["BILL"]; break;                            
                    }
                }
            } else {
                var SyncTypes = SyncType.split("-");
                if (SyncTypes[0] == Winner) {
                    Losers.push(SyncTypes[1]);
                } else {
                    Losers.push(SyncTypes[0]);
                }
            }
            var LoserMap = {"BILL":"Billing", "SHIP":"Shipping", "VENUE":"Venue"};
            var LoserString = LoserMap[Losers[0]];
            if (Losers.length == 2) {
                LoserString += " and " + LoserMap[Losers[1]];
            }
            Confirmed = confirm("This will permanently replace the " + LoserString + " Address data.")
        }
        if (Confirmed) {
            var action = component.get("c.ChangeSyncType");
            action.setParams({
                "AccountId": Account.Id,
                "SyncType": SyncType,
                "Winner": Winner,
                "Losers": JSON.stringify(Losers)
            });
            action.setCallback(this, function(response){
                var appEvent = $A.get("e.c:AddressBuilderChange");
                appEvent.fire();
            });
            $A.enqueueAction(action);
        }
    }
})