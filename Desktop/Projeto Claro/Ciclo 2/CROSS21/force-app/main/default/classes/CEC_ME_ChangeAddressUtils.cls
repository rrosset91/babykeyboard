/*---------------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Mudanca de Endereco = Jorge Seibert/Guilherme Cuencas
--- Update for: Leandro Petri/ Jesús Azuaje
--- Description: Classe responsável por chamada do processo total de Mudanca de Endereco
--- CreateDate: 01/03/2019
--- UpdateDate: 15/01/2020 - RF255 - Mudança de endereço – Filtro por Número en tabla de complementos
--- Version: 2.5
---------------------------------------------------------------------------------------------------------------*/

global class CEC_ME_ChangeAddressUtils implements vlocity_cmt.VlocityOpenInterface {
    private Map<String, Object> input;
    private Map<String, Object> output;
    private Map<String, Object> options;
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            System.debug('input: ' + JSON.serialize(input));
            System.debug('output: ' + JSON.serialize(output));
            System.debug('options: ' + JSON.serialize(options));
            this.input = input;
            this.output = output;
            this.options = options;
            
            switch on methodName {
                when 'getFilteredAssetsByRecordType' {
                    this.getFilteredAssetsByRecordType();
                }
                when 'getFilteredAssets' {
                    this.getFilteredAssets();
                }
                when 'getTechValContractStatus' {
                    this.getTechValContractStatus();
                }
                when 'getTechValAddressStatus' {
                    this.getTechValAddressStatus();
                }
                when 'getOccurrencesConfig' {
                    this.getOccurrencesConfig();
                }
                when 'sendContractInconsistencies' {
                    this.sendContractInconsistencies();
                }
                when 'getDiffDate' {
                    this.getDiffDate();
                }
                when 'getCancellationWorkOrderSchedule' {
                    this.getCancellationWorkOrderSchedule();
                }
                when 'getCasePaymentPlanValueLabel' {
                    this.getCasePaymentPlanValueLabel();
                }
                when 'getInconsistenciesMap' {
                    this.getInconsistenciesMap();
                }
                when 'getAddressGEDTransform' {
                    this.getAddressGEDTransform();
                }
                when 'getFilteredScheduledEntities' {
                    this.getFilteredScheduledEntities();
                }
                when 'getOpenWorkOrders' {
                    this.getOpenWorkOrders();
                }
                when 'getOpenWorkOrdersById' {
                    this.getOpenWorkOrdersById();
                }
            }
            
            return true;
        }
        catch (Exception ex) {
            throw ex;
        }
    }
    
    private void getFilteredAssetsByRecordType() {
        try {
            List<Object> assetList = (List<Object>) this.options.get('Asset');
            Map<String, Object> assetTemporalMap;
            String recordtypeTemp;
            List<object> productList = new List<object>();
            List<Map<String, object>> tvList = new List<Map<String, object>>();
            List<Map<String, object>> movilList = new List<Map<String, object>>();
            List<Map<String, object>> internetList = new List<Map<String, object>>();
            List<Map<String, object>> phoneList = new List<Map<String, object>>();
            Map<String, Object> tvlistTotal = new Map<String, Object>();
            Map<String, Object> internetlistTotal = new Map<String, Object>();
            Map<String, Object> phonelistTotal = new Map<String, Object>();
            Map<String, Object> mobelistTotal = new Map<String, Object>();
            for (Object asset : assetList) {
                assetTemporalMap = (Map<String, Object>) asset;
                recordtypeTemp = (String) assetTemporalMap.get('RecordTypeDevName');
                switch on recordtypeTemp {
                    when 'CECTV' {
                        tvList.add(assetTemporalMap);
                    }
                    when 'CECInternetMovel' {
                        internetList.add(assetTemporalMap);
                    }
                    when 'CECInternetFixa' {
                        internetList.add(assetTemporalMap);
                    }
                    when 'CECFixo' {
                        phoneList.add(assetTemporalMap);
                    }
                    when 'CECMovel' {
                        movilList.add(assetTemporalMap);
                    }
                    when 'CECMovelPreControle' {
                        movilList.add(assetTemporalMap);
                    }
                }
            }
            
            tvlistTotal.put('title', 'tv');
            tvlistTotal.put('childList', tvList);
            internetlistTotal.put('title','internet');
            internetlistTotal.put('childList', internetList);
            phonelistTotal.put('title','Fixo');
            phonelistTotal.put('childList', phoneList);
            mobelistTotal.put('title','Movel');
            mobelistTotal.put('childList', movilList);
            productList.add(tvlistTotal);
            productList.add(internetlistTotal);
            productList.add(phonelistTotal);
            productList.add(mobelistTotal);
            output.put('Products', productList);
        }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getInconsistenciesMap() {
        try {
            //Map<String, Object> requests = (Map<String, Object>) this.options.get('Requests');
            List<String> paramsRequest = new List<String>();
            Map<String, Object> debits = (Map<String, Object>) this.options.get('Debits');
            List<String> paramsDebits = new List<String>();
            Boolean showDebitsAlert = false;
            Map<String, Object> portability = (Map<String, Object>) this.options.get('Portability');
            List<String> paramsPortability = new List<String>();
            Map<String, Object> embratel = (Map<String, Object>) this.options.get('Embratel');
            List<String> paramsEmbratel = new List<String>();
            Map<String, Object> suspension = (Map<String, Object>) this.options.get('TemporarySuspension');
            List<String> paramsSuspension = new List<String>();
            Map<String, List<Object>> occurrencesMap = new Map<String, List<Object>>();
            String contractNumber = String.valueOf(this.options.get('ContractNumber'));
            Boolean isBlocking = false;
            Boolean hasInconsistencies = false;
            
            //REQUESTS
            /*  if(requests.containsKey('data')) {
paramsRequest.add(contractNumber);
hasInconsistencies = true;
}
occurrencesMap.put('Requests', paramsRequest);*/
            
            //DEBITS
            if(debits.containsKey('data')) {
                List<Object> listDebitsData = (List<Object>) debits.get('data');
                
                Map<String, Object> mapDebits = getDebitsAlert(listDebitsData);
                Integer daysBetween = Integer.valueOf(mapDebits.get('DaysBetween'));
                showDebitsAlert = Boolean.valueOf(mapDebits.get('ShowDebitsAlert'));
                
                //Se comenta condicion para no evaluar la cantidad de días US 287 PCBCA-390 y no se deja de bloquear el proceso cuando existen facturas.
                //if(listDebitsData.size() > 0 && daysBetween > 30) {
                if(listDebitsData.size() > 0) {
                    paramsDebits.add(contractNumber);
                    //isBlocking = true;
                    isBlocking = false;
                }
            }
            occurrencesMap.put('Debits', paramsDebits);
            
            //PORTABILITY
            if(portability.containsKey('data')) {
                Map<String, Object> mapPortabilityData = (Map<String, Object>) portability.get('data');
                
                if(!String.isBlank(String.valueOf(mapPortabilityData.get('Status')))) {
                    paramsPortability.add(contractNumber);
                    hasInconsistencies = true;
                }
            }
            occurrencesMap.put('Portability', paramsPortability);
            
            //EMBRATEL
            if(embratel.containsKey('BillingAccounts')) {
                Map<String, Object> mapEmbratelData = (Map<String, Object>) embratel.get('BillingAccounts');
                String statusLegado = String.valueOf(mapEmbratelData.get('StatusDoLegado'));
                String statusEmbratel = String.valueOf(mapEmbratelData.get('EmbratelStatus'));
                if(!statusLegado.equalsIgnoreCase('CONECTADO') || (!statusEmbratel.equalsIgnoreCase('CONECTADO') && !statusEmbratel.equalsIgnoreCase('NÃO POSSUI'))) {
                    paramsEmbratel.add(contractNumber);
                    hasInconsistencies = true;
                }
            }
            occurrencesMap.put('Embratel', paramsEmbratel);
            
            //SUSPENSION
            if(suspension.containsKey('Asset')) {
                if(String.isNotBlank(String.valueOf(suspension.get('Asset')))) {
                    List<Map<String, Object>> listSuspensionData = (List<Map<String, Object>>) suspension.get('Asset');
                    if(listSuspensionData.size() > 0) {
                        paramsSuspension.add(contractNumber);
                        hasInconsistencies = true;
                        isBlocking = true;
                    }
                }
            }
            occurrencesMap.put('Suspension', paramsSuspension);
            
            output.put('Occurrences', occurrencesMap);
            output.put('HasBlockingInconsistences', isBlocking);
            output.put('HasInconsistences', hasInconsistencies);
            output.put('ShowDebitsAlert', showDebitsAlert);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getAddressGEDTransform(){
        try {
            List<Object> edifications = (List<Object>) this.options.get('edifications');
            String numeroLong;
            System.debug('Get numero = ' + this.options.get('numero'));         
            
            if(this.options.get('numero') != ''){
                numeroLong = (String) this.options.get('numero');            
                if(this.options.get('numero') == 'S/N'){
                    numeroLong = '';   
                }
                if(this.options.get('numero') == null){
                    numeroLong = '';   
                }  
            }else{
                numeroLong = '';
            }        
            
            List<Map<String, object>> AddressComplementsTable = new List<Map<String, object>>();
            Map<String, Object> edificationTemporalMap;
            Map<String, Object> address;
            List<Object> domiciles;
            Boolean hasComplements = false;
            
            for (Object edification : edifications) {
                edificationTemporalMap = (Map<String, Object>) edification;
                address = (Map<String, Object>) edificationTemporalMap.get('address');
                domiciles = (List<Object>) edificationTemporalMap.get('domiciles');
                Map<String, Object> singleDomicile = (Map<String, Object>) domiciles[0];
                
                Map<String,Object> addressComplement = new Map<String,Object>();
                String Complementos='';
                String CityName = (String) address.get('city');
                String Bairro = (String) address.get('neighborhood');
                String CEP = (String) address.get('postalCode');
                String Numero = (String) address.get('streetNumber');
                String DomicileId = '';
                
                if (CityName == 'BRASILIA'){
                    numeroLong = '';
                }
                if(Numero == null){
                    Numero = '0';   
                }                              
                if(numeroLong != ''){                    
                    if(numeroLong == Numero){
                        Complementos= (String) address.get('urbanPropertySubAddress');
                        DomicileId = (String) singleDomicile.get('id');
                        addressComplement.put('CityName', CityName);
                        addressComplement.put('Bairro', Bairro);
                        addressComplement.put('CEP', CEP);
                        addressComplement.put('Numero', Numero);
                        addressComplement.put('Complementos', Complementos);
                        addressComplement.put('DomicileId',DomicileId);
                        
                        AddressComplementsTable.add(addressComplement);                        
                    }                 
                }else{
                    Complementos= (String) address.get('urbanPropertySubAddress');
                    DomicileId = (String) singleDomicile.get('id');
                    addressComplement.put('CityName', CityName);
                    addressComplement.put('Bairro', Bairro);
                    addressComplement.put('CEP', CEP);
                    addressComplement.put('Numero', Numero);
                    addressComplement.put('Complementos', Complementos);
                    addressComplement.put('DomicileId',DomicileId);
                    
                    AddressComplementsTable.add(addressComplement);
                    
                }
            }    
            
            if(AddressComplementsTable.size()>0){
                hasComplements = true;
            } else{
                for (Object edificationAux : edifications) {
                    edificationTemporalMap = (Map<String, Object>) edificationAux;
                    address = (Map<String, Object>) edificationTemporalMap.get('address');
                    domiciles = (List<Object>) edificationTemporalMap.get('domiciles');
                    Map<String, Object> singleDomicileAux = (Map<String, Object>) domiciles[0];
                    
                    Map<String,Object> addressComplementAux = new Map<String,Object>();
                    String ComplementosAux='';
                    String CityNameAux = (String) address.get('city');
                    String BairroAux = (String) address.get('neighborhood');
                    String CEPAux = (String) address.get('postalCode');
                    String NumeroAux = (String) address.get('streetNumber');
                    String DomicileIdAux = '';
                    
                    if (CityNameAux == 'BRASILIA'){
                        numeroLong = '';
                    }
                    if(NumeroAux == null){
                        NumeroAux = '0';   
                    }                              
                    if(numeroLong != ''){                    
                        ComplementosAux= (String) address.get('urbanPropertySubAddress');
                        DomicileIdAux = (String) singleDomicileAux.get('id');
                        addressComplementAux.put('CityName', CityNameAux);
                        addressComplementAux.put('Bairro', BairroAux);
                        addressComplementAux.put('CEP', CEPAux);
                        addressComplementAux.put('Numero', NumeroAux);
                        addressComplementAux.put('Complementos', ComplementosAux);
                        addressComplementAux.put('DomicileId',DomicileIdAux);
                        
                        AddressComplementsTable.add(addressComplementAux);                        
                    }                                   
                }
            }
            
            if(AddressComplementsTable.size()>0){
                 hasComplements = true;
             }
            
            output.put('AddressComplementsTable', AddressComplementsTable);
            output.put('HasComplements', hasComplements);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getFilteredAssets() {
        try {
            List<Object> assetList = (List<Object>) this.options.get('Asset');
            System.debug('AssetList:'+assetList);
            Map<String, Object> assetTemporalMap;
            String recordtypeTemp;
            List<object> productList = new List<object>();
            List<Map<String, object>> tvList = new List<Map<String, object>>();
            List<Map<String, object>> movilList = new List<Map<String, object>>();
            List<Map<String, object>> internetList = new List<Map<String, object>>();
            List<Map<String, object>> phoneList = new List<Map<String, object>>();
            Map<String, Object> tvlistTotal = new Map<String, Object>();
            Map<String, Object> internetlistTotal = new Map<String, Object>();
            Map<String, Object> phonelistTotal = new Map<String, Object>();
            Map<String, Object> mobelistTotal = new Map<String, Object>();
            
            for (Object asset : assetList) {
                assetTemporalMap = (Map<String, Object>) asset;
                Map<String, Object> newAsset = new Map<String,Object>();
                newAsset.put('Name', (String)assetTemporalMap.get('productName'));
                recordtypeTemp = (String) assetTemporalMap.get('technologyId');
                
                switch on recordtypeTemp {
                    when '1' {
                        newAsset.put('RecordTypeName','TV');
                        tvList.add(newAsset);
                    }
                    when '2' {
                        newAsset.put('RecordTypeName','TV');
                        tvList.add(newAsset);
                    }
                    when '3' {
                        newAsset.put('RecordTypeName','Internet');
                        internetList.add(newAsset);
                    }
                    when '4' {
                        newAsset.put('RecordTypeName','Fixo');
                        phoneList.add(newAsset);
                    }
                }
            }
            
            tvlistTotal.put('title', 'tv');
            tvlistTotal.put('childList', tvList);
            
            internetlistTotal.put('title','internet');
            internetlistTotal.put('childList', internetList);
            
            phonelistTotal.put('title','Fixo');
            phonelistTotal.put('childList', phoneList);
            
            mobelistTotal.put('title','Movel');
            mobelistTotal.put('childList', movilList);
            
            productList.add(tvlistTotal);
            productList.add(internetlistTotal);
            productList.add(phonelistTotal);
            productList.add(mobelistTotal);
            output.put('Products', productList);
        }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getTechValContractStatus() {
        try {
            String result = 'Livre';
            List<Object> listDomicileHistory = (List<Object>) this.options.get('domicileHistory');
            
            for(Object oDomicileHistory : listDomicileHistory) {
                Map<String, Object> mapDomicileHistory = (Map<String, Object>) oDomicileHistory;
                //type = (String) mapDomicileHistory.get('type');
                if(String.valueOf(mapDomicileHistory.get('type')).equals('CONTRATO')) {
                    if(String.valueOf(mapDomicileHistory.get('status')).startsWithIgnoreCase('CONEC')) {
                        result = 'Ocupado';
                        break;
                    }
                    else if(String.valueOf(mapDomicileHistory.get('status')).startsWithIgnoreCase('DESAB')) {
                        result = 'Desabilitado';
                        break;
                    }
                }
            }
            
            output.put('Status', result);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getTechValAddressStatus() {
        try {
            String result = 'Bloqueado';
            String noteDomicile = String.valueOf(this.options.get('noteDomicile'));
            System.debug('noteDomicile: ' + noteDomicile);
            
            String auxNoteDomicile = noteDomicile.split('\n')[0];
            System.debug('auxNoteDomicile: ' + auxNoteDomicile);
            System.debug('split auxNoteDomicile: ' + auxNoteDomicile.split(': '));
            System.debug('size auxNoteDomicile: ' + auxNoteDomicile.split(': ').size());
            if(auxNoteDomicile.split(': ').size() <= 1) {
                System.debug('size menor o igual a 1');
                List<Object> listGeoLocationsResp = (List<Object>) this.options.get('GeographicLocationsResponse');
                for(Object oGeoLocationsResp : listGeoLocationsResp) {
                    Map<String, Object> mapGeoLocationsResp = (Map<String, Object>) oGeoLocationsResp;
                    System.debug('ServiceType: ' + mapGeoLocationsResp.get('ServiceType'));
                    if(mapGeoLocationsResp.get('ServiceType').equals('PAY TV')) {
                        System.debug('Es PAY TV');
                        if(!String.valueOf(mapGeoLocationsResp.get('TechnicalViability')).contains('Não OK') && !String.valueOf(mapGeoLocationsResp.get('CommercialViability')).contains('Não OK')) {
                            result = 'Endereço OK';
                        }
                    }
                }
            }
            else {
                if(noteDomicile.contains('ENDERECO OK')) {
                    result = 'Endereço OK';
                }
            }
            System.debug('result: ' + result);
            output.put('Status', result);
        }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getOccurrencesConfig() {
        try {
            List<Map<String, Object>> listOccurrences = new List<Map<String, Object>>();
            List<Object> arguments;
            String stringResult;
            Map<String, Object> occurrencesParams = (Map<String, Object>) this.options.get('Occurrences');
            String booleanOccurrence = String.valueOf(this.options.get('Prescheduling'));
            string data = String.valueOf(this.options.get('data'));
            String period = String.valueOf(this.options.get('period'));
            
            //-----------------------OPERACIONES-----------------------//
            //ChangeAddress
            if(occurrencesParams.containsKey('ChangeAddress')) {
                arguments = listParser(occurrencesParams.get('ChangeAddress'));
                stringResult = getOccurrencesSettings('ChangeAddress', arguments, booleanOccurrence, data, period);
                listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
            }
            
            //Rescheduling
            if(occurrencesParams.containsKey('Rescheduling')) {
                arguments = listParser(occurrencesParams.get('Rescheduling'));
                stringResult = getOccurrencesSettings('Rescheduling', arguments, booleanOccurrence, data, period);
                listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
            }
            
            //Cancellation
            if(occurrencesParams.containsKey('Cancellation')) {
                arguments = listParser(occurrencesParams.get('Cancellation'));
                if (arguments.size() > 0) {
                    stringResult = getOccurrencesSettings('Cancellation', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //CancellationInfo
            if(occurrencesParams.containsKey('CancellationInfo')) {
                arguments = listParser(occurrencesParams.get('CancellationInfo'));
                if (arguments.size() > 0) {
                    stringResult = getOccurrencesSettings('CancellationInfo', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //-----------------------INCONSISTENCIAS-----------------------//
            //Requests
            /*  if(occurrencesParams.containsKey('Requests')) {
arguments = listParser(occurrencesParams.get('Requests'));
if(arguments.size() > 0 ) {
stringResult = getOccurrencesSettings('Requests', arguments, booleanOccurrence, data, period);
listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
}
}*/
            
            //BillDebits
            if(occurrencesParams.containsKey('Debits')) {
                arguments = listParser(occurrencesParams.get('Debits'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('Debits', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //Portability
            if(occurrencesParams.containsKey('Portability')) {
                arguments = listParser(occurrencesParams.get('Portability'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('Portability', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //Embratel
            if(occurrencesParams.containsKey('Embratel')) {
                arguments = listParser(occurrencesParams.get('Embratel'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('Embratel', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //Suspension
            if(occurrencesParams.containsKey('Suspension')) {
                arguments = listParser(occurrencesParams.get('Suspension'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('Suspension', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //-----------------------SEARCH ADDRESS-----------------------//
            //SearchAddress
            if(occurrencesParams.containsKey('SearchAddress')) {
                arguments = listParser(occurrencesParams.get('SearchAddress'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('SearchAddress', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //-----------------------TECHNICAL VIABILITY-----------------------//
            //GEDOfflineAddress
            if(occurrencesParams.containsKey('GEDOfflineAddress')) {
                arguments = listParser(occurrencesParams.get('GEDOfflineAddress'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('GEDOfflineAddress', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //GEDAddressFail
            if(occurrencesParams.containsKey('GEDAddressFail')) {
                arguments = listParser(occurrencesParams.get('GEDAddressFail'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('GEDAddressFail', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //GEDOfflineContract
            if(occurrencesParams.containsKey('GEDOfflineContract')) {
                arguments = listParser(occurrencesParams.get('GEDOfflineContract'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('GEDOfflineContract', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //GEDContractFail
            if(occurrencesParams.containsKey('GEDContractFail')) {
                arguments = listParser(occurrencesParams.get('GEDContractFail'));
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('GEDContractFail', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                }
            }
            
            //COPOnlineBaixaOSFail
            if(occurrencesParams.containsKey('COPOnlineBaixaOSFail')){ 
                arguments = listParser(occurrencesParams.get('COPOnlineBaixaOSFail'));
                //System.debug('Coincide con la key COPOnlineBaixaOSFail');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('COPOnlineBaixaOSFail', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    //System.debug('COPOnlineBaixaOSFail dentro del condicional de argument size: ' +  stringResult );
                }
            }
            //COPOfflineBaixaOSBKO
            if(occurrencesParams.containsKey('COPOfflineBaixaOSBKO')){ 
                arguments = listParser(occurrencesParams.get('COPOfflineBaixaOSBKO'));
                //System.debug('Coincide con la key COPOfflineBaixaOSBKO');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('COPOfflineBaixaOSBKO', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    //System.debug('COPOfflineBaixaOSBKO dentro del condicional de argument size: ' +  stringResult );
                }
            }
            //COPExcedido
            if(occurrencesParams.containsKey('COPExcedido')){ 
                arguments = listParser(occurrencesParams.get('COPExcedido'));
                //System.debug('Coincide con la key COPExcedido');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('COPExcedido', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    //System.debug('COPExcedido dentro del condicional de argument size: ' +  stringResult );
                }
            }
            //OSCOPNaoElegivel
            if(occurrencesParams.containsKey('OSCOPNaoElegivel')){ 
                arguments = listParser(occurrencesParams.get('OSCOPNaoElegivel'));
                //System.debug('Coincide con la key OSCOPNaoElegivel');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('OSCOPNaoElegivel', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    //System.debug('OSCOPNaoElegivel dentro del condicional de argument size: ' +  stringResult );
                }
            }
            
            //OSBANaoIA
            if(occurrencesParams.containsKey('OSBANaoIA')){ 
                arguments = listParser(occurrencesParams.get('OSBANaoIA'));
                System.debug('Coincide con la key OSBANaoIA');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('OSBANaoIA', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    
                }
            }
            
            //OSBAnaoEncontrado
            if(occurrencesParams.containsKey('OSBAnaoEncontrado')){ 
                arguments = listParser(occurrencesParams.get('OSBAnaoEncontrado'));
                System.debug('Coincide con la key OSBAnaoEncontrado');
                if(arguments.size() > 0 ) {
                    stringResult = getOccurrencesSettings('OSBAnaoEncontrado', arguments, booleanOccurrence, data, period);
                    listOccurrences.add((Map<String, Object>) JSON.deserializeUntyped(stringResult));
                    
                }
            }
            output.put('ContractOccurrences', listOccurrences);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private string getOccurrencesSettings(String occurrenceName, List<Object> arguments,String booleanPreagendamento,String data, String periodo) {
        try {
            CEC_ME_OccurrenceSettings__mdt occurrenceSetting = [SELECT DeveloperName, Group__c, Id, Label, ObservationPattern__c, Status__c, TypeId__c, Type__c FROM CEC_ME_OccurrenceSettings__mdt WHERE DeveloperName = :occurrenceName][0];
            String occurrenceObservation = '';
            
            if(String.isNotBlank(String.valueOf(occurrenceSetting.ObservationPattern__c))) {
                occurrenceObservation = String.format(String.valueOf(occurrenceSetting.ObservationPattern__c), arguments);  
                if(booleanPreagendamento == 'true' &&  (occurrenceName != 'Debits' || occurrenceName != 'Suspension') && (data != '' || periodo != ''))
                    occurrenceObservation = occurrenceObservation + ' Pré-Agendamento, Data acordada para instalação: ' +  data + ', Período Agendado: ' + periodo + '\\n\\n Operador / Supervisor / área / Site + Cidade';
            }
            
            String stringResult = '{"Name":"' + occurrenceSetting.Label + '",'
                + '"OccurrenceGroup":"' + occurrenceSetting.Group__c + '",'
                + '"OccurrenceType":"' + occurrenceSetting.Type__c + '",'
                + '"OccurrenceTypeId":"' + occurrenceSetting.TypeId__c + '",'
                + '"OccurrenceStatus":"' + occurrenceSetting.Status__c + '",'
                + '"OccurrenceObservation":"' + occurrenceObservation
                + '"}';
            
            return stringResult;
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void sendContractInconsistencies() {
        System.debug('sendContractInconsistencies');
        String procedureName = 'ChangeAddress_ContactRecords';
        System.debug('options: ' + this.options);
        
        try {
            List<Object> contractInconsistenceList = (List<Object>) this.options.get('contractInconsistencies');
            System.debug('contractInconsistenceList: ' + contractInconsistenceList);
            List<vlocity_cmt__CustomerInteractionTopic__c> customerInteractionTopicToInsert =  new List<vlocity_cmt__CustomerInteractionTopic__c>();
            
            String protocolNumber = String.valueOf(this.options.get('protocolNumber'));
            String operatorCode = String.valueOf(this.options.get('operatorCode'));
            String interactionNumber = String.valueOf(this.options.get('interactionNumber'));
            String contractNumber = String.valueOf(this.options.get('contractNumber'));
            String login = UserInfo.getUserId();
            
            String caseId = String.valueOf(this.options.get('caseId'));
            String customerInteractionId = String.valueOf(this.options.get('customerInteractionId'));
            System.debug('customerInteractionId: ' + customerInteractionId);
            Map<String, Object> contractInconsistenceTemporalMap;
            
            for (Object contractInconsistence : contractInconsistenceList) {
                vlocity_cmt__CustomerInteractionTopic__c customerInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
                
                contractInconsistenceTemporalMap = (Map<String, Object>) contractInconsistence;
                
                Map <String, Object> ipInput = new Map <String, Object> ();
                Map <String, Object> ipOutput = new Map <String, Object> ();
                Map <String, Object> ipOptions = new Map <String, Object> ();
                
                String occurrenceObservation = String.valueOf(contractInconsistenceTemporalMap.get('OccurrenceObservation'));
                String occurrenceTypeId = String.valueOf(contractInconsistenceTemporalMap.get('OccurrenceTypeId'));
                
                String occurrenceType = String.valueOf(contractInconsistenceTemporalMap.get('OccurrenceType'));
                String OccurrenceGroup = String.valueOf(contractInconsistenceTemporalMap.get('OccurrenceGroup'));
                
                ipInput.put('login', login);
                ipInput.put('protocolNumber', protocolNumber);
                ipInput.put('operatorCode', operatorCode);
                ipInput.put('occurrenceObservation', occurrenceObservation);
                ipInput.put('interactionNumber', interactionNumber);
                ipInput.put('occurrenceTypeId', occurrenceTypeId);
                ipInput.put('contractNumber', contractNumber);
                
                /* Call the IP via runIntegrationService, and save the output to ipOutput */
                System.debug('IP Input: ' + ipInput);
                if(!test.isRunningTest()) {
                    ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
                }
                System.debug('IP Output: ' + ipOutput);
                
                customerInteractionTopic.vlocity_cmt__CaseId__c = caseId;
                customerInteractionTopic.vlocity_cmt__CustomerInteractionId__c = customerInteractionId;
                customerInteractionTopic.Comments__c = occurrenceObservation;
                customerInteractionTopic.TypeOccurrence__c = occurrenceType;
                customerInteractionTopic.GroupOccurrence__c = OccurrenceGroup;
                customerInteractionTopic.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'vlocity_cmt__CustomerInteractionTopic__c' AND Name = 'Interação ME'].Id;
                customerInteractionTopicToInsert.add(customerInteractionTopic);
            }
            
            if(!customerInteractionTopicToInsert.isEmpty())
                insert customerInteractionTopicToInsert;
        }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private string getFormattedDate(Date unformattedDate) {
        try {
            String sMonth = String.valueof(unformattedDate.month());
            String sDay = String.valueof(unformattedDate.day());
            if(sMonth.length()==1) {
                sMonth = '0' + sMonth;
            }
            if(sDay.length()==1) {
                sDay = '0' + sDay;
            }
            String formattedDate = String.valueof(unformattedDate.year()) + '-' + sMonth + '-' + sDay;
            return formattedDate;
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getDiffDate() {
        try {
            String sOrigin = String.valueOf(this.options.get('originDate'));
            Date originDate = Date.valueOf(sOrigin);
            Integer diffDays = Integer.valueOf(this.options.get('diffDays'));
            
            Date diffDate = originDate.addDays(diffDays);
            output.put('diffDate', getFormattedDate(diffDate));
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getCancellationWorkOrderSchedule() {
        try {
            Map<String, Object> result = new Map<String, Object>();
            List<Object> listOrders = (List<Object>) this.options.get('orders');
            for(Object oOrder : listOrders) {
                Map<String, Object> mapOrder = (Map<String, Object>) oOrder;
                if(String.valueOf(mapOrder.get('typeId')).equals('14') && (String.valueOf(mapOrder.get('status')).equals('CRIADA')
                                                                           ||String.valueOf(mapOrder.get('status')).equals('AGENDADA')
                                                                           ||String.valueOf(mapOrder.get('status')).equals('REAGENDADA'))) {
                                                                               System.debug('Es 14'+ String.valueOf(mapOrder.get('status')) );
                                                                               DateTime executionStart = DateTime.Now().addMinutes(-1);
                                                                               String executionStartDatetime = executionStart.formatGMT('YYYY-MM-dd') + 'T' + executionStart.formatGMT('HH:mm:ss');
                                                                               DateTime executionEnd = DateTime.Now();
                                                                               String executionEndDatetime = executionEnd.formatGMT('YYYY-MM-dd') + 'T' + executionEnd.formatGMT('HH:mm:ss');
                                                                               result.put('workorderId', mapOrder.get('orderId'));
                                                                               result.put('isExempt', mapOrder.get('isExempt'));
                                                                               result.put('executionStartDatetime', executionStartDatetime);
                                                                               result.put('executionEndDatetime', executionEndDatetime);
                                                                               break;
                                                                           }
            }
            output.put('CancellationOrder', result);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getCasePaymentPlanValueLabel() {
        try {
            String valueSelected = String.valueOf(this.options.get('valueSelected'));
            String result;
            
            Schema.DescribeFieldResult fieldResult = Case.PaymentPlan__c.getDescribe();
            List<Schema.PicklistEntry> listValues = fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry value : listValues) {
                if(String.valueOf(value.getValue()).equals(valueSelected)) {
                    result = value.getLabel();
                }
            }
            
            output.put('PaymentPlanLabel', result);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void getFilteredScheduledEntities() {
        try {
            Map<String, Object> scheduledEntities = new Map<String, Object>();
            List<Object> finalEntities = new List<Object>();
            String schedulingAction = String.valueOf(this.options.get('SchedulingAction'));
            Map<String, Object> data = (Map<String,Object>) this.options.get('data');
            String observationOnAppointment = String.valueOf(this.options.get('ObservationOnAppointment'));
            List<Object> orders = (List<Object>) data.get('orders');
            
            for(Object orderObject:orders) {
                Map<String,Object> entity = new Map<String,Object>();
                Map<String,Object> singleOrder = (Map<String,Object>)orderObject;
                if(Integer.valueOf(singleOrder.get('typeId')) != 14 && (String.valueOf(singleOrder.get('status')) == 'CRIADA' || String.valueOf(singleOrder.get('status')) == 'AGENDADA')) {
                    entity.put('id', String.valueOf(singleOrder.get('orderId')));
                    entity.put('action', schedulingAction);
                    entity.put('typeId','OrdemCampo');
                    entity.put('chargeUnproductiveFieldOrder','0');
                    entity.put('isGenerateOccurrence', 'false');
                    entity.put('notes', observationOnAppointment);
                    finalEntities.add(entity);
                }
            }
            output.put('scheduledEntities', finalEntities);
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private Map<String, Object> getDebitsAlert(List<Object> listDebits) {
        try {
            Date maxDueDate;
            Integer daysBetween = 0;
            Boolean showDebitsAlert = false;
            Map<String, Object> mapDebits = new Map<String, Object>();
            
            if(listDebits.size() > 0) {
                for (Object oDebit : listDebits) {
                    Map<String, Object> mapDebit = (Map<String, Object>) oDebit;
                    Date auxDueDate = Date.parse(String.valueOf(mapDebit.get('dueDate')));
                    if(maxDueDate == null || maxDueDate > auxDueDate) {
                        maxDueDate = auxDueDate;
                    }
                }
                daysBetween = maxDueDate.daysBetween(Date.today());
            }
            
            if(daysBetween > 0) {
                showDebitsAlert = true;
            }
            
            mapDebits.put('ShowDebitsAlert', showDebitsAlert);
            mapDebits.put('DaysBetween', daysBetween);
            return mapDebits;
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    public List<Object> listParser (Object obj) {
        List<Object> newList = new List<Object>();
        
        try {
            newList = (List<Object>) obj;
            return newList;
        }
        catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            return newList;
        }
    }
    
    private void getOpenWorkOrders() {
        try {
            Map<String, Object> scheduledEntities = new Map<String, Object>();
            List<Object> finalEntities = new List<Object>();
            Map<String, Object> data = (Map<String,Object>) this.options.get('data');
            List<Object> orders = (List<Object>) data.get('orders');
            for(Object orderObject:orders) {
                Map<String,Object> entity = new Map<String,Object>();
                Map<String,Object> singleOrder = (Map<String,Object>)orderObject;
                if((String.valueOf(singleOrder.get('status')) == 'AGENDADA' || String.valueOf(singleOrder.get('status')) == 'CRIADA') || String.valueOf(singleOrder.get('status')) == 'DESPACHADA' || String.valueOf(singleOrder.get('status')) == 'REAGENDADA') 
                {
                    entity.put('id', String.valueOf(singleOrder.get('orderId')));
                    entity.put('status', String.valueOf(singleOrder.get('status')));
                    entity.put('typeDescription', String.valueOf(singleOrder.get('typeDescription')));
                    entity.put('typeId', String.valueOf(singleOrder.get('typeId')));
                    finalEntities.add(entity);
                }
            }
            output.put('openWorkOrders', finalEntities);
            output.put('openWorkOrdersQuantity', finalEntities.size());
            
            
            for(Object orderObject:orders) {
                if(finalEntities.size() == 0){
                    Map<String,Object> entity = new Map<String,Object>();
                    Map<String,Object> singleOrder = (Map<String,Object>)orderObject;
                    if(String.valueOf(singleOrder.get('status')) == 'FECHADA') 
                    {
                        entity.put('id', String.valueOf(singleOrder.get('orderId')));
                        entity.put('status', String.valueOf(singleOrder.get('status')));
                        entity.put('typeDescription', String.valueOf(singleOrder.get('typeDescription')));
                        entity.put('typeId', String.valueOf(singleOrder.get('typeId')));
                        finalEntities.add(entity);
                        output.put('openWorkOrders', finalEntities);
                        output.put('openWorkOrdersQuantity', 0);
                    }
                }
                
            }
        } catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    private void getOpenWorkOrdersById() {
        try {
            Map<String, Object> scheduledEntities = new Map<String, Object>();
            List<Object> finalEntities = new List<Object>();
            Map<String, Object> data = (Map<String,Object>) this.options.get('data');
            String id = (String) this.options.get('id');
            List<Object> orders = (List<Object>) data.get('orders');
            
            for(Object orderObject:orders) {
                Map<String,Object> entity = new Map<String,Object>();
                Map<String,Object> singleOrder = (Map<String,Object>)orderObject;
                if(singleOrder.get('orderId') == id)
                {
                    entity.put('id', String.valueOf(singleOrder.get('orderId')));
                    entity.put('status', String.valueOf(singleOrder.get('status')));
                    entity.put('typeDescription', String.valueOf(singleOrder.get('typeDescription')));
                    entity.put('typeId', String.valueOf(singleOrder.get('typeId')));
                    finalEntities.add(entity);
                }
            }
            output.put('openWorkOrders', finalEntities);
            output.put('openWorkOrdersQuantity', finalEntities.size());       
            
        } catch (Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
}