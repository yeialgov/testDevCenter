({
    doInit : function(component, event, helper) {
        var action = component.get("c.searchResults");
        var searchstring = component.get("v.inputsearch");
        if (searchstring == "") { searchstring = component.get("v.search"); component.set("v.inputsearch", component.get("v.search")); }
        action.setParams({'searchString':searchstring});
        action.setCallback(this, function(response){
            try{
                var results = JSON.parse(action.getReturnValue())[0];
                for (var x=0; x<results.length; x++) {
                    if (results[x].Account_Status__c.indexOf('Prospect') != -1) results[x].Account_Status__c = 'Prospect';
                    results[x].Name = results[x].Name.toUpperCase();
                }
                component.set("v.SearchResults", results);
            }catch(err){}
        });
        $A.enqueueAction(action);
    }
})