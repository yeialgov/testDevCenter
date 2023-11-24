({
    doInit : function(component, event, helper) {
        var Account = component.get("v.Account");
        try{
            component.set("v.countryIcon", Account.BillingCountry.toLowerCase().replace(" ","-"));
        }catch(err){}
        try{
            var primaryLanguage = Account.PrimaryLanguage__c;
            if (primaryLanguage == "English") {
                component.set("v.languageIcon","english");
            } else if (primaryLanguage == "French") {
                component.set("v.languageIcon","french");
            } else {
                component.set("v.languageIcon","german");
            }
            component.set("v.languageIcon", Account.PrimaryLanguage__c.toLowerCase().replace(" ","-"));
        }catch(err){}
        var Cockpit = {};
        var Lines = [];
        try{
            if (Account.Product_Test_Participation__c != null) {
                component.set("v.TestParticipants", Account.Product_Test_Participation__c.split(";"));
            }
            Cockpit["Name"] = Account.Name.toLowerCase();
            switch(Account.Account_Status__c) {
                case 'Active Customer':
                    Cockpit["StatusIcon"] = "utility:check";
                    Cockpit["StatusExtra"] = "bgColorGreen";
                    break;
                case 'Lost Customer':
                    Cockpit["StatusIcon"] = "utility:close";
                    Cockpit["StatusExtra"] = "bgColorRed";
                    break;
                case 'Paused Customer':
                    Cockpit["StatusIcon"] = "utility:pause";
                    Cockpit["StatusExtra"] = "bgColorLtGreen";
                    break;
                case 'Future Customer':
                    Cockpit["StatusIcon"] = "utility:clock";
                    Cockpit["StatusExtra"] = "bgColorLtGreen";
                    break;
                case 'Hardware Customer':
                    Cockpit["StatusIcon"] = "utility:desktop";
                    Cockpit["StatusExtra"] = "bgColorOrange";
                    break;
                case 'Incomplete Customer':
                    Cockpit["StatusIcon"] = "utility:info_alt";
                    Cockpit["StatusExtra"] = "bgColorYellow";
                    break;
                case 'Lost Hardware Customer':
                    Cockpit["StatusIcon"] = "utility:close";
                    Cockpit["StatusExtra"] = "bgColorRed";
                    break;
                case 'Prospect (Closed Lost)':
                    Cockpit["StatusIcon"] = "utility:close";
                    Cockpit["StatusExtra"] = "bgColorRed";
                    break;
                case 'Legacy NetSuite Customer':
                    Cockpit["StatusIcon"] = "utility:database";
                    Cockpit["StatusExtra"] = "bgColorGray";
                    break;
                case 'Partner':
                    Cockpit["StatusIcon"] = "utility:crossfilter";
                    Cockpit["StatusExtra"] = "bgColorBlack";
                    break;
                case 'Product Test Only':
                    Cockpit["StatusIcon"] = "utility:spinner";
                    Cockpit["StatusExtra"] = "bgColorOrange";
                    break;
                default:
                    Cockpit["StatusIcon"] = "utility:add";
                    Cockpit["StatusExtra"] = "bgColorPurple";
                    break;
            }
            Cockpit["Lines"] = Lines;
            component.set("v.Cockpit", Cockpit);
        } catch(err) {}
    },
    HealthClick : function(component, event, helper) {
        component.set("v.closeModalOpen", !component.get("v.closeModalOpen"));
    },
    reloadRL3 : function(component, event, helper) {
        component.find('recordLoader3').reloadRecord(true) 
    },
    CopyCustomerNo : function(component) {
        var CustomerNo = component.get("v.Account").CustomerID__c;
        // Create new element
        var el = document.createElement('textarea');
        // Set value (string to be copied)
        el.value = CustomerNo;
        // Set non-editable to avoid focus and move outside of view
        el.setAttribute('readonly', '');
        el.style = {position: 'absolute', left: '-9999px'};
        document.body.appendChild(el);
        // Select text inside element
        el.select();
        // Copy text to clipboard
        document.execCommand('copy');
        // Remove temporary element
        document.body.removeChild(el);
        alert('Copied Customer Number: ' + CustomerNo);
    }
})