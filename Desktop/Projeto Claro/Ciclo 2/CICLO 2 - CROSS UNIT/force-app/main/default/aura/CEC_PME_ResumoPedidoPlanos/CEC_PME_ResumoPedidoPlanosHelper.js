({
    // Função para esconder uma seção ao clicar em outro elemento (como um header/label)
    toggleVisibilidadeSecao: function(cmp, headerName) {
        var query = 'secao' + headerName;
        var queryHeader = 'header' + headerName;
        var header = document.getElementById(queryHeader);
        var element = document.querySelectorAll(`div[id^=${query}]`);

        if(element.length != 0){
            for (var i=0 ; i < element.length ; i++){
                $A.util.toggleClass(element[i], "slds-hide");
            }
        }
        if (header) {
            $A.util.toggleClass(header, "active");
        }
        
        return null;
    },
    
   /* loadDesconto: function(cmp) {
        
        let urlString = window.location.href;
        let url = new URL(urlString);
        let param = url.searchParams.get('id');
		
        console.log(param);
        
        var action = cmp.get("c.getDescontos");
        action.setParams({ OrderId: param });
       action.setCallback(this, function (a) {
           if (a.getState() === "SUCCESS") {
               cmp.set("v.Data", a.getReturnValue());
               console.log(a.getReturnValue().vlocity_cmt__RecurringDiscountPrice__c);
               return a.getReturnValue().vlocity_cmt__RecurringDiscountPrice__c;
           } else if (a.getState() === "ERROR") {
               var errors = a.getError();
               //Se llama al metodo para visualizar el error
        this.handleErrors(errors);
           }
       });
       $A.enqueueAction(action);
        

    }*/
})