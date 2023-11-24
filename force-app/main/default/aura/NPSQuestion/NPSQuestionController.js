({
    SelectNPS : function(component, event, helper) {
		component.set("v.NPSChoice", parseInt(event.currentTarget.dataset.value, 10));
	}
})