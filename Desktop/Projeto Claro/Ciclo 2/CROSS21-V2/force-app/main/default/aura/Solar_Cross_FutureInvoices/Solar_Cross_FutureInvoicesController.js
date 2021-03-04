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
        let allReleases = component.get('v.futureReleases');
        
        if(!allReleases)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        /*switch(fieldName){
            case ""
        }*/

        component.set('v.futureReleases', helper.sortData(fieldName,sortDirection,allReleases));
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
})