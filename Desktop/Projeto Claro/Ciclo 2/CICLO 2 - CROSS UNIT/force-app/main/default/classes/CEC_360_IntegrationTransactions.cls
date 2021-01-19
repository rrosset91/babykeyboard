/*
* Autor: Danilo Fucuhara (Deloitte)
* Data: XX/01/2019
* Descrição: [Claro Visão 360] [Time: SQUAD 360] Classe de conexão com a API de extratos, utilizada também para formatação de informações.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 06-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Refatorado os métodos de formatações de valor em um único e ajustado o método getTransactionsPeriod para diferentes cenários(com tipo e subtipo, sem subtipo...)
* ---------------------------------------------------------------
* Data: 15-02-2019  
* Autor: Danilo Fucuhara
* Alterações: Criado o método formatDuration para formatação de segundos para minutos:segundos com a conversão correta.
* ---------------------------------------------------------------
* Data: 25-03-2019  
* Autor: Danilo Fucuhara
* Alterações: Convertido para Named Credentials e ajustado para receber a config. personalizada service name.
*/

public class CEC_360_IntegrationTransactions {
    
    public static CEC_RestObjects.Transactions getTransactionsLast(String phoneLineNumber) { 
        CEC_RestObjects.Transactions transactions = new CEC_RestObjects.Transactions();
        
        try { 
            HTTPRequest request = new HTTPRequest();

            request.setEndpoint('callout:OAGClaro' + 
                                CEC_ServiceName__c.getValues('Transactions').ServiceName__c +
                                '?signatureType=' + 'CLARO_CARTAO' + 
                                '&phoneLineNumber=' + phoneLineNumber + 
                                '&eventsAmount=' + '30' + 
                                '&financialMovementEventIndicator=' + 'true' + 
                                '&pageSize=' + '30' + 
                                '&page=' + '1');
            
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody.replace('\n',''));
            
            transactions = (CEC_RestObjects.Transactions)JSON.deserialize(responseBody, CEC_RestObjects.Transactions.class);
            transactions = CEC_360_IntegrationTransactions.formatTransactions(transactions);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return transactions;
    }
    
    public static CEC_RestObjects.Transactions getTransactionsPeriod(String phoneLineNumber, String dateStart, String dateEnd, String tipo, String subTipo) { 
        CEC_RestObjects.Transactions transactions = new CEC_RestObjects.Transactions();
        
        try { 
            HTTPRequest request = new HTTPRequest();
            String endPoint;
            
            if(tipo != null && subTipo != null) {
                endPoint = 'callout:OAGClaro' + 
                    CEC_ServiceName__c.getValues('Transactions').ServiceName__c +
                    '?signatureType=' + 'CLARO_CARTAO' + 
                    '&phoneLineNumber=' + phoneLineNumber + 
                    '&eventCategoryDescription=' + tipo + 
                    '&eventSubCategoryDescription=' + subTipo + 
                    '&dateStart=' + dateStart + 
                    '&dateEnd=' + dateEnd +
                    '&pageSize=' + '500' +
                    '&page=' + '1';
            }
            
            if(tipo != null && subTipo == null) {
                endPoint = 'callout:OAGClaro' + 
					CEC_ServiceName__c.getValues('Transactions').ServiceName__c +
                    '?signatureType=' + 'CLARO_CARTAO' + 
                    '&phoneLineNumber=' + phoneLineNumber + 
                    '&eventCategoryDescription=' + tipo +
                    '&dateStart=' + dateStart + 
                    '&dateEnd=' + dateEnd +
                    '&pageSize=' + '500' +
                    '&page=' + '1';
            }
            
            if(tipo == null && subTipo == null) {
                endPoint = 'callout:OAGClaro' + 
					CEC_ServiceName__c.getValues('Transactions').ServiceName__c +
                    '?signatureType=' + 'CLARO_CARTAO' + 
                    '&phoneLineNumber=' + phoneLineNumber + 
                    '&dateStart=' + dateStart + 
                    '&dateEnd=' + dateEnd +
                    '&pageSize=' + '500' +
                    '&page=' + '1';
            }
            
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody.replace('\n',''));
            
            transactions = (CEC_RestObjects.Transactions)JSON.deserialize(responseBody, CEC_RestObjects.Transactions.class);
            transactions = CEC_360_IntegrationTransactions.formatTransactions(transactions);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return transactions;
    }
    
    public static CEC_RestObjects.Transactions formatTransactions(CEC_RestObjects.Transactions transactions) {
        if(transactions.data != null) {
            for(CEC_RestObjects.Events e : transactions.data.events) {
                e.expanded = false;
                if(!Test.isRunningTest()){
                    Datetime dt = (DateTime)JSON.deserialize('"' + e.eventDate + '"', DateTime.class);
                    String dateFormated = dt.format('dd/MM/yyyy HH:mm', 'America/Sao_Paulo');
                    e.eventDate = String.valueOf(dateFormated);
                }
                if(e.eventDuration != null) {
                    e.eventDuration = formatDuration(e.eventDuration);
                }
                
                e.eventAmount = formatValor(e.eventAmount);
                e.balancePrincipalBefore = formatValor(e.balancePrincipalBefore);
                e.balancePrincipalAfter = formatValor(e.balancePrincipalAfter);
                if(e.usagePromotionalBalances != null) {
                    for(CEC_RestObjects.PromotionalBalanceTransaction p : e.usagePromotionalBalances) {
                        p.balancePromotionalBefore = formatValor(p.balancePromotionalBefore);
                        p.balancePromotionalAfter = formatValor(p.balancePromotionalAfter);
                    }
                }
            }
        }
        return transactions;
    }

    public static String formatValor(String value) {
        value = 'R$' + value.replace('.', ',');
        if(value.substringAfter(',').length() < 2)
            value = value + '0';
        
        if(value.substringAfter(',').length() > 2)
            value = value.substringBefore(',') + ',' + value.substringAfter(',').substring(0, 2);
        return value;
    }
    
    public static String formatDuration(String duration) {
        Double minutes = math.floor(Integer.valueOf(duration) / 60);
        Double seconds = Integer.valueOf(duration) - minutes * 60;
        String minFinal;
        String secFinal;
        
        if(String.valueOf(Integer.valueOf(minutes)).length() < 2) {
            minFinal = '0' + String.valueOf(Integer.valueOf(minutes));
        } else {
            minFinal = String.valueOf(Integer.valueOf(minutes));
        }
        
        if(String.valueOf(Integer.valueOf(seconds)).length() < 2) {
            secFinal = '0' + String.valueOf(Integer.valueOf(seconds));
        } else {
            secFinal = String.valueOf(Integer.valueOf(seconds));
        }
        
        return minFinal + ':' + secFinal;
    }
    
    public static CEC_RestObjects.Transactions generateMock() { 
        CEC_RestObjects.Transactions transactions = new CEC_RestObjects.Transactions();
        
        transactions.data = new CEC_RestObjects.DataTransaction();
        transactions.data.events = new List<CEC_RestObjects.Events>();
        
        CEC_RestObjects.PromotionalBalanceTransaction promotionals = new CEC_RestObjects.PromotionalBalanceTransaction();
        promotionals.balancePromotionalBefore = '5.3';
        promotionals.balancePromotionalAfter = '5.0';
        
        CEC_RestObjects.Events events = new CEC_RestObjects.Events();
        events.eventId = '18120108151447182';
        events.eventDate = '2019-03-13T11:16:03.000-03:00';
        events.eventCategoryDescription = 'Plano 1';
        events.eventSubCategoryDescription = 'Plano 1';
        events.eventDescription = 'Plano 1';
        events.telephoneNumberOrigin = '0903525242';
        events.telephoneNumberDestiny = '0903525241';
        events.eventDuration = '112';
        events.eventAmount = '1.0';
        events.balancePrincipalBefore = '5.0000';
        events.balancePrincipalAfter = '4.1';
        events.areaOrigin = 'SP';
        events.areaDestiny = 'SP';
        events.usagePromotionalBalances = new List<CEC_RestObjects.PromotionalBalanceTransaction>();
        
        transactions.data.events.add(events);
        events.usagePromotionalBalances.add(promotionals);

        return transactions;
    }
}