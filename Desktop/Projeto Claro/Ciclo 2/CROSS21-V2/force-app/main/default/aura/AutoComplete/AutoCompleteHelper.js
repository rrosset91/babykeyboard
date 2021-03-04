//const { resolveConfig } = require("prettier");

({
    searchRecords : function(component, searchString) {

        const reasons = component.get("v.listReason");
        if(reasons) {
            const valueFieldApiName = component.get("v.valueFieldApiName");
            let filtered = reasons;
            if(searchString && searchString.trim().length > 0) {
                filtered = reasons.filter(reason => reason[valueFieldApiName] && reason[valueFieldApiName].toUpperCase().includes(searchString.toUpperCase().trim()));
            }
            if(filtered) {
                const idFieldApiName = component.get("v.idFieldApiName");
                const finalResult = filtered.map(reason => {
                    const newValue = {id : reason[idFieldApiName], value : reason[valueFieldApiName]};
                    return newValue;
                });
                component.set("v.results", finalResult);
                if(finalResult && finalResult.length > 0) {
                    component.set("v.openDropDown", true);
                }
            }
        }
    }
})