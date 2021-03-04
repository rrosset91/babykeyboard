/*
* Author: Cintia Souza - Squad visão 360 
* Change: Renan S.de Freitas - Squad visão 360
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Classe de teste da CEC_360_ShowCasesController
* 
*
* ---------------------------------------------------------------
*/
public with sharing class CEC_360_ShowCasesController
{
    public class CEC_360_ShowCasesControllerException extends Exception {}
    
	@AuraEnabled
    public static List<String> getAssetsByBillingAccount(String billingAcountId)
    {
        
        Set<String> setMSISDNId = new Set<String>();
        List<Asset> assets = [SELECT msisdn__c
                                 FROM Asset 
                                 WHERE vlocity_cmt__BillingAccountId__c = :billingAcountId
                                 AND businessunit__c != 'Net'];
        
        for(Asset varAsset : assets)
            setMSISDNId.add(varAsset.msisdn__c);
        
        return new List<String>(setMSISDNId);
    }
    
    @AuraEnabled
    public static DateInfo getDates()
    {
        DateInfo dateInfo = new DateInfo();
        Date today = System.today();
        
		dateInfo.endDate = today;
		dateInfo.startDate = today.addMonths(-5);
		dateInfo.minDate = dateInfo.startDate;
		dateInfo.maxDate = dateInfo.endDate;      
        
        return dateInfo;    
    }


    @AuraEnabled
	public static ResultWrapper getDataRecord(String recordId, string objectAPI)
    {
		ResultWrapper res = new ResultWrapper();
		if('Asset'.equalsIgnoreCase(objectAPI))
        {
			Asset varAsset = [SELECT Id, RecordType.Name, MSISDN__c FROM Asset where Id = :recordId];
			res.recordTypeName = varAsset.RecordType.Name;
			res.dataContract = String.isNotBlank(varAsset.MSISDN__c) ? varAsset.MSISDN__c : '';
		}
        else if('Account'.equalsIgnoreCase(objectAPI))
        {
			res.recordTypeName = '';
            res.dataContract = [Select ContractNumber__c FROM Account where Id = :recordId].ContractNumber__c;
            res.businessUnit = [SELECT BusinessUnit__c FROM Account WHERE Id = :recordId].BusinessUnit__c;
            
		}
        
		return res;
	}
    
    @AuraEnabled
    public static map<String, String> getPicklistValueByLabel(String varObject, String varField) {
        map<String, String> mapStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel(varObject, varField);
        return mapStatusPickValByLabel;
    }
    
    public static void validateDate(DateTime startDate, DateTime endDate)
    {
        if(startDate.addMonths(6) < endDate)
        {
            throw new CEC_360_ShowCasesControllerException('O período máximo permitido para consulta é de 6 meses');
        }
        
        if(startDate > endDate)
        {
          throw new CEC_360_ShowCasesControllerException('Data início não pode ser maior que a data fim');  
        }
    }
    
    @AuraEnabled
    public static List<TreeCases> getCasesContract (string parentId, String dataIni, String dataFim, String status) 
    {
        
        String dateIniAux = dataIni + ' 00:00:00';
        String dateFimAux = dataFim + ' 23:00:00';
        
        DateTime varDataIni = DateTime.valueOf(dateIniAux);
        DateTime varDateFim = DateTime.valueOf(dateFimAux);

        varDataIni = varDataIni.addDays(0);
		varDateFim = varDateFim.addDays(0);
       
        
        system.debug('varDateFim: ' + varDateFim);
        system.debug('parentId: ' + parentId);
        system.debug('varDataIni: ' + varDataIni);
        system.debug('status: ' + status);
        
       
       
        
        validateDate(varDataIni, varDateFim);
        
        String txt_Query = 'SELECT Id, CaseNumber, CreatedDate, Description, Channel__c, Status,' +
            'Contact.Name, Priority, ClosedDate, Owner.Name, Resolution__c, Type, ResolvedBy__c ' + 
            'FROM Case WHERE ContractBillingAccount__c =: parentId ' + 
            'AND CreatedDate >=: varDataIni AND CreatedDate <=:  varDateFim ';
        
        if(String.isNotBlank(status) && String.isNotEmpty(status))
            txt_Query = txt_Query + 'AND Status =: status ';
        
        txt_Query = txt_Query + 'ORDER BY CreatedDate DESC';
        
        system.debug(txt_Query);
        
        List<sObject> lstCases = Database.Query(txt_Query);    
        
        return formatToWrapper(lstCases);
    }

    @AuraEnabled
    public static List<TreeCases> getCasesAsset (string parentId, String dataIni, String dataFim, String status) 
    {
        
        String dateIniAux = dataIni + ' 00:00:00';
        String dateFimAux = dataFim + ' 23:00:00';
        
        DateTime varDataIni = DateTime.valueOf(dateIniAux);
        DateTime varDateFim = DateTime.valueOf(dateFimAux);

        varDataIni = varDataIni.addDays(0);
		varDateFim = varDateFim.addDays(0);
       
        
        system.debug('varDateFim: ' + varDateFim);
        system.debug('parentId: ' + parentId);
        system.debug('varDataIni: ' + varDataIni);
        system.debug('status: ' + status);
        
        validateDate(varDataIni, varDateFim);
                
        String txt_Query = 'SELECT Id, CaseNumber, CreatedDate, Description, Channel__c, Status,' +
            'Contact.Name, Priority, ClosedDate, Owner.Name, Resolution__c, Type, ResolvedBy__c ' + 
            'FROM Case WHERE LineNumber__c  =: parentId ' + 
            'AND CreatedDate >=: varDataIni AND CreatedDate <=:  varDateFim ';
        
        if(String.isNotBlank(status) && String.isNotEmpty(status))
            txt_Query = txt_Query + 'AND Status =: status ';
        
        txt_Query = txt_Query + 'ORDER BY CreatedDate DESC';
        
        system.debug(txt_Query);
        
        List<sObject> lstCases = Database.Query(txt_Query);    
        
        return formatToWrapper(lstCases);
    }
    
    public static List<TreeCases> formatToWrapper(List<Case> lstCases)     
    {
        map<String, String> mapStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Status');
        map<String, String> mapPriorityPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Priority');
        map<String, String> mapResolvedPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'ResolvedBy__c');
        
        List<TreeCases> lstTree = new List<TreeCases>();
        
        for(Case varCase : lstCases)
        {
            TreeCases obj = new TreeCases();
            obj.Id = varCase.Id;
            obj.caseNumber = varCase.CaseNumber;
            obj.createdDate = varCase.CreatedDate;
            obj.description = varCase.Description;
            obj.channel = varCase.Channel__c;
            obj.status = (String.isNotBlank(varCase.Status)) ? mapStatusPickValByLabel.get(varCase.Status) : '';
            obj.contactName = varCase.Contact.Name;
            obj.type = varCase.Type;
            obj.priority = (String.isNotBlank(varCase.Priority)) ? mapPriorityPickValByLabel.get(varCase.Priority) : '';
            obj.closedDate = varCase.ClosedDate;
            obj.ownerName = varCase.Owner.Name;
            obj.resolvedBy = (String.isNotBlank(varCase.ResolvedBy__c)) ? mapResolvedPickValByLabel.get(varCase.ResolvedBy__c) : '';
            obj.resolutionInfo = varCase.Resolution__c;
            obj.showDetails = false;
            lstTree.add(obj);
        }
        
        return lstTree;        
    }

    @AuraEnabled
    public static Boolean getCriticalChannels()
    {
        return FeatureManagement.checkPermission('Perfil_Canais_Criticos');                
    }
    
    public class DateInfo {
        @AuraEnabled public Date endDate;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date minDate;
        @AuraEnabled public Date maxDate;
    }
    
    public class TreeCases
    {
        @AuraEnabled public String Id;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String description;
        @AuraEnabled public String channel;
        @AuraEnabled public String status;
        @AuraEnabled public String contactName;
        @AuraEnabled public String type;
        @AuraEnabled public String priority;
        @AuraEnabled public Datetime closedDate;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String resolvedBy;
        @AuraEnabled public String resolutionInfo;
        @AuraEnabled public Boolean showDetails;        
    }


    public class ResultWrapper {
		@AuraEnabled public string recordTypeName;
        @AuraEnabled public string dataContract;
        @AuraEnabled public string businessUnit;
        
	}


}