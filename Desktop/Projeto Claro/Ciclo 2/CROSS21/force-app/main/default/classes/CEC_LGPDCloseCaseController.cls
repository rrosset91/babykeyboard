public class CEC_LGPDCloseCaseController {
@future(callout=true)
   
    public static void ControllerManagement(string IdLgpd, string comment) {
      
         string retorno = '';
        
        string bodyManagement = ' { "data": {' 
                                 + '"requestId": "'+ IdLgpd + '" , '
                                 + '"comment":  ' + JSON.serialize(comment) +' , '
                                 + '"internal": true'
                                 + ' } }';
        string bodyStages = 
                            +' { "data": {'
                            + '"comments": "' + 'FECHADO' + '" ,'
                            + '"internalComment": true,'
                            + '"nextstage": "FECHADO",'
                            + '"resolution": "Pedido aprovado" , '
                            +'"requestQueueRefId": "' + IdLgpd  +'" , '
                            + '"language": "en-us"'
                            + '} }';
        
             system.debug('Body: '+bodyManagement);
        
         try{    
             CEC_360_LGPDIntegrationObjects.PutManagement management  = CEC_360_IntegrationManagement.PutManagement(bodyManagement);
             system.debug('retornoTry: '+management);
          CEC_360_LGPDIntegrationObjects.PutOrdersStage OrdersStage = CEC_360_IntegrationOrdersStages.putOrdersStages(bodyStages);

            
               system.debug('retornoTry: '+OrdersStage);
            //system.debug('retornoTry: '+retorno);
        }catch(CEC_IntegrationException ex){ 
           
            system.debug('retornoCatch: '+retorno);
        }
    
     
    }
    

}