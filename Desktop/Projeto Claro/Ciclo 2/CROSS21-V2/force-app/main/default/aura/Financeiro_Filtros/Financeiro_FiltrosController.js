({
 
	handlePeriodFilter: function(component, event, helper){     
       var selectedOptionValue = event.getParam("value");
       const periodaction = component.get("v.handlePeriodFilter");
        
       if(selectedOptionValue == "CustomFilter"){
        component.set("v.PeriodoCustomizado", true);
        return component.set("v.PeriodoCustomizado", true);
           
       }
      

        $A.enqueueAction(periodaction);               
        
    },
    
    
     
    handleProductFilter : function(component, event, helper){
        console.warn('Não implementado');
    },
    
    handleStatusFilter : function(component, event, helper){
        console.warn('Não implementado');
    },
     
    
    handleDateFilter : function(component, event, helper) {
        var selectedEndDateValue = component.get("v.FilterEndDate"); 
        var selectedStartDateValue = component.get("v.FilterStartDate");
        
        if (selectedStartDateValue == null){
            component.set("v.ButtonFilterdisabled", true)
            
        } else if (selectedEndDateValue == null) {
                     component.set("v.ButtonFilterdisabled", true)
            
        } else {component.set("v.ButtonFilterdisabled", false)
               
        }     
    },

    onClickFiltrarPeriodo : function(component, event, helper) {
          const func = component.get('v.onClickFiltrarPeriodo');
        
        if(func)
            $A.enqueueAction(func);
    },
    
})