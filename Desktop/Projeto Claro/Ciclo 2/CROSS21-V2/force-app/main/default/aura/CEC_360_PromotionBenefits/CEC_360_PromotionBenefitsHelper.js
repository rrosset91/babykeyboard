({
    loadPromotionsBenefits : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getPromotionBenefits");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            promotionIdNGP : component.get("v.promotionIdNGP"),
            promotionVersionNGP : component.get("v.promotionVersionNGP"),
            sequentialIdNGP : component.get("v.sequentialIdNGP")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retorno;
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                retorno = response.getReturnValue();
                if(retorno != null){
                    if(retorno.data != null) {
                        component.set("v.showTable", true);
                        component.set("v.totalPages", Math.ceil(retorno.data.promotion.benefitsReceived.length/component.get("v.pageSize")));
                        component.set("v.allDataBenefits", retorno.data.promotion.benefitsReceived);
                        component.set("v.currentPageNumber", 1);
                        helper.buildData(component, helper);
                    } else {
                        component.set("v.showTable", false);
                        component.set("v.visible", true);
                        component.set("v.message",'Não há benefícios para a promoção');
                    }
                } else {
                    component.set("v.showTable", false);
                    component.set("v.visible", true);
                    component.set("v.message",'Não há benefícios para a promoção.');
                }
            } else {
                component.set("v.showSpinner", false);
                component.set("v.showTable", false);
                component.set("v.visible", true);
                component.set("v.message",'Não foi possível encontrar registros.');
            }
        });
        $A.enqueueAction(action);
    },
    
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allDataBenefits");
        var x = (pageNumber - 1) * pageSize ;
        
        for(; x <= (pageNumber) * pageSize - 1; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.dataBenefits", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    generatePageList : function(component, pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1) {
            if(totalPages <= 10) {
                var counter = 2;
                for(; counter < (totalPages); counter++) {
                    pageList.push(counter);
                } 
            } else {
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if(pageNumber>(totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    }
})