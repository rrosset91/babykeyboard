/*
* Autor: Marcos Aurelio - Deloitte
* Data: 27/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 8]
Mock utilizado pela classe de teste PME_ValidateCNPJ_Test.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: João Rodrigues
* Data: 02/06/2020
* Alterações: Mocks específicos para testes da PME_ValidateCNPJ_Test
*/
@isTest
public class CEC_PME_MobileCorporateCustomer_Mock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = '{}';
        if (req.getEndpoint().contains('05438120000199')) {
            body = '{ "apiVersion" : "1;2019-02-20", "transactionId" : "Id-ebb5d65e37ef3f6ca696c321", "data" : { "mobileCustomers" : { "acrmClientId" : "A8902", "personType" : "PJ", "segmentations" : [ { "segmentationType" : "VALOR_CLIENTE", "segmentationValue" : "CE" }, { "segmentationType" : "ACRM_SEGMENTACAO_ACCOUNT", "segmentationValue" : "PME" } ], "socialName" : "TEF AUTOMACAO COMERCIAL LTDA", "tradingName" : "MAQPLAN", "documentNumberCNPJ" : "05438120000199", "stateSubscription" : "0744099500104", "citySubscription" : null, "contacts" : [ { "acrmContactId" : null, "name" : "THIAGO OLIVEIRA", "phoneLineNumber" : "21990326563", "extension" : null, "email" : "thiago@claro.com.br", "cpf" : "32771393875", "contactType" : "Primary" } ], "partnerParticipation" : [ { "partnerCpf" : "false", "partnerCnpj" : "05438120000199", "partnerSince" : "2018-06-05" } ], "numberOfEmployees" : null, "revenues" : "200000.0", "billingPeriod" : "12", "legalPersonType" : "EMPRESA_PRIVADA", "privateBusinessClass" : null, "fundoPobrezaContributorIndicator" : "false", "fomeZeroContributorIndicator" : "false", "suframa" : null, "primaryCnae" : "4751201", "secondaryCnae" : null, "specialTaxStatusPrivateCompany" : [ { "microEnterpriseIndicator" : "false", "smallBusinessIndicator" : "false", "federalSimpleIndicator" : "false", "specialRegimeIndicator" : "false", "liminarIndicator" : "false" } ], "businessReferences" : [ ], "addresses" : [ { "addressFunction" : "PRINCIPAL", "StreetType" : "Q", "streetName" : "SHCGN 709 BLOCO A", "streetNumber" : "SN", "complement" : "LOJA 09", "neighborhood" : "ASA NORTE", "mailbox" : null, "city" : "BRASILIA", "state" : "DF", "zipCode" : "70750701" } ], "registrationDate" : "2018-06-05T14:39:58.000-03:00", "acrmdata.mobileCustomerStatus" : "0", "territoryName" : "Regional CO/NO", "specialTaxStatusPublicCompany" : [ { "retentionIndicator" : "false", "immunityIndicator" : "false", "exemptionIndicator" : "false" } ] } } }';
        } else {
            body = '{"error":{"message":"message","httpCode":"httpcode","errorCode":"errorCode","detailedMessage":"detailedMessage"},"data":{"mobileCustomers":{"documentNumberCNPJ":"CNPJ_CPC"}}}';
        }
        
        
        res.setBody(body);
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
}