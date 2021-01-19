/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 23/01/2020 
* Descrição: [CEC - Extensão Fase 2] - [Time: SQUAD Canais Criticos - Sprint 17] - [Integração Protocolo PS8]
* 
* Controle de Versão
* -----------------------------------------------------------------------------------------------------------
* Data: 04/03/2020  
* Autor: Squad Canais Criticos
* Alterações: Alteração no método getDescription para evitar replace do campo (exceção do caracter especial $)
* ------------------------------------------------------------------------------------------------------------
* ------------------------------------------------------------------------------------------------------------
* Data: 22/07/2020
* Autor: Squad LGPD - Guilherme Cuencas - Sysmap Solution
* Descrição: [SOLAR Sprint 4] - [Integração Protocolo PS8]
* Alterações: Inclusão do processo de LGPD na criação de protocolo para PS8
* ------------------------------------------------------------------------------------------------------------
*/

public class CEC_ProtocolMovelService {
    
    public static Map<Id, CEC_ProtocolNetResponse> create(Set<Id> setCasesId)
    {
        System.debug('CEC_ProtocolMovelService >> create');
        
        Map<Id, CEC_ProtocolNetResponse> mapResponses = new Map<Id, CEC_ProtocolNetResponse>();
        
        Set<String> setProducts = new Set<String>();
        Set<String> setBU = new Set<String>();
        
        List<Case> lstCases = [SELECT Id, CaseNumber, Output_Subject__r.Name, Description, Product__c, Contact.Name, ContactEmail,  ContractMSISDN__c,
                                      Channel__c,InputType__c, Resolution__c, BusinessUnit__c FROM Case WHERE Id IN: setCasesId];
        
        for(Case varCase: lstCases) {
            setProducts.add(varCase.Product__c);
            setBU.add(varCase.BusinessUnit__c);
        }
        
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(setBU, setProducts);
        
        for(Case varCase: lstCases)
        {      
            CEC_ProtocolNetResponse CEC_Response = new CEC_ProtocolNetResponse();
            
            try{
                system.debug('CEC_CreateProtocolMovelService ## Classificação do Procedimento (' + varCase.Product__c + ')');
                
                if(!mapClassification.containsKey(varCase.BusinessUnit__c) && 
                   !mapClassification.get(varCase.BusinessUnit__c).containsKey(varCase.Product__c))
                    throw new CEC_IntegrationException('Classificação (' + varCase.BusinessUnit__c + 'x' + varCase.Product__c + ') não encontrada para o caso: ' + varCase.CaseNumber);
                
                if(String.isBlank(varCase.ContractMSISDN__c) && varCase.Product__c <> 'Sem produto')
                    throw new CEC_IntegrationException('Número da Linha não informado para o caso: '  + varCase.CaseNumber);
                
                ProtocolMovelServiceRequest request = new ProtocolMovelServiceRequest();
                DataRequest data = new DataRequest();
                
                data.companyId = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Company__c;
                data.channelRequestId = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ChannelRequestId__c;
                data.situation = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Situation__c;
                data.contactTypeId = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ContactTypeId__c;
                data.result = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Result__c;
                
                //Parametrizado
                data.reasonCode1 = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ReasonCode1__c;
                data.reasonCode2 = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ReasonCode2__c;
                data.reasonCode3 = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ReasonCode3__c;
                data.reasonCode4 = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ReasonCode4__c;
                data.reasonCode5 = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).ReasonCode5__c;
                
                data.summary = varCase.Output_Subject__r.Name;
                data.description = getDescription(mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Description__c, varCase);        
                data.contactName = varCase.Contact.Name;
                data.contactEmail = varCase.ContactEmail;
                
                system.debug('CEC_CreateProtocolMovelService ## Número da Linha (' + varCase.CaseNumber + '): ' + varCase.ContractMSISDN__c );
                
                Customer customer = new Customer();
                //21-02-2020 Retirar os 0s a esquerda para não dar erro no PS8
                customer.msisdn = getMSISDN(varCase.ContractMSISDN__c);
                data.customer = customer;
                
                request.data = data;
                
                System.debug('request: '+request);
                
                HttpResponse response = CEC_HttpReq.sendReq('CEC_OAG_Claro_Protocol', request);
                CEC_Response = parseResponse(response);

            } catch(Exception ex) {
                CEC_Response = builMessageError(ex.getMessage());
            }
            
            mapResponses.put(varCase.Id, CEC_Response); 
        }
        
        return mapResponses;
    }    
    
    //Métodos resposável por tratar o error 
    private static CEC_ProtocolNetResponse parseResponse(HttpResponse varResponse)
    {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_ProtocolNetResponse response = (CEC_ProtocolNetResponse) parser.readValueAs(CEC_ProtocolNetResponse.class);  
        
        if(varResponse.getStatusCode() == 200)
        {
            return response;            
        }
        else
        {
            if(response.error <> null)
                throw new CEC_IntegrationException(response.error.detailedMessage);
            else
                throw new CEC_IntegrationException('StatusCode: ' + varResponse.getStatusCode() + '| MessageError: ' + varResponse.getBody());
        }
        
    }
    
    //Método responsável por tratar os erros customizados da integração
    @testVisible private static CEC_ProtocolNetResponse builMessageError(String error)
    {
        CEC_ProtocolNetResponse response = new CEC_ProtocolNetResponse();
        
        response.error = new CEC_ProtocolNetResponse.Error();
        response.error.message = 'Validation Error';
        response.error.detailedMessage = error;
        
        return response;
    }
    
    @testVisible private static String getDescription(String messageBody, Case caseInfo)
    {
        //Mensagem extra configurada no metadata
        if(String.isNotBlank(messageBody)) messageBody =+ '/n';
           
        //Mensagem padrão de envio ao PS8
        messageBody =+ 'Caso inserido para o canal ' + caseInfo.Channel__c + ' via ' + caseInfo.InputType__c + '\n';     
        messageBody =+ 'Descrição: ' + caseInfo.Description  + '\n';
        messageBody =+ 'Resolução: ' + caseInfo.Resolution__c;
        
        return messageBody;
    }    
    
    @testVisible private static String getMSISDN(String varContract)
    {
        Decimal contractOnlyNumbersDecimal = Decimal.valueOf(varContract.trim());
        varContract = String.valueOf(contractOnlyNumbersDecimal);
        return varContract;
    }
    /* ************************************************ Contrato de Request e Response ************************************************ */
    
    public class ProtocolMovelServiceRequest
    {
        public DataRequest data { get; set; }
    }
    
    public virtual class DataRequest {
        
        public Customer customer { get; set; }
        
        public String companyId { get; set; }
        public String channelRequestId { get; set; }
        public String situation { get; set; }
        public String reasonCode1 { get; set; }
        public String reasonCode2 { get; set; }
        public String reasonCode3 { get; set; }
        public String reasonCode4 { get; set; }
        public String reasonCode5 { get; set; }
        public String summary { get; set; }
        public String description { get; set; }
        public String contactTypeId { get; set; }
        public String contactName { get; set; }        
        public String contactEmail { get; set; }
        public String result { get; set; }
        
    }
    
    public class Customer {
        public string msisdn { get; set; }
    }
}