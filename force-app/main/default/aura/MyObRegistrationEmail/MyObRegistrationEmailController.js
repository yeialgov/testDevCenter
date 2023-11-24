({
    doInit : function(component, event, helper) {
        if (!component.get("v.HasRun")) {
            component.set("v.HasRun", true);
            var Contact = component.get("v.Contact");
            var ErrorMessages = [];
            
            if (Contact.Email == null) ErrorMessages.push("Contact must have an Email.");
            if (Contact.NameIssue__c) ErrorMessages.push("Contact must have a real First and Last Name.");
            //if (Contact.PrimaryLanguage__c != 'German' && Contact.PrimaryLanguage__c != 'English' && Contact.PrimaryLanguage__c != 'French') {
            //    ErrorMessages.push("Contact must have a primary language of German, English, or French.");
            //}
            
            if (ErrorMessages.length > 0) {
                component.set("v.ErrorMessages", ErrorMessages);
                component.set("v.ShowSpinner", false);
            } else {
                var redirectId = component.get("v.redirectId");
                if (redirectId == null) redirectId = Contact.AccountId;
                var action = component.get("c.sendMyObRegistrationEmail");
                action.setParams({"ContactId": Contact.Id, "Language": Contact.Account.PrimaryLanguage__c});
                action.setCallback(this, function(response){
                    var evt = $A.get("e.force:navigateToSObject");
                    evt.setParams({recordId: redirectId});
                    evt.fire();
                });
                $A.enqueueAction(action);
            }
        }
    }
})