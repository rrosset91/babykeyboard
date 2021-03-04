({
    getArticle: function(component) {
        let recordId = component.get('v.recordId');
        //action to server
        let action = component.get('c.checkUserPermission');
        action.setParams({ recordId: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (data !== null && data !== '') {
                    this.showToast('Erro', data, 'error');
                    $A.get("e.force:closeQuickAction").fire();
                    console.log(data);
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    this.showToast('Erro', data, 'error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    publish: function(component) {
        component.set('v.isLoading', true);
        let scheduledDate = component.find('scheduleDate').get('v.value');
        let newVersion = component.find('newVersion').get('v.checked');
        let onRadioSelect = component.get('v.value');
        let recordId = component.get('v.recordId');
        let scheduleRevisionDate = component.find('scheduleRevisionDate').get('v.value');
        //action to server
        let action = component.get('c.publishArticle');
        action.setParams({
            recordId: recordId,
            scheduledDate: scheduledDate,
            publishOption: onRadioSelect,
            isNewVersion: newVersion,
            scheduledRevisionDate: scheduleRevisionDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (data) {
                    this.showToast('Sucesso', data, 'success');
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    this.showToast('Sucesso', data, 'success');
                    $A.get("e.force:closeQuickAction").fire();
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    this.showToast('Erro', errors[0].message, 'error');
                }
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    setRevisionDueDate: function(component) {
        let today = new Date();
        let todayPlus6Months = new Date(today.setDate(today.getDate() + 180));
        let day = (todayPlus6Months.getUTCDate() < 10) ? '0' + todayPlus6Months.getUTCDate() : todayPlus6Months.getUTCDate();
        let month = todayPlus6Months.getMonth() + 1;
        let year = todayPlus6Months.getFullYear();
        let fullDate = year + '-' + month + '-' + day;
        console.log('fullDate: ' + fullDate);
        component.find('scheduleRevisionDate').set('v.value', fullDate);
    },
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})