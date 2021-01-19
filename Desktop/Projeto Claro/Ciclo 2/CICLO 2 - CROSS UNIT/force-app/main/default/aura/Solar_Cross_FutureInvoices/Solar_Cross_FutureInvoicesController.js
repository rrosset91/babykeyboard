({
	doInit : function(component, event, helper) {
        helper.initialLoad(component);        
	},
	onSort : function(component,event,helper){
		console.log('aaabb');
        let fieldName = event.getParam("fieldName");
        let sectionName = event.getParam("title");
        console.log('teste:: ', sectionName)
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedBy",fieldName);
        component.set("v.sortedDirection",sortDirection);
        console.log('sortedDirection',sortDirection);

        let allReleases;
        let showModal = component.get('v.showModal');
        allReleases = showModal == true ? component.get('v.hundredFutureReleases') : component.get('v.futureReleases');

        
        if(!allReleases)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        /*switch(fieldName){
            case ""
        }*/
        if(showModal){
            component.set('v.hundredFutureReleases', helper.sortData(fieldName,sortDirection,allReleases));
        }else{
            component.set('v.futureReleases', helper.sortData(fieldName,sortDirection,allReleases));
        }
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    handleOnNext : function(component,event,helper){
        console.log('handleOnNext');
        helper.onNext(component,event,helper);
    },
    handleOnPrevious : function(component,event,helper){
        console.log('handleOnNext');
        helper.onPrevious(component,event,helper);
    },

    openModal : function(component,event,helper){
        component.set('v.showModal',true);
    },
    handleCloseModal : function(component,event,helper){
        component.set('v.showModal',false);
    }
})