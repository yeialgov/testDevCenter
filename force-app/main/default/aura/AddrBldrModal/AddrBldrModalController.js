({
    addAN : function(component) {
        var Blocks = component.get("v.Blocks");
        var Account = component.get("v.Account");
        Blocks.push({"Text": Account.Name, "FieldName":"Name", "FieldLabel": "Account Name"});
        component.set("v.Blocks", Blocks);
        component.set("v.ShowLineAddButtons", false);
    },
    addLCN : function(component) {
        var Blocks = component.get("v.Blocks");
        var Account = component.get("v.Account");
        Blocks.push({"Text": Account.LegalCompanyName__c, "FieldName":"LegalCompanyName__c", "FieldLabel": "Legal Company Name"});
        component.set("v.Blocks", Blocks);
        component.set("v.ShowLineAddButtons", false);
    },
    addCN : function(component) {
        var Blocks = component.get("v.Blocks");
        var Account = component.get("v.Account");
        var Type = component.get("v.Type");
        if (Type == "BILL") {
            Blocks.push({"Text": Account.SF_BillTo_Contact__r.Name, "FieldName":"SF_BillTo_Contact__r.Name", "FieldLabel": "Billing Contact"});
        } else { 
            Blocks.push({"Text": Account.SF_SoldTo_Contact__r.Name, "FieldName":"SF_SoldTo_Contact__r.Name", "FieldLabel": "Shipping Contact"});
        }
        component.set("v.Blocks", Blocks);
        component.set("v.ShowLineAddButtons", false);
    },
    addET : function(component) {
        var Blocks = component.get("v.Blocks");
        var Account = component.get("v.Account");
        Blocks.push({"Text": "","FieldName": null, "FieldLabel": null});
        component.set("v.Blocks", Blocks);
        component.set("v.ShowLineAddButtons", false);
    },
    addBlock : function(component, event){
        alert(event.getSource().get("v.class"));
    },
    deleteBlock : function(component, event){
        var Index = event.getSource().get("v.class").split(" ")[0];
        var Blocks = component.get("v.Blocks");
        Blocks.splice(Number(Index), 1);
        component.set("v.Blocks", Blocks);
    },
    shiftUp : function(component, event){
        var Index = event.getSource().get("v.class");
        var Blocks = component.get("v.Blocks");
        Blocks.splice(Number(Index)-1, 0, Blocks.splice(Number(Index), 1)[0]);
        component.set("v.Blocks", Blocks);
    },
    shiftDown : function(component, event){
        var Index = event.getSource().get("v.class");
        var Blocks = component.get("v.Blocks");
        Blocks.splice(Number(Index), 0, Blocks.splice(Number(Index)+1, 1)[0]);
        component.set("v.Blocks", Blocks);
    },
    ShowLineAdder : function(component) {
        component.set("v.ShowLineAddButtons", !component.get("v.ShowLineAddButtons"));
    },
    Save : function(component) {
        component.set("v.ShowSpinner", true);
        component.find("recordViewForm").submit();
    },
    HasError : function(component) {
        component.set("v.ShowSpinner", false);
    },
    Submitted : function(component) {
        var Account = component.get("v.Account");
        var action = component.get("c.SyncAddress");
        var AddressBuilder = [];
        var Blocks = component.get("v.Blocks");
        for (var x=0; x<Blocks.length; x++) {
            AddressBuilder.push(Blocks[x].FieldName);
        }
        action.setParams({ 
            "AccountId": Account.Id, 
            "AddressBuilder": JSON.stringify(AddressBuilder),
            "Type": component.get("v.Type")
        });
        action.setCallback(this, function(response){
        	component.set("v.ShowSpinner", false);
            var appEvent = $A.get("e.c:AddressBuilderChange");
            appEvent.fire();
            component.set("v.ShowModal", false);
        });
        $A.enqueueAction(action);
    },
    Cancel : function(component) {
        component.set("v.ShowModal", false);
    },
    doInit : function(component) {
        var Account = component.get("v.Account");
        var BuilderStr = Account.AddressBuilder__c;
        if (component.get("v.Type") == "SHIP") {
            BuilderStr = Account.AddressBuilder_Shipping__c;
        }
        var MetadataFields = [
            "Name", "LegalCompanyName__c", "SF_BillTo_Contact__r.Name", "SF_SoldTo_Contact__r.Name"
        ];
        var MetadataLabels = [
            "Account Name", "Legal Company Name","Billing Contact", "Shipping Contact"
        ];
        var Builder;
        try { Builder = JSON.parse(BuilderStr); } catch(err) {}
        var Blocks = [];
        if (Builder != null) {
            for (var x=0; x<3; x++) {
                if (Builder[x] != null && Builder[x] != "empty") {
                    if (MetadataFields.indexOf(Builder[x]) > -1) {
                        var FieldParts = Builder[x].split(".");
                        var Text = Account[FieldParts[0]];
                        if (FieldParts.length == 2) Text = Account[FieldParts[0]][FieldParts[1]];
                        Blocks.push({
                            "Text": Text,
                            "FieldName": Builder[x],
                            "FieldLabel": MetadataLabels[MetadataFields.indexOf(Builder[x])]
                        });
                    } else {
                        Blocks.push({
                            "Text": null,
                            "FieldName": Builder[x],
                            "FieldLabel": null
                        });
                    }
                }
            }
        }
        component.set("v.Blocks", Blocks);
    }
})