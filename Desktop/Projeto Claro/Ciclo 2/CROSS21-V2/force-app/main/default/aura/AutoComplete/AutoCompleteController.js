({
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
//        if (searchString.length >= 0) {
            //Ensure that not many function execution happens if user keeps typing

            //Exibir a lista apenas quando não tiver caracteres ou quando tiver pelo menos 3 digitados
            //TODO Gabriel e Jose - Se ficar muito estranho dessa forma, tirar esse if
            if(!searchString || searchString.trim().length === 0 || searchString.trim().length >= 3) {
                if (component.get("v.inputSearchFunction")) {
                    clearTimeout(component.get("v.inputSearchFunction"));
                }
    
                const inputTimer = setTimeout($A.getCallback(function () {
                    helper.searchRecords(component, searchString);
                }), 500);
                component.set("v.inputSearchFunction", inputTimer);
            }
            

 /*       } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }*/
    },

    optionClickHandler : function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);  
        
        console.log("Teste: "+selectedId);
        let getEvent = component.getEvent("getSelectItem");
        getEvent.setParams({ "selectedItem": selectedId });
        getEvent.fire();
    },

    clearOption : function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    },
})