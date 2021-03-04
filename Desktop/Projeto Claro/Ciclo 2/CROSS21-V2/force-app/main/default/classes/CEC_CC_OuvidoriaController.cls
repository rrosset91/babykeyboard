/**
 * ---------------------------------------------------------------
 * Data: 16/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions
 * Descrição:  Ouvidoria - Controller para Consulta de protocolo no PS8, NETSMS, e PSAC
 * ---------------------------------------------------------------
 * --- Controle de Versão
 * ---------------------------------------------------------------------------------------------------------
 * Author: Squad LGPD - Sysmap Solutions
 * Description: Consulta de protocolo no PS8 e NETSMS, PSAC mockado
 * Date: 16/10/2020
 * ---------------------------------------------------------------------------------------------------------
 * Author: Squad LGPD - Sysmap Solutions
 * Description: Integração com PSAC
 * Date: 05/11/2020
 * ---------------------------------------------------------------------------------------------------------
*/
global class CEC_CC_OuvidoriaController {
    public static final String MAIOR_180 = 'INVÁLIDO - PROTOCOLO MAIOR QUE 180 DIAS';
    public static final String DENTRO_PRAZO = 'INVÁLIDO - PROTOCOLO DENTRO DO PRAZO DE 5 DIAS';
    public static final String OK = 'VÁLIDO';

    /**
     * Enum para representar os legaod possíveis onde o protocolo vai ser encontrado
     */
    private enum Legacy {
        NETSMS,
        PS8,
        PSAC
    }

    /**
     * Método que busca um protocolo nos legados, para consulta pela URA e Minha Claro
     * A consulta é feita no PS8, depois no NETSMS (ambos via API /interactions)
     * Se não encontrado em nenhum dos dois, é feita chamada ao PSAC da Embratel
     */
    //*
    public static CEC_CC_LegacyProtocolResponse getLegacyProtocol(
        String protocol,
        String cpf,
        String companyId
    ) {
        Legacy legacySystem;
        CEC_CC_LegacyProtocolResponse legacyProtocol = new CEC_CC_LegacyProtocolResponse();

        
        // Se foi informado um CPF, buscamos no Salesforce os dados do cliente que foi passado no CPF
        
        Account customer = null;   // O cliente que foi/será encontrado
        List<Account> contractsResidencial = null; // os contratos residencial
        List<Asset> assetMovel = null; // os contratos móvel

        // Só faz a busca se o CPF foi passado no parâmetro
        Boolean validateCpf = !String.isBlank(cpf);
        if(validateCpf){

            // Obter os dados do cliente
            Account[] accs = [
                SELECT
                    Id,
                    Name,
                    DocumentType__c,
                    DocumentNumber__c,
                    Phone,
                    CellPhone__c,
                    Email__c,
                    CustomerTypeList__c,
                    vlocity_cmt__BillingEmailAddress__c
                FROM Account
                WHERE DocumentNumber__c = :cpf AND DocumentType__c = 'CPF'
            ];

            if (accs.size() == 0) {
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message =
                    'Não foi encontrado um cliente com o CPF ' + cpf;
                legacyProtocol.error.httpCode = '500';
                return legacyProtocol;
            }
            customer = accs[0];

            // Obter os contratos residenciais
            contractsResidencial = [
                SELECT
                    id,
                    ContractNumber__c,
                    vlocity_cmt__Status__c,
                    InstalledPremises__r.Name,
                    vlocity_cmt__BillingEmailAddress__c,
                    InstalledPremises__r.vlocity_cmt__StreetAddress__c,
                    ContractType__c,
                    BusinessUnit__c,
                    (
                        SELECT Id, Email, Phone, MobilePhone, DocumentNumber__c
                        FROM Contacts
                    )
                FROM Account
                WHERE
                    ParentId = :customer.Id
                    AND RecordTypeId = :CEC_360_ShowContractsActiveController.recTypeContract
                    AND vlocity_cmt__Status__c != 'Cancelado'
                    AND ContractNumber__c != NULL
                    AND BusinessUnit__c = 'Net'
            ];

            // Procurar no account customer os contratos móveis ativo
            assetMovel = [
                SELECT
                    id,
                    MSISDN__c,
                    Status,
                    Name,
                    BusinessUnit__c,
                    Product2Id,
                    vlocity_cmt__ContractId__c
                FROM Asset
                WHERE
                    AccountId = :customer.Id
                    AND RecordType.DeveloperName IN :CEC_360_ShowContractsActiveController.RECORD_TYPES_ASSET
                    AND Status != 'Cancelado'
                    AND MSISDN__c != NULL
            ];

            system.debug('asset');
            System.debug(assetMovel);
        }

        // Preparar a Request para chamar o interactions
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        
        
        
        if(companyId == '002'){ //PS8
            legacyProtocol = getPS8Protocol(protocol, cpf, assetMovel);

            if(legacyProtocol.data == null && legacyProtocol.error.httpCode == '422' && legacyProtocol.error.detailedMessage == 'Protocolo não pertence ao cliente') {
                return legacyProtocol;
            }

        }else if(companyId == '001'){ //NETSMS
            legacyProtocol = getNETSMSProtocol(protocol, cpf, contractsResidencial);
            // se aindda não foi encontrado, buscar no PSAC
            if(legacyProtocol.data == null && legacyProtocol.error.httpCode == '422' && legacyProtocol.error.detailedMessage == 'Protocolo não pertence ao cliente')
            {
                return legacyProtocol;
            }
            
        }
        else if(companyId == '003'){ //PSAC
        //if(legacyProtocol.data == null){
            legacyProtocol = getEbtProtocol(protocol);
            // if(legacyProtocol.data == null){
            //     // SE HOUVE ALGUM ERRO...
            //     if(legacyProtocol.error == null){
            //         // mas o objeto de erro está nulo
            //         legacyProtocol.error = new CEC_RestObjects.Error();
            //         legacyProtocol.error.message = 'Erro desconhecido';
            //         legacyProtocol.error.httpCode = '500';
            //     }else{
            //         legacyProtocol.error = new CEC_RestObjects.Error();
            //         legacyProtocol.error.message = 'Protocolo não encontrado';
            //         legacyProtocol.error.httpCode = '404';
            //     }
            //     // Se obj de erro não está nulo, não há nada a fazer, apenas retornar
            // }
        }

        if(legacyProtocol.data == null){
            // SE HOUVE ALGUM ERRO...
            if(legacyProtocol.error == null){
                // mas o objeto de erro está nulo
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message = 'Erro desconhecido';
                legacyProtocol.error.httpCode = '500';
            }else{
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message = 'Protocolo não encontrado';
                legacyProtocol.error.httpCode = '404';
            }
            // Se obj de erro não está nulo, não há nada a fazer, apenas retornar
        }

        return legacyProtocol;
    }
    //*/

    /**
     * Busca um protocolo no sistema PSAC (Embratel)
     */
    private static CEC_CC_LegacyProtocolResponse getEbtProtocol(String protocolNumber) {
        
        CEC_CC_LegacyProtocolResponse legacyProtocol = new CEC_CC_LegacyProtocolResponse();
                
        CEC_PSAC_Response ebtProtocol = new CEC_PSAC_Response();
        String namedCredential = '';
        if(CEC_CatalogUtilities.isRunningInSandbox()){
            namedCredential = 'APIGEE_Claro_SAAS';
        }else{
            namedCredential = 'APIGEE_OPDK_Claro_CAS';
        }
        //*
        String endpoint = 'callout:'+ namedCredential + '/interactions' + 
		'?companyId=EMBRATEL&protocolNumber=' + protocolNumber;

        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setEndpoint(endpoint);

        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept', '*/*');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');

        Http h = new Http();

        try{
            HttpResponse response = h.send(request);
            String responseBody = response.getBody();
            System.debug('PSAC RESPONSE BODY >>> ' + responseBody);
            ebtProtocol = (CEC_PSAC_Response) JSON.deserialize(
                responseBody,
                CEC_PSAC_Response.class
            );
        }catch(CalloutException ex){
            system.debug(ex);
            system.debug(ex.getCause());
            ex.setMessage(request.getEndpoint() + ' | ' + ex.getMessage());
            throw ex;
        }catch(Exception ex){
            system.debug(ex);
            system.debug(ex.getCause());
            CEC_IntegrationException ex2 = new CEC_IntegrationException();
            ex2.errorMessage = ex.getMessage();
            ex2.errorCode  = '500';
            ex2.httpCode  = '500';
            throw ex2;
        }

        System.debug('psac response' + ebtprotocol);
        // construímos noss response de acordo com os
        // códigos de erro possíveis de ser retornados
        legacyProtocol.error = ebtProtocol.error;
        
        
        if(ebtProtocol.error != null || legacyProtocol.data == null){
            legacyProtocol.data = null;
            legacyProtocol.error = ebtProtocol.error;
            legacyProtocol.legacyData = null;
        } else {
            legacyProtocol.data.protocolNumber = protocolNumber;
            legacyProtocol.data.interactionNumber = ebtProtocol.data.attendances.interactionNumber;
            
            if(ebtProtocol.data.attendances.solicitationOpeningDate == null){
                // Tratar a ausência da data como protocolo nao encontrado
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message = 'PSAC: Erro desconhecido';
                legacyProtocol.error.httpCode = '404';  //404 será traduzido na Fachada para 500
                legacyProtocol.legacyData = ebtProtocol.data;
                return legacyProtocol;
            }
            String[] dateSplit = ebtProtocol.data.attendances.solicitationOpeningDate.substring(0,10).split('/');

            Date openingDate = Date.newInstance(Integer.valueOf(dateSplit[2]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[0]));
            legacyProtocol.data.interactionOpeningDate = dateSplit[2]+'-'+ dateSplit[1]+ '-'+dateSplit[0]+ 'T' + ebtProtocol.data.attendances.solicitationOpeningDate.substring(10);
            Date today = Date.today();
            Integer daysOpened = openingDate.daysBetween(today);
            
            if(daysOpened > 180){
                legacyProtocol.eligibility = MAIOR_180;
            }else {
                legacyProtocol.eligibility = OK;
            }
            legacyProtocol.data.status = 'CONCLUÍDO';
            legacyProtocol.data.legacy = 'PSAC';
            legacyProtocol.legacyData = ebtProtocol.data;
            System.debug('PSAC PROTOCOL >>> ' + legacyProtocol);
        }

        return legacyProtocol;
    }

    /**
     * Busca um protocolo no NETSMS
     */
    private static CEC_CC_LegacyProtocolResponse getNETSMSProtocol(String protocol, String cpf, Account[] contractsResidencial){
        CEC_CC_LegacyProtocolResponse legacyProtocol = new CEC_CC_LegacyProtocolResponse();
        LegacyProtocol objProtocol = null;

        //opcode são os 3 primeiros digitos do protocolo
        String opCode = protocol.substring(0, 3);

        String endpoint =
            'callout:OAGClaro/interactions' +
            '?protocolNumber=' +
            protocol +
            '&operatorCode=' +
            opCode;

        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
            
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setEndpoint(endpoint);

        System.debug('endpoint ' + endpoint);
        HttpResponse resp;
        String responseBody;
        responseBody = CEC_HttpReq.sendReq(request, null).getBody();

        objProtocol = (LegacyProtocol) JSON.deserialize(
            responseBody,
            LegacyProtocol.class
            );
            
        System.debug(objProtocol);

        if (
            objProtocol != null &&
            objProtocol.data != null &&
            objProtocol.data.attendances.size() > 0
        ) {

            // Se o CPF foi passado, verificar se o protocolo pertence a esse cliente chamando a /customercontracts
            if(!String.isBlank(cpf)){
                request = new HTTPRequest();
                endpoint = 'callout:OAGNet/customercontracts?protocolNumber='+protocol;
                                    
                request.setEndpoint(endpoint);
                request.setMethod('GET');
                request.setTimeout(120000);
                
                http = new HTTP(); 
                System.debug(request.getEndpoint());
                HTTPResponse response = CEC_HttpReq.sendReq(request, null);
                
                responseBody = response.getBody();
                CustomerContractProtocol contract = (CustomerContractProtocol)JSON.deserialize(responseBody, CustomerContractProtocol.class);
                System.debug('contract ' + contract );
                System.debug(cpf);
                if(contract.data != null && contract.data.contracts != null && contract.data.contracts.size() > 0 &&  contract.data.contracts[0].cpfcnpj != cpf){
                    legacyProtocol.error = new CEC_RestObjects.Error();
                    legacyProtocol.error.message = 'Unprocessable Entity';
                    legacyProtocol.error.detailedMessage = 
                        'Protocolo não pertence ao cliente';
                    legacyProtocol.error.httpCode = '422';
                    legacyProtocol.data = null;
                    return legacyProtocol;
                }

            }
            
            Attendences consideredAtt = getOccurrenceNETSMS(objProtocol);

            String[] dateTimeSplit = consideredAtt.solicitationDateOpening.split('T');
            String[] dateSplit = dateTimeSplit[0].split('-');

            Date openingDate = Date.newInstance(Integer.valueOf(dateSplit[0]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[2]));

            Date today = Date.today();
            Integer daysOpened = openingDate.daysBetween(today);
            if(consideredAtt.solicitationStatus == 'ABERTA'){
                legacyProtocol.data.status = 'ABERTO';
                if(daysOpened > 5){
                    legacyProtocol.eligibility = OK;
                }else {
                    legacyProtocol.eligibility = DENTRO_PRAZO;
                }
            } else {
                legacyProtocol.data.status = 'RESOLVIDO';
                if(daysOpened > 180){
                    legacyProtocol.eligibility = MAIOR_180;
                }else {
                    legacyProtocol.eligibility = OK;
                }
            }

            System.debug('NETSMS RESPONSE');
            // Para NETSMS:
            legacyProtocol.data.protocolNumber = consideredAtt.protocolNumber;
            
            legacyProtocol.data.interactionOpeningDate = consideredAtt.solicitationDateOpening;
            legacyProtocol.data.interactionClosingDate = consideredAtt.solicitationDateClosing;
            legacyProtocol.data.interactionNumber = consideredAtt.interactionNumber;
            legacyProtocol.legacyData = objProtocol.data;
            legacyProtocol.data.legacy = 'NETSMS';
        } else {
            legacyProtocol.data = null;
            if(objProtocol != null && objProtocol.error != null){
                legacyProtocol.error = objProtocol.error;
            }
            else{
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message = 'Erro desconhecido';
                legacyProtocol.error.httpCode = '500';
            }
        }
        return legacyProtocol;
    }

    /**
     * Obtem a ocorrência a ser considerada no caso do NETSMS
     */
    private static Attendences getOccurrenceNETSMS(LegacyProtocol objProtocols) {
        // Se existir alguma ocorrência aberta, buscar a mais recente.
        // Se todas foram fechadas, a mais antiga é considerada.
        Attendences consideredAtt = null;
        Attendences mostRecentOpenAtt = null;
        Attendences oldestClosedAtt = null;

        String mostRecentOpenDateStr = null;
        String oldestClosedDateStr = null;

        for (Attendences att : objProtocols.data.attendances) {
            if(att.solicitationStatus == 'ABERTA'){ 
                if(mostRecentOpenDateStr == null || att.solicitationDateOpening > mostRecentOpenDateStr){
                    mostRecentOpenDateStr = att.solicitationDateOpening;
                    mostRecentOpenAtt = att;
                }
            }
            else {
                if(oldestClosedDateStr == null || att.solicitationDateOpening < oldestClosedDateStr){
                    oldestClosedDateStr = att.solicitationDateOpening;
                    oldestClosedAtt = att;
                }
            }
        }
        if(mostRecentOpenAtt != null){
            consideredAtt = mostRecentOpenAtt;
        } else {
            consideredAtt = oldestClosedAtt;
        }
        return consideredAtt;
    }

    /**
     * Busca o protocolo no PS8
     */
    private static CEC_CC_LegacyProtocolResponse getPS8Protocol(String protocol, String cpf, Asset[] assetMovel){
        // Preparar a Request para chamar o interactions
        CEC_CC_LegacyProtocolResponse legacyProtocol = new CEC_CC_LegacyProtocolResponse();
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();

        // Tentar chamar primeiro para o móvel (PS8)
        String endpoint =
            'callout:OAGClaro/interactions?protocolNumber=' +
            protocol +
            '&companyId=Movel';
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(120000);

        // Fazendo a chamada:
        HTTPResponse response = null;
        response = CEC_HttpReq.sendReq(request, null);
        String responseBody = response.getBody();
        
        LegacyProtocol objProtocols = (LegacyProtocol) JSON.deserialize(
            responseBody,
            LegacyProtocol.class
        );
        system.debug('ObjProtocols ' + objProtocols);
        if (
            objProtocols.error == null &&
            objProtocols.data != null &&
            objProtocols.data.attendances != null &&
            objProtocols.data.attendances.size() > 0
        ) {
            System.debug('ENCONTROU PS8 ' + objProtocols);
            Attendences ultimaAtt = getLastAttendancePS8(objProtocols);
            // objProtocols.data.attendances = new List<Attendences>{ ultimaAtt };

            if(!String.isBlank(cpf)){
                // Para PS8: Pegar o MSISDN do attendance e verificar se o MSISDN está em algum asset do cliente
                Boolean protMsisdnValid = false;
                for (Asset clientAsset : assetMovel) {
                    if (clientAsset.MSISDN__c == ultimaAtt.msisdn) {
                        protMsisdnValid = true;
                        break;
                    }
                }
                if (!protMsisdnValid) {
                    System.debug(
                        'MSISDN NÃO BATE COM O CLIENTE: ' + ultimaAtt.msisdn
                    );
                    legacyProtocol.error = new CEC_RestObjects.Error();
                    legacyProtocol.error.message = 'Unprocessable Entity';
                    legacyProtocol.error.detailedMessage = 
                        'Protocolo não pertence ao cliente';
                    legacyProtocol.error.httpCode = '422';
                    legacyProtocol.data = null;
                    return legacyProtocol;
                }
            }
            System.debug('MSISDN OK');
            legacyProtocol.data.interactionOpeningDate = ultimaAtt.solicitationDateOpening;
            legacyProtocol.data.interactionClosingDate = ultimaAtt.solicitationDateClosing;
            legacyProtocol.data.protocolNumber = ultimaAtt.protocolNumber;
            
            legacyProtocol.data.legacy = 'PS8';
            legacyProtocol.legacyData = objProtocols.data;
            legacyProtocol.data.status = ultimaAtt.situation;

            String[] dateTimeSplit = legacyProtocol.data.interactionOpeningDate.split('T');
            String[] dateSplit = dateTimeSplit[0].split('-');
            String[] hourSplit = dateTimeSplit[0].split(':');

            Date openingDate = Date.newInstance(Integer.valueOf(dateSplit[0]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[2]));
            Date today = Date.today();
            Integer daysOpened = openingDate.daysBetween(today);

            if(ultimaAtt.situation == 'ABERTO' || ultimaAtt.situation == 'PENDENTE'){
                legacyProtocol.data.status = 'ABERTO';
                if(daysOpened > 5) {
                    legacyProtocol.eligibility = OK;
                }else {
                    legacyProtocol.eligibility = DENTRO_PRAZO;
                }
            } else if(ultimaAtt.situation == 'PROCEDENTE' || ultimaAtt.situation == 'IMPROCEDENTE') {
                legacyProtocol.data.status = 'CONCLUÍDO';
                if(daysOpened > 180) {
                    legacyProtocol.eligibility = MAIOR_180;
                }else {
                    legacyProtocol.eligibility = OK;
                }
            }
            System.debug(legacyProtocol);
           
        } else {
            legacyProtocol.data = null;
            if(objProtocols.error != null){
                legacyProtocol.error = objProtocols.error;
            }
            else{
                legacyProtocol.error = new CEC_RestObjects.Error();
                legacyProtocol.error.message = 'Erro desconhecido';
                legacyProtocol.error.httpCode = '500';
            }
        }
        return legacyProtocol;
    }

    /**
     * Obtêm a ocorrência a ser considerada no caso do PS8
     * Com base no interactionSequenceId
     * @param objProtocols O protocolo PS8
     */
    private static Attendences getLastAttendancePS8(LegacyProtocol objProtocols) {
        // Retornar apenas o última attendance, com base no interactionSequenceId
        Integer maiorOrdem = 0;
        Attendences ultimaAtt = null;
        for (Attendences att : objProtocols.data.attendances) {
            if (
                att.interactionSequenceId != null &&
                Integer.valueOf(att.interactionSequenceId) > maiorOrdem
            ) {
                //PS8 / PEOPLESOFT
                maiorOrdem = Integer.valueOf(att.interactionSequenceId);
                ultimaAtt = att;
                continue;
            }
        }
        return ultimaAtt;
    }
    
    /**
     * Objetos usados para estruturar o retorno do protocolo dos legados
     */
    global class LegacyProtocol {
        public String apiVersion;
        public String transactionId;
        public DataProtocols data;
        public CEC_RestObjects.Error error;
    }
    global class DataProtocols extends CEC_CC_LegacyProtocolResponse.LegacyProtocolRawData  {
        public List<Attendences> attendances;
    }

    global class Attendences {
        public string order;
        public string protocolNumber;
        public string interactionNumber;
        public string action;
        public string solicitationType;
        public string solicitationDateOpening;
        public string solicitationDateClosing;
        public string solicitationStatus;
        public string channelRequestId;
        public string contactName;
        public String situation;
        public String reasonCode1;
        public String reasonCode2;
        public String reasonCode3;
        public String reasonCode4;
        public String description;
        public String slaIndicatorExceeded;
        public String reclassificationIndicator;
        public String synthesisRanking;
        public String interactionSequenceId;
        public String msisdn;
    }

    global class CustomerContractProtocol {
        public String apiVersion;
        public String transactionId;
        public CustomerContracts data;
        public CEC_RestObjects.Error error;
    }
    private class CustomerContracts{
        public CustomerContractData[] contracts;
    }
    private class CustomerContractData{
        public String cpfcnpj;
        public String docType;
        public String firstName;
        public String lastName;
        public String creationDate;
        public String operatorCode;
        public String customerAccountId;
    }
}