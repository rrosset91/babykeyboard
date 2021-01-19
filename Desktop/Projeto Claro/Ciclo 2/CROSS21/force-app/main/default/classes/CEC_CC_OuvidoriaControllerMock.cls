/**
 * ---------------------------------------------------------------
 * Data: 28/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions
 * Descrição: Classe que reúno os mocks de teste de Ouvidoria
 * ---------------------------------------------------------------
 */
global with sharing class CEC_CC_OuvidoriaControllerMock {
   
    global class CEC_PS8_Within180Days_Mock implements HttpCalloutMock 
    {//MOCK COM DATA ABAIXO DE 180 DIAS E ACIMA DE 5 DIAS
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            
            //CRIANDO DIA MINIMO PARA TESTE (180 DIAS ANTES DA DATA ATUAL) NO FORMATO SOLICITADO
            Datetime timeofTest=Datetime.now().addDays(-180);
            String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');


            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "1;2019-08-28",' +
                '"transactionId": "Id-ca1a7e5f7b8f0c1d7b452e38",' +
                    '"data": {' +
                        
                        '"attendances":[{'+

                        '"interactionSequenceId": "1",' +
                        '"solicitationDateOpening":"'+ timeString +'",'+
                        '"interactionModificationDate": "2020-02-21T10:49:58.000-03:00",' +
                        '"solicitationDateClosing":"'+ timeString +'",'+
                        '"protocolNumber": "202023084",' +
                        '"contactName": "1SARA SOPHIE DA CONCEIÇÃO",' +
                        '"msisdn": "11940564346",' +
                        '"channelRequestId": "URA",' +
                        '"situation": "PROCEDENTE",' +
                        '"slaIndicatorExceeded": "false",' +
                        '"reasonDescription1": "Procedimento Interno",' +
                        '"reasonDescription2": "Claro Conta",' +
                        '"reasonCode3": "CEC",' +
                        '"reasonDescription3": "CEC",' +
                        '"reasonCode4": "Canais Críticos",' +
                        '"reasonDescription4": "Canais Críticos",' +
                        '"description": "",' +
                        '"closedSituationIndicator": "true",' +
                        '"memo": "Caso inserido para o canal Anatel via Site Anatel\\n\\nDescrição: descriçao.\\n\\nResolução: resolução.",' +
                        '"contactReturnType": "TELEFONE",' +
                        '"name": "Breno Eduardo",' +
                        '"address": "null"' +

                        
                        '}]'+
                        
                    '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    

    global class CEC_PS8_Within5Days_Mock implements HttpCalloutMock 
    {//MOCK COM DATA ABAIXO DE 5 DIAS
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            
            
            Datetime timeofTest=Datetime.now().addDays(-3);
            String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');


            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "1;2019-08-28",' +
                '"transactionId": "Id-ca1a7e5f7b8f0c1d7b452e38",' +
                    '"data": {' +
                        
                        '"attendances":[{'+

                        '"interactionSequenceId": "1",' +
                        '"solicitationDateOpening":"'+ timeString +'",'+
                        '"interactionModificationDate": "2020-02-21T10:49:58.000-03:00",' +
                        '"solicitationDateClosing":"'+ timeString +'",'+
                        '"protocolNumber": "202023084",' +
                        '"contactName": "1SARA SOPHIE DA CONCEIÇÃO",' +
                        '"msisdn": "11940564346",' +
                        '"channelRequestId": "URA",' +
                        '"situation": "ABERTO",' +
                        '"slaIndicatorExceeded": "false",' +
                        '"reasonDescription1": "Procedimento Interno",' +
                        '"reasonDescription2": "Claro Conta",' +
                        '"reasonCode3": "CEC",' +
                        '"reasonDescription3": "CEC",' +
                        '"reasonCode4": "Canais Críticos",' +
                        '"reasonDescription4": "Canais Críticos",' +
                        '"description": "",' +
                        '"closedSituationIndicator": "true",' +
                        '"memo": "Caso inserido para o canal Anatel via Site Anatel\\n\\nDescrição: descriçao.\\n\\nResolução: resolução.",' +
                        '"contactReturnType": "TELEFONE",' +
                        '"name": "Breno Eduardo",' +
                        '"address": "null"' +

                        
                        '}]'+
                        
                    '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    global class CEC_PS8_OpenMoreThan5Days_Mock implements HttpCalloutMock 
    {//MOCK COM DATA ABAIXO DE 5 DIAS
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            
            
            Datetime timeofTest=Datetime.now().addDays(-6);
            String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');


            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "1;2019-08-28",' +
                '"transactionId": "Id-ca1a7e5f7b8f0c1d7b452e38",' +
                    '"data": {' +
                        
                        '"attendances":[{'+

                        '"interactionSequenceId": "1",' +
                        '"solicitationDateOpening":"'+ timeString +'",'+
                        '"interactionModificationDate": "2020-02-21T10:49:58.000-03:00",' +
                        '"solicitationDateClosing":"'+ timeString +'",'+
                        '"protocolNumber": "202023084",' +
                        '"contactName": "1SARA SOPHIE DA CONCEIÇÃO",' +
                        '"msisdn": "11940564346",' +
                        '"channelRequestId": "URA",' +
                        '"situation": "PENDENTE",' +
                        '"slaIndicatorExceeded": "false",' +
                        '"reasonDescription1": "Procedimento Interno",' +
                        '"reasonDescription2": "Claro Conta",' +
                        '"reasonCode3": "CEC",' +
                        '"reasonDescription3": "CEC",' +
                        '"reasonCode4": "Canais Críticos",' +
                        '"reasonDescription4": "Canais Críticos",' +
                        '"description": "",' +
                        '"closedSituationIndicator": "true",' +
                        '"memo": "Caso inserido para o canal Anatel via Site Anatel\\n\\nDescrição: descriçao.\\n\\nResolução: resolução.",' +
                        '"contactReturnType": "TELEFONE",' +
                        '"name": "Breno Eduardo",' +
                        '"address": "null"' +

                        
                        '}]'+
                        
                    '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    global class CEC_PS8_ClosedMoreThan180Days_Mock implements HttpCalloutMock 
    {//MOCK COM DATA ACIMA DE 180 DIAS

        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            
            
            Datetime timeofTest=Datetime.now().addDays(-181);
            String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');


            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "1;2019-08-28",' +
                '"transactionId": "Id-ca1a7e5f7b8f0c1d7b452e38",' +
                    '"data": {' +
                        
                        '"attendances":[{'+

                        '"interactionSequenceId": "1",' +
                        '"solicitationDateOpening":"'+ timeString +'",'+
                        '"interactionModificationDate": "2020-02-21T10:49:58.000-03:00",' +
                        '"solicitationDateClosing":"'+ timeString +'",'+
                        '"protocolNumber": "202023084",' +
                        '"contactName": "1SARA SOPHIE DA CONCEIÇÃO",' +
                        '"msisdn": "11940564346",' +
                        '"channelRequestId": "URA",' +
                        '"situation": "PROCEDENTE",' +
                        '"slaIndicatorExceeded": "false",' +
                        '"reasonDescription1": "Procedimento Interno",' +
                        '"reasonDescription2": "Claro Conta",' +
                        '"reasonCode3": "CEC",' +
                        '"reasonDescription3": "CEC",' +
                        '"reasonCode4": "Canais Críticos",' +
                        '"reasonDescription4": "Canais Críticos",' +
                        '"description": "",' +
                        '"closedSituationIndicator": "true",' +
                        '"memo": "Caso inserido para o canal Anatel via Site Anatel\\n\\nDescrição: descriçao.\\n\\nResolução: resolução.",' +
                        '"contactReturnType": "TELEFONE",' +
                        '"name": "Breno Eduardo",' +
                        '"address": "null"' +

                        
                        '}]'+
                        
                    '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    global class CEC_PS8_TestInvalidProtocol implements HttpCalloutMock 
    {//MOCK COM protocolo invalido
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            


            res.setHeader('Content-Type', 'application/json');
            res.setBody(
               

                '{'+ 
                    '"apiVersion" : "1;2019-08-28",'+ 
                    '"transactionId" : "Id-ec8f775f5c530f7a5ed3bf65",' +
                    '"error" : {' + 
                    '"httpCode" : "422",' +
                    '"errorCode" : "API-INTERACTIONS-010", '+
                    '"message" : "Unprocessable Entity", '+
                    '"detailedMessage" : "Atendimento nao encontrado para os parametros: protocolo =202033684 - Verifique se o codigo de identificação do atentimento esta correto.",'+ 
                    '"link" : {'+ 
                    '"rel" : "related",'+ 
                    '"href" : "https://oag.claro.com.br/docs/error_codes.html" '+
                    '} '+
                   ' } '+
                    '} '
            );
            res.setStatusCode(422);
            return res;
        }
    }
                                                            //MOCK NETSMS

    global class NETSMS_ClosedMoreThan180Days_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            Datetime agora = Datetime.now();
            DateTime dt1 = agora.addDays(-181);
            Datetime dt2 = agora.addDays(-50);
            // Data de 181 dias atras
            String dateString = dt1.format('yyyy-MM-dd\'T\'hh:mm:ss');
            // Data de 50 dias atras
            String date2String = dt2.format('yyyy-MM-dd\'T\'hh:mm:ss');
            
            res.setHeader('Content-Type', 'application/json');
            String reqBody = null;
            if(req.getEndpoint().contains('operatorCode')){
                //Chamada ao NETSMS
                // retorna com sucesso um protocolo com várias interações
                // Como são todos Fechados, apenas o mais antigo é considerando,
                // entrando para a regra dos 180 dias
                reqBody = '{ '+
                '"apiVersion" : "1;2018-09-20",' +
                '"transactionId" : "Id-ad7d775fc7ed62f41cb53df6",' +
                '"data" : { '+
                '"attendances" : [ '+
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483462",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + dateString+ '",' +
                '"solicitationDateClosing" : "' + dateString+ '",' +
                '"solicitationStatus" : "RESOLVIDA" ' +
                '},' +
                '{ ' +
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483463",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "RESOLVIDA" '+ 
                '},' +
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483465",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "RESOLVIDA" '+
                '}, { ' +
                '"order" : "1",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "C",' +
                '"solicitationType" : "REGISTRO SISTEMICO",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "EXECUTADA" ' +
                '} ]' +
                '} }';
            }
            res.setBody(reqBody);
            res.setStatusCode(200);
            return res;
        }
    }

    global class NETSMS_ClosedWithin180Days_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            Datetime agora = Datetime.now();
            DateTime dt1 = agora.addDays(-50);
            Datetime dt2 = agora.addDays(-30);
            Datetime dt3 = agora.addDays(-2);
            // Data de 50 dias atras
            String dateString = dt1.format('yyyy-MM-dd\'T\'hh:mm:ss');
            // Data de 30 dias atras
            String date2String = dt2.format('yyyy-MM-dd\'T\'hh:mm:ss');
            // Data de 3 dias atras
            String date3String = dt3.format('yyyy-MM-dd\'T\'hh:mm:ss');
            
            res.setHeader('Content-Type', 'application/json');
            String reqBody = null;

            if(req.getEndpoint().contains('operatorCode')){
                //Chamada ao NETSMS
                // retorna com sucesso um protocolo com várias interações
                // Como são todos Fechados, apenas o mais antigo é considerando,
                // entrando para a regra dos 180 dias
                reqBody = '{ '+
                '"apiVersion" : "1;2018-09-20",' +
                '"transactionId" : "Id-ad7d775fc7ed62f41cb53df6",' +
                '"data" : { '+
                '"attendances" : [ '+
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665295",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483462",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + dateString+ '",' +
                '"solicitationDateClosing" : "' + dateString+ '",' +
                '"solicitationStatus" : "RESOLVIDA" ' +
                '},' +
                '{ ' +
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665296",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483463",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "RESOLVIDA" '+ 
                '},' +
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665297",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483465",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "RESOLVIDA" '+
                '}, { ' +
                '"order" : "1",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "C",' +
                '"solicitationType" : "REGISTRO SISTEMICO",' +
                '"solicitationDateOpening" : "' + date3String+ '",' +
                '"solicitationDateClosing" : "' + date3String+ '",' +
                '"solicitationStatus" : "EXECUTADA" ' +
                '} ]' +
                '} }';
            }
            res.setBody(reqBody);
            res.setStatusCode(200);
            return res;
        }
    }

    global class NETSMS_OpenWithin5Days_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            Datetime agora = Datetime.now();
            DateTime dt1 = agora.addDays(-2);
            Datetime dt2 = agora.addDays(-30);
            Datetime dt3 = agora.addDays(-50);
            // Data de 50 dias atras
            String dateString = dt1.format('yyyy-MM-dd\'T\'hh:mm:ss');
            // Data de 30 dias atras
            String date2String = dt2.format('yyyy-MM-dd\'T\'hh:mm:ss');
            // Data de 3 dias atras
            String date3String = dt3.format('yyyy-MM-dd\'T\'hh:mm:ss');
            
            res.setHeader('Content-Type', 'application/json');
            String reqBody = null;

            if(req.getEndpoint().contains('operatorCode')){
                //Chamada ao NETSMS
                // retorna com sucesso um protocolo com várias interações
                // Como são todos Fechados, apenas o mais antigo é considerando,
                // entrando para a regra dos 180 dias
                reqBody = '{ '+
                '"apiVersion" : "1;2018-09-20",' +
                '"transactionId" : "Id-ad7d775fc7ed62f41cb53df6",' +
                '"data" : { '+
                '"attendances" : [ '+
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483462",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + dateString+ '",' +
                '"solicitationDateClosing" : "' + dateString+ '",' +
                '"solicitationStatus" : "ABERTA" ' +
                '},' +
                '{ ' +
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483463",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "RESOLVIDA" '+ 
                '},' +
                '{ '+
                '"order" : "2",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "O",' +
                '"occurrenceId" : "861483465",' +
                '"solicitationType" : "OUVIDORIA",' +
                '"solicitationDateOpening" : "' + date2String+ '",' +
                '"solicitationDateClosing" : "' + date2String+ '",' +
                '"solicitationStatus" : "ABERTA" '+
                '}, { ' +
                '"order" : "1",' +
                '"protocolNumber" : "040203852518986",' +
                '"interactionNumber" : "406665298",' +
                '"action" : "C",' +
                '"solicitationType" : "REGISTRO SISTEMICO",' +
                '"solicitationDateOpening" : "' + date3String+ '",' +
                '"solicitationDateClosing" : "' + date3String+ '",' +
                '"solicitationStatus" : "EXECUTADA" ' +
                '} ]' +
                '} }';
            }
            res.setBody(reqBody);
            res.setStatusCode(200);
            return res;
        }
    }


    global class NETSMSOpenMoreThan5DaysMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            Datetime agora = Datetime.now();
                DateTime dt1 = agora.addDays(-6);
                Datetime dt2 = agora.addDays(-50);
                // Data de 181 dias atras
                String dateString = dt1.format('yyyy-MM-dd\'T\'hh:mm:ss');
                // Data de 50 dias atras
                String date2String = dt2.format('yyyy-MM-dd\'T\'hh:mm:ss');
                String reqBody = null;
                if(req.getEndpoint().contains('operatorCode')){
                    reqBody = '{ '+
                    '"apiVersion" : "1;2018-09-20",' +
                    '"transactionId" : "Id-ad7d775fc7ed62f41cb53df6",' +
                    '"data" : { '+
                    '"attendances" : [ '+
                    '{ '+
                    '"order" : "2",' +
                    '"protocolNumber" : "040203852518986",' +
                    '"interactionNumber" : "406665295",' +
                    '"action" : "O",' +
                    '"occurrenceId" : "861483462",' +
                    '"solicitationType" : "OUVIDORIA",' +
                    '"solicitationDateOpening" : "' + dateString+ '",' +
                    '"solicitationDateClosing" : "' + dateString+ '",' +
                    '"solicitationStatus" : "ABERTA" ' +
                    '},' +
                    '{ ' +
                    '"order" : "2",' +
                    '"protocolNumber" : "040203852518986",' +
                    '"interactionNumber" : "406665296",' +
                    '"action" : "O",' +
                    '"occurrenceId" : "861483463",' +
                    '"solicitationType" : "OUVIDORIA",' +
                    '"solicitationDateOpening" : "' + date2String+ '",' +
                    '"solicitationDateClosing" : "' + date2String+ '",' +
                    '"solicitationStatus" : "ABERTA" '+ 
                    '},' +
                    '{ '+
                    '"order" : "2",' +
                    '"protocolNumber" : "040203852518986",' +
                    '"interactionNumber" : "406665297",' +
                    '"action" : "O",' +
                    '"occurrenceId" : "861483465",' +
                    '"solicitationType" : "OUVIDORIA",' +
                    '"solicitationDateOpening" : "' + date2String+ '",' +
                    '"solicitationDateClosing" : "' + date2String+ '",' +
                    '"solicitationStatus" : "RESOLVIDA" '+
                    '}, { ' +
                    '"order" : "1",' +
                    '"protocolNumber" : "040203852518986",' +
                    '"interactionNumber" : "406665298",' +
                    '"action" : "C",' +
                    '"solicitationType" : "REGISTRO SISTEMICO",' +
                    '"solicitationDateOpening" : "' + dateString+ '",' +
                    '"solicitationDateClosing" : "' + dateString+ '",' +
                    '"solicitationStatus" : "EXECUTADA" ' +
                    '} ]' +
                    '} }';
                }

                res.setBody(reqBody);
                res.setStatusCode(200);
                return res;
            
        }
    }
    global class CEC_PSAC_LessThan180Days_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('EMBRATEL')){
            
                Datetime timeofTest=Datetime.now().addDays(-179);
                String timeString = timeofTest.formatGmt('dd/MM/yyyyHH:mm:ss');
    
    
                res.setHeader('Content-Type', 'application/json');
                res.setBody(
                    '{' +
                        '"apiVersion": "1;2020-08-20",'+
                        '"transactionId": "c5ae9c1f-cbf7-4c4f-b583-42dc7beac1e1",'+
                        '"data": {'+
                            '"attendances": {'+
                                '"documentNumber" : "42737230668",' +
                                '"solicitationOpeningDate" : "'+ timeString +'",' +
                                '"solicitationDateClosing" : "'+ timeString +'",' +
                                '"productDescription" : "21",' +
                                '"categoryDescription" : "PRODUTOS/SERVIÇOS",' +
                                '"solicitationType" : "CANCELAMENTO DESATIVAÇÃO",' +
                                '"subCategoryDescription" : "CLIENTE NÃO RETIDO",' +
                                '"categoryId": "95",'+
                                '"processId": "3",'+
                                '"productId": "6",'+
                                '"subCategoryID": "495",'+
                                '"message" : "",' +
                                '"interactionNumber" : "20202323213",' +
                                '"msisdn" : "6999998888",' +
                                '"status" : "C"}' +
                        '}'+
                    '}'
                );
                res.setStatusCode(201); //
                return res;
            }else{
                return (new CEC_PS8_TestInvalidProtocol()).respond(req);
            }
        }
    }

    
    global class CEC_PSAC_MoreThan180Days_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('EMBRATEL')){
            
                Datetime timeofTest=Datetime.now().addDays(-181);
                String timeString = timeofTest.formatGmt('dd/MM/yyyyHH:mm:ss');
    
    
                res.setHeader('Content-Type', 'application/json');
                res.setBody(
                    '{' +
                        '"apiVersion": "1;2020-08-20",'+
                        '"transactionId": "c5ae9c1f-cbf7-4c4f-b583-42dc7beac1e1",'+
                        '"data": {'+
                            '"attendances": {'+
                                '"documentNumber" : "42737230668",' +
                                '"solicitationOpeningDate" : "'+ timeString +'",' +
                                '"solicitationDateClosing" : "'+ timeString +'",' +
                                '"productDescription" : "21",' +
                                '"categoryDescription" : "PRODUTOS/SERVIÇOS",' +
                                '"solicitationType" : "CANCELAMENTO DESATIVAÇÃO",' +
                                '"subCategoryDescription" : "CLIENTE NÃO RETIDO",' +
                                '"categoryId": "95",'+
                                '"processId": "3",'+
                                '"productId": "6",'+
                                '"subCategoryID": "495",'+
                                '"message" : "",' +
                                '"interactionNumber" : "20202323213",' +
                                '"msisdn" : "6999998888",' +
                                '"status" : "C"}' +
                        '}'+
                    '}'
                );
                res.setStatusCode(200);
                return res;
            }else{
                return (new CEC_PS8_TestInvalidProtocol()).respond(req);
            }
        }
    }//*/
    
    global class CEC_PSAC_NotFound_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('EMBRATEL')){            
                Datetime timeofTest=Datetime.now().addDays(-181);
                String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');

                res.setHeader('Content-Type', 'application/json');
                res.setBody(
                 '{'+ 
                    '"apiVersion" : "1;2019-08-28",'+ 
                    '"transactionId" : "Id-ec8f775f5c530f7a5ed3bf65",' +
                    '"error" : {' + 
                    '"httpCode" : "422",' +
                    '"errorCode" : "API-INTERACTIONS-010", '+
                    '"message" : "Unprocessable Entity", '+
                    '"detailedMessage" : "Atendimento nao encontrado para os parametros: protocolo =202033684 - Verifique se o codigo de identificação do atentimento esta correto.",'+ 
                    '"link" : {'+ 
                    '"rel" : "related",'+ 
                    '"href" : "https://oag.claro.com.br/docs/error_codes.html" '+
                    '} '+
                   ' } '+
                    '} '
                );
                res.setStatusCode(422);
                return res;
            }else{
                return (new CEC_PS8_TestInvalidProtocol()).respond(req);
            }
        }
    }
    
        global class CEC_PSAC_NotFound2_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {// faz o call do respond do mock configurado ao inves da API diretamente
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('EMBRATEL')){            
                Datetime timeofTest=Datetime.now().addDays(-181);
                String timeString = timeofTest.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');

                res.setHeader('Content-Type', 'application/json');
                res.setBody(
                    '{' +
                        '"apiVersion": "1;2020-08-20",'+
                        '"transactionId": "c5ae9c1f-cbf7-4c4f-b583-42dc7beac1e1",'+
                        '"data": {'+
                            '"attendances": {'+
                                '"solicitationOpeningDate" : null,' +
                                '"solicitationDateClosing" : null' +
                                '}' +
                        '}'+
                    '}'
                );
                res.setStatusCode(422);
                return res;
            }else{
                return (new CEC_PS8_TestInvalidProtocol()).respond(req);
            }
        }
    }

    /**
     * Mock de retorno na customercontracts (informações do cliente dado um protocolo)
     */
    global class CEC_CustomerContract_Mock implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            System.debug('ENDPOINT >> ' + req.getEndpoint());
            Boolean IsRequestContract = req.getEndpoint().contains('customercontracts');
            System.debug(IsRequestContract);
            if(IsRequestContract){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(
                    '{' +
                    '"apiVersion" : "1;2018-12-17",' +
                    '"transactionId" : "Id-64178f5f4736d089aecb2be8",' +
                    '"data" : {'+
                    '"contracts" : [ {'+
                        '"cpfcnpj" : "42737230268",' +
                        '"docType" : "CPF",' +
                        '"firstName" : "MARINEIDE",' +
                        '"lastName" : "PEREIRA SOUZA",' +
                        '"partyRoleId" : "6814745",' +
                        '"operatorCityCode" : "15890",' +
                        '"operatorCode" : "040",' +
                        '"operatorPartyId" : "002639",' +
                        '"customerAccountId" : "040049563690",' +
                        '"contractId" : "49563690",' +
                        '"creationDate" : "2018-11-19T00:00:00.000-02:00",' +
                        '"accountType" : "1",' +
                        '"statusCode" : "1",' +
                        '"status" : "CONECTADO",' +
                        '"financialStatus" : "INADIMPLENTE",' +
                        '"personTypeCode" : "1",' +
                        '"personType" : "FISICA",' +
                        '"segmentCode" : "5",' +
                        '"segment" : "SEM SEGMENTO",' +
                        '"birthDate" : "1972-11-08-03:00",' +
                        '"emailAddress" : "neidesouzanps@gmail.com",' +
                        '"paymentDayDue" : "10",' +
                        '"paymentMethodCode" : "1",' +
                        '"paymentMethod" : "BOLETO",' +
                        '"profileCode" : "460",' +
                        '"profileName" : "VIRTUA + FONE",' +
                        '"installAddressId" : "8265879",' +
                        '"postCode" : "72001880",' +
                        '"propertyHpId" : "841260515",' +
                        '"propertyCode" : "841260516",' +
                        '"networkNodeCode" : "CAS05",' +
                        '"isEncoded" : "false",' +
                        '"networkCellCode" : "CAS05_A",' +
                        '"isJuridicalSegment" : "false",' +
                        '"hasAnalogicalPayTV" : "true",' +
                        '"hasDigitalPayTV" : "false",' +
                        '"hasInternet" : "true",' +
                        '"hasNetFone" : "true",' +
                        '"hasCloud" : "false",' +
                        '"isAllowedPPVPurchase" : "false",' +
                        '"cdBase" : "BRA",' +
                        '"phones" : [ {'+
                        '"telephoneNumber" : "000000000",' +
                        '"areaCode" : "00",' +
                        '"contactMediumRole" : "Home Phone"'+
                        '}, {'+
                        '"telephoneNumber" : "981884359",' +
                        '"areaCode" : "61",' +
                        '"contactMediumRole" : "Mobile Phone"'+
                        '}, {'+
                        '"telephoneNumber" : "35415737",' +
                        '"areaCode" : "61",' +
                        '"contactMediumRole" : "VOIP"'+
                        '} ]'+
                    '} ]'+
                    '}'+
                    '}'
                );
            }else{
                // se não for customercontracts, usar os demais mocks do NETSMS
                res = new NETSMS_ClosedWithin180Days_Mock().respond(req);
            }
            res.setStatusCode(200);
            return res;
        
        }
    }
}