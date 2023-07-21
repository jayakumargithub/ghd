({
	checkCase : function(component) {
		let action = component.get('c.loadCase');
        action.setParam('caseId', component.get('v.recordId'));
		action.setCallback(this, function(response) {
            let state = response.getState();
            if (component !== undefined && component.isValid() && state === 'SUCCESS') {
                let loadedCase = response.getReturnValue();
                component.set('v.hasCode', loadedCase.RoyalMail1DTrackingNumber__c != null);
                component.set('v.loaded', true);
            }
        });
        $A.enqueueAction(action);
	}
})