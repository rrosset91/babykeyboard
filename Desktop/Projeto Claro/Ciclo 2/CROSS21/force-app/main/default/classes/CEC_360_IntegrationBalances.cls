/* Autor: Danilo Fucuhara - Deloitte 
Criação: 22/03/2019
Descrição:Classe de conexão com a API de Saldos. 
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.

* Controle de Versão
* ---------------------------------------------------------------
* Data: 25-03-2019  
* Autor: Leticia Freitas
* Alterações: Ajustar as chamadas da integração para credencial nominada. 
* ---------------------------------------------------------------
*/

public class CEC_360_IntegrationBalances { 
    
    public static CEC_RestObjects.BalancesMain getBalance(String phoneLineNumber) { 
        CEC_RestObjects.BalancesMain balances = new CEC_RestObjects.BalancesMain();
        
        String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('Balances');
        }else{
            service = '/balances';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:OAGClaro' + service + 
                                '?'+ 'phoneLineNumber='+ phoneLineNumber + '&retrieveAdditionalInformation=' + 'false');
            
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            balances = (CEC_RestObjects.BalancesMain)JSON.deserialize(responseBody, CEC_RestObjects.BalancesMain.class);
            
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return balances;
    }
    
    public static List<CEC_RestObjects.Accumulators> getOtherBalances(String phoneLineNumber) { 
        CEC_RestObjects.BalancesMain balancesObj = new CEC_RestObjects.BalancesMain();
        List<CEC_RestObjects.Accumulators> balancesAccumulators;
        String service;
        Boolean returnMock;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('Balances');
            returnMock = CEC_ServiceName__c.getValues('Balances').returnMock__c;
        }else{
            service = '/balances';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro' + service + 
                                '?'+'phoneLineNumber='+ phoneLineNumber + '&retrieveAdditionalInformation=' + 'true');
            system.debug('Endpoint'+request.getEndpoint());
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('ResponseBody'+responseBody);


            if(!Test.isRunningTest() && returnMock){
                balancesObj = (CEC_RestObjects.BalancesMain)JSON.deserialize(JSON.Serialize(generateMock()), CEC_RestObjects.BalancesMain.class);
                balancesAccumulators = balancesObj.data.balances.accumulators;
            }else{
                balancesObj = (CEC_RestObjects.BalancesMain)JSON.deserialize(responseBody, CEC_RestObjects.BalancesMain.class);
                balancesAccumulators = balancesObj.data.balances.accumulators;
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                }
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return balancesAccumulators;
    } 

    public static List<CEC_RestObjects.PromotionalBalances> getOtherBalancesPromotional(String phoneLineNumber) { 
        CEC_RestObjects.BalancesMain balancesObj = new CEC_RestObjects.BalancesMain();
        List<CEC_RestObjects.PromotionalBalances> balancesPromotional;
        
        String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('Balances');
        }else{
            service = '/balances';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro' +service+ 
                                '?'+ 'phoneLineNumber='+phoneLineNumber + '&retrieveAdditionalInformation=' + 'true');
            request.setMethod('GET');
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            balancesObj = (CEC_RestObjects.BalancesMain)JSON.deserialize(responseBody, CEC_RestObjects.BalancesMain.class);
            balancesPromotional= balancesObj.data.balances.promotionalBalances;
            
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return balancesPromotional;
    } 
    
    public static CEC_RestObjects.BalancesMain generateMock() { 
        List<CEC_RestObjects.PromotionalBalances> lstPromo = new List<CEC_RestObjects.PromotionalBalances>();
        CEC_RestObjects.PromotionalBalances promo = new CEC_RestObjects.PromotionalBalances();
        promo.platformIdentification = '2';
        promo.platformDescription = 'Total Contas Dedicadas';
        promo.description = 'Bônus para Ligações Locais';
        promo.categoryIdentification = 'PACOTE';
        promo.categoryDescription = 'Saldo de Pacotes';
        promo.internalUseIndicator = 'false';
        promo.balance = '5.5';
        promo.measurementUnit = 'REAIS';
        promo.dateEndValidity = '2019-01-01';
        lstPromo.add(promo);
        
        List<CEC_RestObjects.Accumulators> lstAccum = new List<CEC_RestObjects.Accumulators>();
        CEC_RestObjects.Accumulators accum1 = new CEC_RestObjects.Accumulators();
        accum1.accumulatorPlatformIdentification = '2';
        accum1.accumulatorPlatformDescription = 'MIN. BONUS IR';
        accum1.accumulatorBusinessDescription = 'Bônus para Ligações Locais';
        accum1.accumulatorCategoryIdentification = 'PACOTE';
        accum1.accumulatorCategoryDescription = 'Saldo de Pacotes';
        accum1.accumulatorInternalUseIndicator = 'true';
        accum1.accumulatorBalance = '10.0';
        accum1.accumulatorDateStartValidity = Datetime.newInstance(2019, 01, 01);
        accum1.accumulatorDateEndValidity = Datetime.newInstance(2019, 01, 01);
        accum1.accumulatorMeasurementUnit = 'REAIS';
        lstAccum.add(accum1);
        
        CEC_RestObjects.Accumulators accum2 = new CEC_RestObjects.Accumulators();
        accum2.accumulatorBalance = '0.0';
        accum2.accumulatorMeasurementUnit = 'BOLEANO';
        lstAccum.add(accum2);
        
        CEC_RestObjects.Accumulators accum3 = new CEC_RestObjects.Accumulators();
        accum3.accumulatorBalance = '11.0';
        accum3.accumulatorBusinessDescription = 'SMS Enviado';     
        accum3.accumulatorMeasurementUnit = 'BOLEANO';
        lstAccum.add(accum3);

        CEC_RestObjects.Accumulators accum4 = new CEC_RestObjects.Accumulators();
        accum4.accumulatorBalance = '1.0';
        accum4.accumulatorBusinessDescription = 'Total Acumulado';   
        accum4.accumulatorMeasurementUnit = '';
        lstAccum.add(accum4);
        
        CEC_RestObjects.BalancesMain balanceAmount = new CEC_RestObjects.BalancesMain();
        balanceAmount.data = new CEC_RestObjects.DataBalance();
        balanceAmount.data.balances = new CEC_RestObjects.Balances();
        balanceAmount.data.balances.datePlatformActivation = 'ab';
        balanceAmount.data.balances.platformSituation = 'ab';
        balanceAmount.data.balances.principalBalanceAmount = '40.5';
        balanceAmount.data.balances.principalExpirationDateCredit = '2019-04-04';
        balanceAmount.data.balances.principalDateBlockingCalls = '2019-01-06';
        balanceAmount.data.balances.principalDateExpirationBalance = '2019-04-05';
        balanceAmount.data.balances.principalDateExpirationService = '2019-07-04';
        balanceAmount.data.balances.principalDateExpirationPhone = '2019-07-05';
        balanceAmount.data.balances.phoneLineNumber = '1912312312';
        balanceAmount.data.balances.pricePlan = new CEC_RestObjects.PricePlan();
        balanceAmount.data.balances.pricePlan.pricePlanName = 'teste';      
        balanceAmount.data.balances.accumulators = lstAccum;
        balanceAmount.data.balances.promotionalBalances = lstPromo;
        
        return balanceAmount;
    }
    
}