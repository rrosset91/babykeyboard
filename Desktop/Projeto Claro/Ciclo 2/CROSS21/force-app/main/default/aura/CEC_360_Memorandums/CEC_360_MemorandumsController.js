({ 
    doInit : function(component,event,helper){
       helper.setDates(component,event,helper); 
    },
    closeModal : function(component){
        component.set('v.showModal',false);
    },
    
    openModal : function(component){
        component.set('v.showModal',true);
    },
    
     callSearch: function(component,event,helper){
         component.set("v.memoList",null);
         var isAsset = component.get("v.isAsset");
         var isValid = helper.validScreen(component,event,helper);
         if(isValid){
             if(isAsset){
                  helper.getMemosAsset(component,event,helper);
             }else{
                  helper.getMemosContract(component,event,helper);
             }
            
             
         }
}
})