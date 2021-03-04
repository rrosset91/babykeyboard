public with sharing class FinancialBondsNotIssued {
    // @note  83484 - Dados "Itens Títulos Não Emitidos"
    
    @AuraEnabled
    public static ResponseWrapper getBillDebts(String contractId, String operatorId,String startDate,String endDate){
        ResponseWrapper responseData = new ResponseWrapper();

        Map<String, String> params = setParams(contractId, operatorId);


        Map<String, String> headers = new Map<String, String>();
        String authToken = getAuth('GetBillDebts');
        headers.put('X-Client-Auth', authToken);
        headers.put('X-QueryString', 'customeraccountid='+operatorId+contractId);

        System.debug('83484:: params ==>'+ params);
        System.debug('83484:: headers ==>'+ headers);
        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetBillDebts');


        System.debug(calloutResponse);
        JSONCustomersContractsBillsDebts response = (JSONCustomersContractsBillsDebts)JSON.deserialize(calloutResponse.get('response'), JSONCustomersContractsBillsDebts.class);
        System.debug(response);	
        

		if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
            System.debug('Success'+calloutResponse.get('statusCode'));	
            responseData.groupDebts = new List<GroupBillDebtsWrapper>();
            responseData.groupDebts = processCallOut(response);
            responseData.responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
            
		}else{
            System.debug('Error '+calloutResponse.get('statusCode'));	
			responseData = setErrorMessage(response);
            responseData.responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
		}
        System.debug('responseData ' + responseData);	

		return responseData;
    }



    private static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
    }

    public static Map<String, String> setParams(String contractId, String operatorId){
		Map<String, String> params = new Map<String, String>();
		params.put('infoDetailLevel', 'DETAILS');


		return params;
    }

    private static List<GroupBillDebtsWrapper> processCallOut(JSONCustomersContractsBillsDebts jsonObject){
        List<GroupBillDebtsWrapper> lstGroups  = new List<GroupBillDebtsWrapper>();
        Map<Integer, List<BillDebtsWrapper>> mapGroupDebts = new Map<Integer, List<BillDebtsWrapper>>();
        Map<Integer, String> mapGroupDebtsDescription = new Map<Integer, String>();
        if(jsonObject.data.partnerDebts != null){
            for (JSONCustomersContractsBillsDebts.PartnerDebt partnerDebt : jsonObject.data.partnerDebts) {
                if(partnerDebt.serviceGroup != null){
                    for (JSONCustomersContractsBillsDebts.ServiceGroup service : partnerDebt.serviceGroup) {
                        if(service.partnerExtracts != null){
                            for (JSONCustomersContractsBillsDebts.PartnerExtract extract : service.partnerExtracts) {
                                BillDebtsWrapper debtWrapper = new BillDebtsWrapper();
                                debtWrapper.dueDate = formatDate(extract.dueDate.split('T')[0]);
                                debtWrapper.entryDate = formatDate(extract.entryDate.split('T')[0]);
                                debtWrapper.installmentNumber = String.valueOf(extract.installmentNumber);
                                debtWrapper.itemDescription = extract.itemDescription;
                                debtWrapper.partnerId = returnPartner(partnerDebt.partnerId);
                                debtWrapper.totalInstallments = String.valueOf(extract.totalInstallments);
                                debtWrapper.amount = extract.amount;
                                debtWrapper.sortentryDate = extract.entryDate.split('T')[0];
                                debtWrapper.productDescription = extract.partnerItemDescription;
                                
                                if(!mapGroupDebts.containsKey(service.groupId)){
                                    mapGroupDebts.put(service.groupId, new List<BillDebtsWrapper>());
                                    mapGroupDebtsDescription.put(service.groupId, service.groupDescription);
                                }
                                mapGroupDebts.get(service.groupId).add(debtWrapper);
                            }
                        }
                        if(service.partnerPhones != null){
                            for (JSONCustomersContractsBillsDebts.PartnerPhone phone : service.partnerPhones) {
                                if(phone.partnerExtracts != null){
                                    for (JSONCustomersContractsBillsDebts.PartnerExtract2 extract : phone.partnerExtracts) {
                                        BillDebtsWrapper debtWrapper = new BillDebtsWrapper();
                                        debtWrapper.dueDate = formatDate(extract.dueDate.split('T')[0]);
                                        debtWrapper.entryDate = formatDate(extract.entryDate.split('T')[0]);
                                        debtWrapper.installmentNumber = String.valueOf(extract.installmentNumber);
                                        debtWrapper.itemDescription = extract.itemDescription;
                                        debtWrapper.partnerId = returnPartner(partnerDebt.partnerId);
                                        debtWrapper.totalInstallments = String.valueOf(extract.totalInstallments);
                                        debtWrapper.amount = extract.amount;
                                        debtWrapper.sortentryDate = extract.entryDate.split('T')[0];
                                        debtWrapper.productDescription = extract.partnerItemDescription;

                                        if(!mapGroupDebts.containsKey(service.groupId)){
                                            mapGroupDebts.put(service.groupId, new List<BillDebtsWrapper>());
                                            mapGroupDebtsDescription.put(service.groupId, service.groupDescription);
                                        }
                                        mapGroupDebts.get(service.groupId).add(debtWrapper);
                                    }
                                }
                            }
                        }
                    }
                }
                if(partnerDebt.debtGroup != null){
                    for (JSONCustomersContractsBillsDebts.DebtGroup debt : partnerDebt.debtGroup) {
                        if(debt.extractItems != null){
                            for(JSONCustomersContractsBillsDebts.ExtractItem extract : debt.extractItems){
                                BillDebtsWrapper debtWrapper = new BillDebtsWrapper();
                                debtWrapper.dueDate = formatDate(extract.dueDate.split('T')[0]);
                                debtWrapper.entryDate = formatDate(extract.entryDate.split('T')[0]);
                                debtWrapper.installmentNumber = String.valueOf(extract.installmentNumber);
                                debtWrapper.itemDescription = extract.itemDescription;
                                debtWrapper.partnerId = returnPartner(partnerDebt.partnerId);
                                debtWrapper.totalInstallments = String.valueOf(extract.totalInstallments);
                                debtWrapper.amount = String.valueOf(extract.sourceValue);
                                debtWrapper.sortentryDate = extract.entryDate.split('T')[0];
                                debtWrapper.productDescription = extract.productDescription;

                                if (extract.proportionality != null) {
                                    debtWrapper.proportionalityEntryDate = '';
                                    for (JSONCustomersContractsBillsDebts.Proportionality proportion : extract.proportionality) {
                                        debtWrapper.proportionalityEntryDate += proportion.message+'; ';
                                    }
                                }

                                if(!mapGroupDebts.containsKey(debt.groupId)){
                                    mapGroupDebts.put(debt.groupId, new List<BillDebtsWrapper>());
                                    mapGroupDebtsDescription.put(debt.groupId, debt.groupDescription);
                                }
                                mapGroupDebts.get(debt.groupId).add(debtWrapper);
                            }
                        }
                    }
                }
            }
        }

        if(!mapGroupDebts.isEmpty()){
            for(Integer key : mapGroupDebts.keySet()){
                GroupBillDebtsWrapper groupDebt = new GroupBillDebtsWrapper();
                groupDebt.groupId = key;
                groupDebt.groupDescription = mapGroupDebtsDescription.get(key);
                groupDebt.debts = mapGroupDebts.get(key);
                lstGroups.add(groupDebt);
            }
        }

        return lstGroups;
    }

    private static ResponseWrapper setErrorMessage(JSONCustomersContractsBillsDebts jsonObject){

        ResponseWrapper wrapper = new ResponseWrapper();
        if(jsonObject != null){
            if(jsonObject.error != null){
                wrapper.errorMessage = jsonObject.error.errorCode + ' - ' + jsonObject.error.detailedMessage;
            }else{
                wrapper.errorMessage = 'Unknown error';
            }
        }else{
            wrapper.errorMessage = 'Unknown error';
        }
        
        return wrapper;
    }

    private static String formatDate(String dateString){
        System.debug(dateString);
        List<String> lstDate = dateString.split('-');
        dateString = lstDate[2] + '/' + lstDate[1] + '/' + lstDate[0];

        System.debug(dateString);
        return  dateString;
    }
    private static String returnPartner(Integer partnerId){
        String partnerName;
        switch on partnerId {
            when  1 { partnerName = 'NET';}
            when  2 { partnerName = 'EMBRATEL';}
            when  16 { partnerName = 'CLARO';}
            when else {
                partnerName = 'OUTROS';
            }
        }
        return partnerName;
    }


    public class ResponseWrapper 
    {
        @AuraEnabled Public Integer responseCode;
        @AuraEnabled Public string errorMessage;
        @AuraEnabled Public List<GroupBillDebtsWrapper> groupDebts;
    }

    public class GroupBillDebtsWrapper 
    {
        @AuraEnabled Public Integer groupId;
        @AuraEnabled Public string groupDescription;
        @AuraEnabled Public List<BillDebtsWrapper> debts;
    }
    
    public class BillDebtsWrapper 
    {
        @AuraEnabled Public string itemDescription;
        @AuraEnabled Public string amount;
        @AuraEnabled Public string dueDate;
        @AuraEnabled Public string proportionalityEntryDate;
        @AuraEnabled Public string installmentNumber;
        @AuraEnabled Public string entryDate;
        @AuraEnabled Public string sortentryDate;
        @AuraEnabled Public string partnerId;
        @AuraEnabled Public string totalInstallments;
        @AuraEnabled Public string productDescription;
	}
}