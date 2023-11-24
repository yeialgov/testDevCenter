({
    lookupSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.search');
        component.find('lookup').search(serverSearchAction);
    },
    NewCaseSolution : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "CaseSolution__c",
            "defaultFieldValues": {
                'Creator__c' : component.get("v.recordId")
            }
        });
        createRecordEvent.fire();
    },
    addCSJ : function(component, event, helper) {
        var action = component.get("c.newCaseSolution");
        var selection = component.get("v.selection");
        var CSId = selection[selection.length-1].id;
        action.setParams({
            "CaseId": component.get("v.recordId"),
            "CaseSolutionId": CSId,
            "UpdateSubject": selection.length === 1
        });
        action.setCallback(this, function(response){
            if (selection.length === 1) {
                //window.location.reload()
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    delCSJ : function(component, event, helper) {
        var action = component.get("c.delCaseSolution");
        var selection = component.get("v.selection");
        var CSIds = [];
        for (var x in selection) {
            CSIds.push(selection[x].id);
        }
        action.setParams({
            "CaseId": component.get("v.recordId"),
            "CaseSolutionIds": JSON.stringify(CSIds)
        });
        $A.enqueueAction(action);
    },
    doInit : function(component, event, helper) {
        var action = component.get("c.getCaseSolutions");
        action.setParams({"CaseId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var CSJs = JSON.parse(action.getReturnValue());
            var items = [];
            for (var x in CSJs) {
                var item = {
                    "engName": CSJs[x].CaseSolution__r.Name,
                    "id": CSJs[x].CaseSolution__r.Id,
                    "icon": "custom:custom94"
                };
                items.push(item);
            }
            component.set("v.selection", items);
        });
        $A.enqueueAction(action);
    }
})