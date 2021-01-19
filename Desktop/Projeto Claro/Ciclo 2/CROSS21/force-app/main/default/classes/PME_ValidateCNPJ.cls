/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
* Classe que implementa a lógica reponsável pela consulta de CNPJ na tela de busca de cliente.
* Seus métodos são consumidos pelo vlocity.
* Controle de Versão
* ---------------------------------------------------------------
* Data: 02/06/2020    
* Autor: João Rodrigues
* Alterações: DDP 128209 - Correção da busca de CNPJ (consultarDadosConsolidadosCliente) que antes considerava que qualquer linha suspensa era ativa.
*/

global with sharing class PME_ValidateCNPJ implements vlocity_cmt.VlocityOpenInterface{
  
    global PME_ValidateCNPJ() {}
  
      /*
  * Autor: Marcos Aurelio - Deloitte
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
     Principal método da classe, conforme o parametro methodName, é definido qual o fluxo a ser executado.
  */    
  
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
      Boolean result = true;
  
         try{
            if('validateCNPJ'.equals(methodName)){
                validateCNPJ(inputMap, outMap, options);
            } else if ('validateCPF'.equals(methodName)){
                validateCPF(inputMap, outMap, options);
            } else if ('consultarDadosConsolidadosCliente'.equals(methodName)){
              consultarDadosConsolidadosCliente(inputMap, outMap, options);
            } else if(methodName.equals('convertLeadInAccountContact')){
          convertLeadInAccountContact(inputMap, outMap, options);
            } else {
                result = false;
            }
      } catch(Exception e){  
        System.debug('Exception type caught: ' + e.getTypeName());   
          System.debug('Message: ' + e.getMessage());   
          System.debug('Cause: ' + e.getCause());
          System.debug('Line number: ' + e.getLineNumber());   
          System.debug('Stack trace: ' + e.getStackTraceString());
             result = false;  
  
        }  
        return result;  
  
     }
  
    
  /*
  * Autor: Marcos Aurelio - Deloitte
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
     Realiza a conversão de um LEAD em conta/oportunidade.
  */    
  
    private void convertLeadInAccountContact(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
      
      String idLead = (String)input.get('DRId_Lead');
      
         Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(idLead);
      LeadStatus convertStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      lc.setConvertedStatus(convertStatus.ApiName);
      lc.setDoNotCreateOpportunity(true);
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      
      String accountId = lcr.getAccountId();
      String contactId = lcr.getContactId();
  
         outMap.put('AccountId',accountId);
         outMap.put('ContactId',contactId);
    }
      
  /*
  * Autor: Marcos Aurelio - Deloitte
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
     Realiza a validação do CNPJ inserido no fluxo de Busca de cliente.
  */    
      private void validateCNPJ(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
      
        String cnpj = (String)options.get('cnpj');
        Boolean retorno = CEC_PME_Utils.validateCNPJ(cnpj);
           outMap.put('cnpjValidado',retorno);
    }
  /*
  * Autor: Marcos Aurelio - Deloitte
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11]
     Realiza a validação do CPF inserido no fluxo de pedido.
  */    
      private void validateCPF(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
      
        String cpf = (String)options.get('CPF');
        String cpfremove = cpf.remove('.');
        String cpfremove2 = cpfremove.remove('-');      
        Boolean retorno = CEC_PME_Utils.validateCPF(cpfremove2);
           outMap.put('cpfValidado',retorno);
    }
  /*
  * Autor: Marcos Aurelio - Deloitte
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
      Método que faz a consulta de cliente utilizando serviço externos. Parte da regra de mensagem está contida no método.
  */    
    private void consultarDadosConsolidadosCliente(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
        String segment = '';
        String returnMessage;
        Boolean activeLines = false;
        Boolean isClient = false;
        Boolean hasError = false;
        String cnpj = (String)options.get('cnpj');
        Integer pageNumber = 1;
        Integer recordsLimit = 50;
        Boolean isLastPage = false;

        CEC_PME_MobileCustomer_Response resClient = PME_ValidateCNPJ_Service.getClientMobile(cnpj);
  
        if(resClient.data != Null){
              
            isClient = true;

            while(!isLastPage) {
  
                PME_ValidateCNPJ_Response res = PME_ValidateCNPJ_Service.getInfoByClientActive(cnpj, pageNumber, recordsLimit);

                if(res.data != Null){

                    Integer returnedSubs = res.data.subscribers.size();

                    if(returnedSubs > 0){
                        for(PME_ValidateCNPJ_Response.Subscribers subscriber : res.data.subscribers){

                            if(subscriber.customer != Null){
                                if(subscriber.customer.subType != Null){
                                    segment = subscriber.customer.subType;
                                    if(!subscriber.status.contains('SUSPENSO_FINAL')){
                                        activeLines = true;
                                        break;
                                    } 
                                }
                            }
                        }
                        if(activeLines) {
                            returnMessage = 'CNPJ com linha ativa, não é possível seguir com o cadastro';
                            isLastPage = true;
                        } else {
                            returnMessage = 'CNPJ com cadastro sem linha ativa. Poderá seguir com o processo de venda, o input será manual';                                    
                        }
                        if(returnedSubs < recordsLimit) {
                            isLastPage = true;
                        } else {
                            pageNumber++;
                        }
                    }
                } else {
                    isLastPage = true;
                }
                
                if(res.parametroinvalidofault != Null){
                    returnMessage = resClient.parametroinvalidofault.mensagem;
                    isLastPage = true;
                }
    
                if(res.Technicalfault != Null){
                    returnMessage = res.technicalfault.mensagem;
                    isLastPage = true;
                }
            }
        }
         
        if(!isClient){
            CEC_PME_MobileCorporateCustomer_Response resMobCorpCustomer = PME_ValidateCNPJ_Service.getMobileCorporateCustomer(cnpj);
            if(resMobCorpCustomer.data != Null){
                isClient = true;    
                System.Debug(resMobCorpCustomer.data.mobileCustomers.documentNumberCNPJ);
            }
            
            if(resMobCorpCustomer.error != Null){
                returnMessage = resMobCorpCustomer.error.message;
                System.Debug('****ERRO CONSULTA MOBILE CORPORATE CUSTOMERS****');
                System.Debug('httpCode: ' + resMobCorpCustomer.error.httpCode);
                System.Debug('errorCode: ' + resMobCorpCustomer.error.errorCode);
                System.Debug('message: ' + resMobCorpCustomer.error.message);
                System.Debug('detailedMessage: ' + resMobCorpCustomer.error.detailedMessage);
                System.Debug('************************************************');
            }
        }
        
        if(resClient.parametroinvalidofault != Null){
            returnMessage = resClient.parametroinvalidofault.mensagem;
        }

        if(resClient.Technicalfault != Null){
            returnMessage = resClient.technicalfault.mensagem;
        }

        if(!String.isBlank(returnMessage)){
            hasError = true;
            outMap.put('returnMessage', returnMessage);
        }
        
        outMap.put('segment', segment);
        outMap.put('activeLines', activeLines);
        outMap.put('isClient',isClient);
        outMap.put('hasError', hasError);       
    }
  }