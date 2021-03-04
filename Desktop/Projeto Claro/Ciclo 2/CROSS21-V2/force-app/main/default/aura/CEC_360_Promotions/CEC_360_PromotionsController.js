({
    doInit : function(component, event, helper) {
        helper.loadPromotions(component, event, helper);
        helper.setDatePromotions(component,event,helper);
      },
    
    openDetails: function(component, event, helper) {
        console.log(event.target.getAttribute('data-promotionIdNGP'));
        var modalBody;
        $A.createComponent("c:CEC_360_PromotionBenefits", {
            recordId : component.get('v.recordId'),
            promotionName : event.target.getAttribute('data-promotionName'),
            effectiveDate : event.target.getAttribute('data-effectiveDate'),
            channelName : event.target.getAttribute('data-channelName'),
            statusContractedPromotion : event.target.getAttribute('data-statusContractedPromotion'),
            promotionIdNGP : event.target.getAttribute('data-promotionIdNGP'),
            promotionVersionNGP : event.target.getAttribute('data-promotionVersionNGP'),
            sequentialIdNGP : event.target.getAttribute('data-sequentialIdNGP')
        }, function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                component.find('overlayLib').showCustomModal({
                    body: modalBody, 
                    showCloseButton: false,
                    cssClass: "mymodal slds-modal_medium",
                    closeCallback: function() {
                        
                    }
                })
            }                               
        });
    },
    
    openDetails1: function(component, evt, helper) {
        var modalHeader;
        var modalBody;
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "HTMLAttributes": { 
                        "class": "slds-button__icon_large" 
                    }
                }],
                ['c:CEC_360_PromotionBenefits', {}]
            ], 
            function(components, status) {
                if (status === 'SUCCESS') {
                    modalHeader = components[0]
                    modalBody = components[0];
                    component.find('overlayLib').showCustomModal({
                        body: modalBody,
                        showCloseButton: false,
                        cssClass: 'mymodal slds-modal_medium'
                    });
                }
            });
    },
    callPromotionsHistory: function(component,event,helper){
        component.set('v.dataPromotionsHistory',null);
        component.set('v.showTableHistory',false);
        var isValid =  helper.validScreen(component,event,helper);
        if(isValid){
            helper.loadPromotionsHistory(component, event,helper);
        }
    },
    
    
    anteriorHandler : function(component, event, helper) {
        var dataList = component.get("v.dataPromotionsHistory");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++) {
            if(i > -1) {
                paginationList.push(dataList[i]);
                counter ++;
            }else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },
    
      
    proximoHandler : function(component, event, helper) {
        var dataList = component.get("v.dataPromotionsHistory");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        
        for(var i=end+1; i<end+pageSize+1; i++) {
            if(dataList.length > end) {
                if(dataList[i] != null) paginationList.push(dataList[i]);
                counter ++;
            }
        }
        start = start + counter;
        end = end + counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },
   
})