({
	init : function(component, event, helper) {
        helper.checkCase(component);
	},
	assignToCase : function(component, event, helper) {
        component.set('v.loaded', false);
		let action = component.get('c.assignCodeToCase');
        action.setParam('caseId', component.get('v.recordId'));
		action.setCallback(this, function(response) {
            let state = response.getState();
            if (component !== undefined && component.isValid() && state === 'SUCCESS') {
                helper.checkCase(component);
            }
        });
        $A.enqueueAction(action);
	},
})