/*
* Autor: Diego Almeida(IBM).
* Data: 07/07/2020
* [Claro SOLAR] [Time: CRM]
* Descrição: [PU18- Sprint 0] - Realizar contestação de itens da Fatura.
* ------------------------------------- Alterações -----------------------------------
* Data: .
* Autor: .
* [Descrição]: . 
* 
*/
public with sharing class Solar_Cross_CasesController {
    public static SolarCaseResponseWrapper SolarCreateCase(SolarCaseRequestWrapper wrapper) {
        SolarCaseResponseWrapper response = new SolarCaseResponseWrapper();
        System.debug('Çhannel: '+wrapper.canal);
        System.debug('ProcessCode__c: '+wrapper.codigoProcesso);
        List<MappingCaseManagement__mdt> lstmetadata = [  SELECT 
                                                    Subject__c,
                                                    Channel__c,
                                                    ProcessCode__c,
                                                    Origin__c,
                                                    Queue__c,
                                                    Status__c,
                                                    RecordType__c,
                                                    Ativo__c,
                                                    GenerateProtocol__c
                                                FROM 
                                                    MappingCaseManagement__mdt
                                                WHERE
                                                    Channel__c  =: wrapper.canal
                                                AND 
                                                    (ProcessCode__c =: wrapper.codigoProcesso
                                                    OR 
                                                    ProcessCode__c =: 'Geral')
                                                AND 
                                                    Ativo__c = true
                                                ];
        
        System.debug('lstmetadata: '+lstmetadata);
        //Caso nao tenha um metadado cadastrado para o processCode enviado devera ter um para o 'Geral'
        if(lstmetadata != null && lstmetadata.size() >= 1 && String.isNotBlank(wrapper.idExterno) && String.isNotBlank(wrapper.idContrato)){
            MappingCaseManagement__mdt metadata = new MappingCaseManagement__mdt();
            if(lstmetadata.size() > 1){
                for(MappingCaseManagement__mdt objMeta : lstmetadata){
                    if(objMeta.ProcessCode__c == wrapper.codigoProcesso){
                        metadata = objMeta;
                    }
                }
            }else{
                metadata = lstmetadata[0];
            }
            
            System.debug('metadata: '+metadata);

            String strRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

            Contact contactObj = new Contact();
            Account contractObj = new Account();
            Account accountObj = new Account();
            List<Contact> lstContact = new List<Contact>();
            try {
                System.debug(' wrapper.idContrato: '+  wrapper.idContrato);
                //contactObj = [SELECT Id FROM Contact WHERE ExternalID__c =: wrapper.idCliente];
                contractObj = [SELECT Id, BusinessUnit__c  FROM Account WHERE contractNumber__c =: wrapper.idContrato AND RecordTypeId =: strRecordTypeId LIMIT 1];
                System.debug('contractObj: '+contractObj);
                accountObj = [SELECT Id FROM Account WHERE ExternalID__c =: wrapper.idExterno];
                System.debug('accountObj: '+accountObj);
                lstContact = [SELECT Id  FROM Contact WHERE AccountId =:  accountObj.Id Order By ContactType__c Desc];
                if(!lstContact.isEmpty())
                	contactObj = lstContact[0];
            } catch (Exception ex) {
                response.codigo = 500;
                response.mensagem = 'DmlException: ' + ex;
            }
            
            if(response.codigo != 500){	
                String strRecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(metadata.RecordType__c).getRecordTypeId();

                List<Group> lGroupLst = [SELECT Id FROM Group WHERE DeveloperName =:metadata.Queue__c];
                List<String> protocolNumber = new List<String>();
                Case caso = new Case();
                    // Origem Wrapper
                    caso.ContactId = contactObj == null? null:contactObj.Id;                    
                    caso.AccountId = accountObj.Id;
                    caso.ContractBillingAccount__c = contractObj.Id;
                    caso.CallReason__c = wrapper.motivoContato;
                    //caso.Channel__c = wrapper.canal;
                    caso.LegacyProtocol__c = wrapper.protocolo;


                    //Adição de campos TU29
                    caso.Type = wrapper.serviceType;
                   // system.debug('wrapper.invoiceLateDays ====================================================================================> ' + wrapper.invoiceLateDays);
                    caso.InvoiceLateDays__c = wrapper.invoiceLateDays != null && wrapper.invoiceLateDays != '' ? Decimal.valueOf(wrapper.invoiceLateDays) : null;
                    // caso.BusinessUnit__c = wrapper. ; NECESSÁRIO VER SE OS CAMPOS isMovelType E isNet VEM COMO TRUE/FALSE; SIM/NÃO; S/N; 0/1 PARA FAZER A LÓGICA E POPULAR O CAMPO ####### PENDENTE
                    caso.RequestSupport__c = wrapper.scritpPointDetail;
                    caso.LastAccessedSystem__c = wrapper.lastAccessedSystem;
                    caso.SystemResponse__c = wrapper.systemResponse;
                   // system.debug('wrapper.invoiceLateDays ====================================================================================> ' + wrapper.invoiceLateDays);
                   // caso.InvoiceLateDays__c = wrapper.invoiceLateDays != null && wrapper.invoiceLateDays != '' ? Decimal.valueOf(wrapper.invoiceLateDays) : null;
                    // caso.BusinessUnit__c = wrapper. ; NECESSÁRIO VER SE OS CAMPOS isMovelType E isNet VEM COMO TRUE/FALSE; SIM/NÃO; S/N; 0/1 PARA FAZER A LÓGICA E POPULAR O CAMPO ####### PENDENTE
                   // caso.RequestSupport__c = wrapper.scritpPointDetail;
                   // caso.LastAccessedSystem__c = wrapper.lastAccessedSystem;
                   // caso.SystemResponse__c = wrapper.systemResponse;



                    //Origem Metadado
                    caso.Origin = metadata.Origin__c;
                    caso.OwnerId = lGroupLst[0].Id; //metadata.Queue__c;
                    caso.Subject = metadata.Subject__c;
                    caso.RecordTypeId = strRecordTypeIdCase;
					caso.Status = metadata.Status__c;
                	caso.Channel__c = metadata.Channel__c;
                    //Protocolo
                    caso.Product__c = wrapper.produto;
                    caso.BusinessUnit__c = contractObj.BusinessUnit__c;
					
                    if(metadata.Channel__c == 'Digital' && contractObj.BusinessUnit__c.equalsIgnoreCase('NET') && metadata.GenerateProtocol__c){
                        caso.EntryReason__c = wrapper.motivoEntrada;
                        caso.LeavingReason__c = wrapper.motivoSaida;
                        caso.Solar_Cross_forwardingReason__c = wrapper.motivoEncaminhamento;
                        caso.subReason__c = wrapper.subMotivo;
                        caso.status = wrapper.status;

                        Solar_Cross_GenerateProtocol.FlowInputVariables inputVar = new Solar_Cross_GenerateProtocol.FlowInputVariables();
                        inputVar.contractNumber = wrapper.idContrato;
                        List<Solar_Cross_GenerateProtocol.FlowInputVariables> lstInputVar = new List<Solar_Cross_GenerateProtocol.FlowInputVariables>{inputVar};
                        protocolNumber = Solar_Cross_GenerateProtocol.createOcurrencyNETSMS(lstInputVar);
                        if(!protocolNumber.isEmpty()){
                            caso.legacyProtocol__c = protocolNumber[0].StartsWith('Erro') ? null : protocolNumber[0];
                            response.protocolo = caso.legacyProtocol__c == null ? null : caso.legacyProtocol__c;
                        }
                        
                    }

                System.debug('caso Insert: '+caso.legacyProtocol__c);
                Savepoint sp = Database.setSavepoint();
                try {
                    insert caso;
                    System.debug('caso Retrieve: '+caso);
                    response.codigo = 200;
                    response.idCliente = wrapper.idExterno;
                    response.casoId = caso.id;
                    response.contratoId = contractObj.Id;
                    response.contaId    = accountObj.Id;

                } catch (DmlException ex) {
                    System.debug('107');
                    Database.rollback(sp);
                    response.codigo = 500;
                    response.mensagem = 'DmlException: ' + ex;
                }
                if(response.codigo == 200 && String.isEmpty(wrapper.protocolo)  && metadata.Channel__c != 'Digital'){
                    Case casoSelect = [SELECT Id, ContactId, AccountId, ContractBillingAccount__c, CallReason__c, ProtocolNumber__c, Origin, OwnerId, Subject, RecordTypeId, Product__c, CaseNumber, LegacyProtocol__c, BusinessUnit__c, InteractionNumber__c FROM Case WHERE Id =: caso.Id];
                    System.debug('casoSelecte: '+casoSelect);
                    
                    //Esse método dessa classe não está ok
                    List<Object>lstObjectProtocol = CEC_CC_CaseProtocolController.GetProtocol(casoSelect);
                    
                    System.debug('lstObjectProtocol: '+lstObjectProtocol);
                    //List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = (List<CEC_CC_CaseProtocolController.EntidadeProtocol>)CEC_CC_CaseProtocolController.GetProtocol(caso);
                    // String jsonString = JSON.serialize(lstObjectProtocol);
                    // System.debug('jsonString: '+jsonString);
                    List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = (List<CEC_CC_CaseProtocolController.EntidadeProtocol>)JSON.deserialize(JSON.serialize(lstObjectProtocol), List<CEC_CC_CaseProtocolController.EntidadeProtocol>.class);
                    System.debug('lstProtocol: '+lstProtocol);

                    
                    System.debug('lstProtocol: '+lstProtocol);
                    if(String.isNotBlank(lstProtocol[0].protocolo)){
                        response.protocolo = lstProtocol[0].protocolo;
                        response.status = lstProtocol[0].msgStatus;
                    }
                }
            }
        }else{
            response.codigo = 400;
            response.mensagem = 'Data not found';
        }

        System.debug('response: '+response);
        return response;
    }

    

    
    public class SolarCaseRequestWrapper{
        public String idCliente         {get; set;}
        public String idContrato        {get; set;}
        public String contractNumber    {get; set;}
        public String operatorCode      {get; set;}
        public String contactMobile     {get; set;}
        public String tipoAtendimento   {get; set;}
        public String motivoContato     {get; set;}
        public String protocolo         {get; set;}
        public String servico           {get; set;}
        public String modalidadeServico {get; set;}
        public String motivo            {get; set;}
        public String subMotivo         {get; set;}
        public String categoria         {get; set;}
        public String subCategoria      {get; set;}
        public String canal             {get; set;}
        public String origem            {get; set;}
        public String fluxo             {get; set;}
        public String produto           {get; set;}
        public String unidadeNegocios   {get; set;}
        public String codigoProcesso   {get; set;}
        public String idExterno         {get;set;}

        //Adição de campos TU29
        public String serviceType       {get; set;}
        public String serviceSubType    {get; set;}
        public String financialSituation{get; set;}
        public String invoiceLateDays   {get; set;}
        public String isMovelType       {get; set;}
        public String isNet             {get; set;}
        public String scritpPointDetail {get; set;}
        public String lastAccessedSystem{get; set;}
        public String systemResponse    {get; set;}


        public String motivoEntrada     {get;set;}
        public String motivoSaida       {get;set;}
        public String motivoEncaminhamento {get;set;}
        public String status            {get;set;}
        public String idFatura          {get;set;}
        //public Object Data              {get; set;}

        public SolarCaseRequestWrapper(){
            this.idCliente          = '';
            this.idContrato         = '';
            this.contractNumber     = '';
            this.operatorCode       = '';
            this.tipoAtendimento    = '';
            this.servico            = '';
            this.modalidadeServico  = '';
            this.motivo             = '';
            this.subMotivo          = '';
            this.categoria          = '';
            this.subCategoria       = '';
            this.canal              = '';
            this.origem             = '';
            this.fluxo              = '';
            this.contactMobile      = '';
            this.motivoContato      = '';
            this.protocolo          = '';
            this.idExterno          = '';
             //Adição de campos TU29
             this.serviceType        = '';
             this.serviceSubType     = '';
             this.financialSituation = '';
             this.invoiceLateDays    = '';
             this.isMovelType        = '';
             this.isNet              = '';
             this.scritpPointDetail  = '';
             this.lastAccessedSystem = '';
             this.systemResponse     = '';
             this.motivoEntrada      = '';
             this.motivoSaida        = '';
             this.motivoEncaminhamento = '';
             this.status             = '';
             this.idFatura           = '';
            //this.data               = null;
        }
    }

    public class SolarCaseResponseWrapper{
        public Integer codigo   {get; set;}
        public String mensagem  {get; set;}
        public String idCliente {get; set;}
        public String protocolo {get; set;}
        public String status    {get; set;}
        public String fluxo     {get; set;}
        public String casoId    {get; set;}
        public String contaId   {get;set;}
        public String contratoId {get;set;}

        public SolarCaseResponseWrapper(){
            this.codigo     = 0;
            this.mensagem   = '';
            this.idCliente  = '';
            this.protocolo  = '';
            this.status     = '';
            this.fluxo      = '';
            this.casoId     = '';
            this.contaId    = '';
            this.contratoId = '';
        }
    }

    

}