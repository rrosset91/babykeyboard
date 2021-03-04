({
    doInit: function(component, event, helper) {
        helper.getArticle(component);
        helper.setRevisionDueDate(component);
    },

    onRadioSelect: function(component, event, helper) {
        let radioSelect = component.get('v.value');
        console.log('radioSelect: ' + radioSelect);
        if (radioSelect == 'later') {
            component.set('v.disabledDateField', false);
            component.set('v.disabledCheckbox', true);
            component.find('newVersion').set('v.checked', false);
        } else {
            component.set('v.disabledDateField', true);
            component.set('v.disabledCheckbox', false);
            component.find('newVersion').set('v.checked', true);
        }
    },

    onPublish: function(component, event, helper) {
		helper.publish(component);
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})