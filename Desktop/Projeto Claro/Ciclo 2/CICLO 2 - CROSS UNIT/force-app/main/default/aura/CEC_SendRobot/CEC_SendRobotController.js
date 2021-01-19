({
    doInit : function(component, event, helper) {

        //Recupera OrderId via url
        component.set("v.cartid", component.get("v.pageReference").state.c__cartid);

        //Recupera Endpoint Robo
        var vRobotUrl = $A.get("$Label.c.RobotUrlHttps");

        var action    = component.get("c.getObjects");        
        action.setParams({
            'idObj': component.get("v.cartid")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state=="SUCCESS"){
                var obj = JSON.parse(response.getReturnValue());
                
                //Chamada Método Post para envio dos dados ao Robo
                helper.postToURL(vRobotUrl, obj[0], 'post');
                
          		//Exibe mensagem de envio
                component.set("v.showErrors",true);
                component.set("v.errorMessage",'O processo de preenchimento de dados no legado está em execução');
                helper.displayError(component,'warning');
                
            }else if(state=="ERROR"){
                //Exibe mensagem de erro na recuperação dos dados do pedido
                var errors = response.getError();		 
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
                helper.displayError(component,'error');
            }
        });
        $A.enqueueAction(action); 
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})