/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 

 * @last modified on  : 12-10-2020

 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-09-2020   lucas.soldi@ibm.com   Initial Version
**/

public class Solar_Cross_OutageResidential {

    public static Map<String,String> mapIcons = new Map<String,String>{
        'CORRETIVA' => 'utility:clear',
        'PREVENTIVA' => 'utility:ban',
        'INFORMATIVA' => 'utility:success'

    };

    public static Map<String,String> mapVariants = new Map<String,String>{
        'utility:ban' => 'warning',
        'utility:success' => 'success',
        'utility:clear' => 'error'
    };

    public static Map<String,Integer> mapWeight = new Map<String,Integer>{

        'CORRETIVA' => 3,
        'PREVENTIVA' => 2,
        'INFORMATIVA' => 1
    };

    public static String globalVariant = 'INFORMATIVA';



    @AuraEnabled
    public static Boolean getContractType(String recordId){
        System.debug('Get Contract Type: '+recordId);
        Boolean bolReturn;
        Case objCase = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c FROM Case WHERE Id = :recordId LIMIT 1];
        List<String> lstMobileContracts = Label.Solar_Cross_MobileContract.split(';');
        List<String> residentialContracts = Label.Solar_Cross_ResidentialContract.split(';');

        if(lstMobileContracts.contains(objCase.ContractBillingAccount__r.BusinessUnit__c)){
            bolReturn = false;
        }else{
            bolReturn = true;
        }
        System.debug('Get Contract Type Return: '+bolReturn);
        return bolReturn;
    }

    @AuraEnabled
    public static Map<String,Object> getOutages(String recordId, String strStartDate, String strEndDate){ 
        System.debug('Entrou no outages:'+ recordId);
        System.debug('Dates: ' + strStartDate+' // ' +strEndDate );
        Map<String, Object> data = new Map<String, Object>();
        List<Case> lstCase = [SELECT Id, ContractBillingAccount__r.ContractNumber__c,ContractBillingAccount__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c FROM Case WHERE Id =: recordId];
        String operatorCode = lstCase[0].ContractBillingAccount__r.CityCode__c;
        String contractNumber =lstCase[0].ContractBillingAccount__r.ContractReferenceNumber__c;
        String startDate = strStartDate==null? convertDate(Date.today().addDays(-30)) : strStartDate;
        String endDate = strEndDate==null? convertDate(Date.today()) : strEndDate;

        List<DataFields> lstReturn = new List<DataFields>();
        ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('GetOutage');

        Map<String, String> headers = new Map<String, String>();
        headers.put('x-client-auth', metaParameter.token__c);
        headers.put('X-QueryString', 'operatorCode='+operatorCode+'&contractNumber='+contractNumber);

        Map<String,String> queryParams = getQueryParams(startDate,endDate, operatorCode,contractNumber);

        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', queryParams, headers, 'GetOutage');

        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
            OutagesReleaseJson releaseJson = (OutagesReleaseJson) JSON.deserialize(calloutResponse.get('response'), OutagesReleaseJson.class);
            if(releaseJson.data.installments != null){
                lstReturn = proccessOutages(releaseJson);
                lstReturn.sort();
                List<DataFields> lstDataFields1ByType =  getFirstProductTypes(lstReturn);
    
                ImportantOutage objimportantOut = new ImportantOutage();
                objimportantOut.iconUsed = mapIcons.get(globalVariant);
                objimportantOut.variantIcon = mapVariants.get(mapIcons.get(globalVariant));
    
                data.put('success', true);
                data.put('outages', lstReturn);
                data.put('outagesFirst', lstDataFields1ByType);
                data.put('objimportantOut',objimportantOut);
                System.debug('lstReturn'+lstReturn);
            }else{
                data.put('success', true);
			    data.put('message', Label.Solar_Cross_IntegrationNoData);
            }
		} else {
			data.put('success', false);
			data.put('message', Label.Solar_Cross_IntegrationErrorMessage + '\n'+'Código do Erro: ' + calloutResponse.get('statusCode') + ' | ' +  metaParameter.EndPoint__c.subStringAfter(':'));
        }
        return data;

    }

    public static String convertDate(Date dateParam){
        return dateParam.day() + '/' +dateParam.month() + '/' +dateParam.year();
    }

    public static Map<String,String> getQueryParams(String startDate, String endDate, String operatorCode, String contractNumber){
        Map<String,String> mapReturn = new Map<String,String>();
       // mapReturn.put('contractNumber',contractNumber);
       // mapReturn.put('operatorCode',operatorCode);
        mapReturn.put('startDate',startDate);
        mapReturn.put('endDate',endDate);

        return mapReturn;

    }

    public static List<DataFields> proccessOutages(OutagesReleaseJson outages){
        List<DataFields> lstReturn = new List<DataFields>();
        String outgeNum;
        for(OutagesReleaseJson.Installments objInstallment: outages.data.installments){
            outgeNum = objInstallment.OutageNumber;
            for(OutagesReleaseJson.productsOutages prodOutage : objInstallment.products){
                DataFields objDataField = new DataFields();
                objDataField.productType = prodOutage.productType;
                objDataField.affectedServices = prodOutage.affectedServices;

                List<String> dateSplit = prodOutage.StartDate.split('/');
                objDataField.StartDate = Date.newInstance(Integer.valueOf(dateSplit[2]),Integer.valueOf(dateSplit[1]),Integer.valueOf(dateSplit[0]));
                if(prodOutage.EndDate != null){
                	List<String> dateSplitEnd = prodOutage.EndDate.split('/');
                    objDataField.EndDate = Date.newInstance(Integer.valueOf(dateSplitEnd[2]),Integer.valueOf(dateSplitEnd[1]),Integer.valueOf(dateSplitEnd[0]));
                }
                if(prodOutage.previsionDate != null){
                    List<String> dateSplitPrevision = prodOutage.previsionDate.split('/');
                	objDataField.PrevisionDate = Date.newInstance(Integer.valueOf(dateSplitPrevision[2]),Integer.valueOf(dateSplitPrevision[1]),Integer.valueOf(dateSplitPrevision[0]));
                }
                objDataField.status = prodOutage.status;
                objDataField.symptom = prodOutage.symptom;
                objDataField.variant = prodOutage.variant;
                objDataField.nature = convertCoverageToNature(prodOutage.coverage);
                objDataField.coverage = prodOutage.coverage;
                objDataField.responsible = prodOutage.responsible;
                objDataField.OutageNumber = outgeNum;
                objDataField.iconUsed = mapIcons.get(objDataField.nature);
                objDataField.variantIcon = mapVariants.get(mapIcons.get(objDataField.nature));
                objDataField.showMoreInfo = objDataField.nature == 'CORRETIVA' ? true : false;
                objDataField.comparableStartDate = Date.newInstance(Integer.valueOf(dateSplit[2]),Integer.valueOf(dateSplit[1]),Integer.valueOf(dateSplit[0]));


                lstReturn.add(objDataField);
            }
        }

        return lstReturn;
    }

    
    public static List<DataFields> getFirstProductTypes(List<DataFields> outages){
        List<DataFields> lstReturn = new List<DataFields>();
        
        Map<String,DataFields> mapDataFields = new Map<String, DataFields>();
        for(DataFields prodOutage : outages){
            if(mapDataFields.get(prodOutage.affectedServices) == null){
                mapDataFields.put(prodOutage.affectedServices, prodOutage);
                globalVariant = mapWeight.get(prodOutage.nature) > mapWeight.get(globalVariant) ? prodOutage.nature :globalVariant;
            }
        }
        return mapDataFields.values();
    }


    private static String convertCoverageToNature(String strCoverage){
        if(strCoverage != null){
            if(strCoverage.contains('NATUREZA:') && strCoverage.contains('<HR>'))
                return strCoverage.subStringBetween('NATUREZA:','<HR>').Trim();
        }        
        return 'INFORMATIVA';
    }


    public class DataFields implements Comparable{
        @AuraEnabled public String productType;
        @AuraEnabled public String affectedServices;
        @AuraEnabled public Date StartDate;
        @AuraEnabled public Date EndDate;
        @AuraEnabled public String status;
        @AuraEnabled public String symptom;
        @AuraEnabled public String variant;
        @AuraEnabled public String nature;
        @AuraEnabled public String coverage;
        @AuraEnabled public String responsible;
        @AuraEnabled public Date PrevisionDate;
        @AuraEnabled public String OutageNumber; 
        @AuraEnabled public String iconUsed;    
        @AuraEnabled public String variantIcon;
        @AuraEnabled public Boolean showMoreInfo; 
        @AuraEnabled public Date comparableStartDate;

        
        public Integer compareTo(Object compareTo) {
            DataFields dataFields = (DataFields)compareTo;
            if(comparableStartDate == null){
                return 1;
            }

            Date newStartDate = date.valueOf(comparableStartDate);
            Date newComparableDate = date.valueOf(dataFields.comparableStartDate);

            if (newStartDate ==  newComparableDate) return 0;
            if (newStartDate < newComparableDate) return 1;
            return -1;   
        }
    }

    public class ImportantOutage{
        @AuraEnabled public String variantIcon;
        @AuraEnabled public String iconUsed;
    }  
}