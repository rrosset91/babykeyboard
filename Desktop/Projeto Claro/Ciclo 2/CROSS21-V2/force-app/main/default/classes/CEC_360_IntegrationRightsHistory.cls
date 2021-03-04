/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 09/07/2020
   	Descrição: Classe de integração do componente CEC_360_LGPDRightsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC 
	Alterado: Guilherme Cuencas 04/09/2020 */
	
	public class CEC_360_IntegrationRightsHistory {
 
    
    public static CEC_360_LGPDIntegrationObjects.getRightsHistory OrdersRightsHistory(String cpf) { 
        CEC_360_LGPDIntegrationObjects.getRightsHistory rights = new CEC_360_LGPDIntegrationObjects.getRightsHistory();
        CEC_LGPD_Parameters__mdt paramsClientAuth = [Select statuses__c,clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigDsar'];
        string service = CEC_360_ServiceName.getServiceName('customersOrders');
        string parameters = '?language=br-pt&page=0&limit=50';
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:APIGEE_Claro'+ service + parameters );
            
            request.setMethod('GET');
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', paramsClientAuth.clientAuth__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf='+cpf);
            
            request.setTimeout(120000);
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
          
      
            rights = (CEC_360_LGPDIntegrationObjects.getRightsHistory)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.getRightsHistory.class);

           
            
            //formatting integration data
           for(CEC_360_LGPDIntegrationObjects.customerOrders rightsDataString : rights.customerOrders){
               System.debug('type' + rightsDataString.id);
                          System.debug('type' + rightsDataString.orderType);

               CEC_LGPDdsar__mdt[] mdt = [SELECT DeveloperName,rightName__c,Extract__c FROM CEC_LGPDdsar__mdt WHERE DeveloperName  =: rightsDataString.orderType limit 1];
              // System.debug('orderType +++: ' + mdt);
               
                //rule to check if extract is available 
               if(!Test.isRunningTest()&& !mdt.isEmpty()){
              
               if( mdt[0].Extract__c == true && rightsDataString.status == 'Concluido') {
                   //disabled button == false
                   rightsDataString.extractAvailable = false;

               } else{ 
                   rightsDataString.extractAvailable = true;
               }
              if (rightsDataString.orderType != null ){
                   rightsDataString.orderType = mdt[0].rightName__c;
                             } 
                  }
                if(rightsDataString.orderDate != null ){
                    rightsDataString.orderDateOld = rightsDataString.orderDate;
                    DateTime orderDate = (DateTime)JSON.deserialize('"'+rightsDataString.orderDate  +'"', DateTime.class);
                    String orderDateStr = orderDate.format('dd/MM/yyyy HH:mm:ss');
                    rightsDataString.orderDate  = orderDateStr;
                    
                }
                if (rightsDataString.completionDate != null ){
                    rightsDataString.completionDateOld = rightsDataString.completionDate;
                    DateTime completionDate = (DateTime)JSON.deserialize('"'+rightsDataString.completionDate +'"', DateTime.class);
                    String completionDateStr = completionDate.format('dd/MM/yyyy HH:mm:ss');
                    rightsDataString.completionDate  = completionDateStr;
                    
                }
               if (rightsDataString.subjectType != null){
                   string subjectType = rightsDataString.subjectType.toString();
                   subjectType= subjectType.remove('(');
                   subjectType = subjectType.remove(')');
                   rightsDataString.subjectTypeStr = subjectType;
               }
               system.debug ('REtornooo' + rightsDataString.extractAvailable);
            }
            
            System.debug('response.getStatusCode(): ' + response.getStatusCode());
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return rights;
    }
}