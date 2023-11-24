({
	doInit : function(component, event, helper) {
        var Case = component.get("v.Case");
        var CalendlyURL = "https://calendly.com/";
        CalendlyURL += Case.Owner.FirstName;
        CalendlyURL += "_orderbird?sfid=";
        CalendlyURL += Case.Id;
        CalendlyURL += "&name=";
        CalendlyURL += Case.Contact.FirstName;
        CalendlyURL += "%20";
        CalendlyURL += Case.Contact.LastName;
        CalendlyURL += "&email=";
        CalendlyURL += Case.Contact.Email;
        CalendlyURL += "&a1=";
        CalendlyURL += encodeURI(Case.Contact.Phone);
        CalendlyURL += "&a2=";
        CalendlyURL += Case.Account.CustomerID__c;
        CalendlyURL += "%20";
        CalendlyURL += encodeURI(Case.Account.Name);
		window.open(CalendlyURL, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top=0, left=0, width=901, height=700");;
	}
})