/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 23/01/2020 
* Descrição: [CEC - Extensão Fase 2] - [Time: SQUAD Canais Criticos - Sprint 17] - 
*	         Classificação dos casos para tratativa de integração (tabulações)
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
public class CEC_CC_ClassificationMdtDAO  
{
    
    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassificationType(Set<String> setBUs, Set<String> setProducts)
    {
        return getClassificationTypeRecordTypeNull(setBUs, setProducts, null, false);
    }

    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassificationType(Set<String> setBUs, Set<String> setProducts, Set<String> recordTypeDeveloperName)
    {
        return getClassificationTypeRecordTypeNull(setBUs, setProducts, recordTypeDeveloperName, false);
    }
    
    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getAllClassificationType()
    {
        return getClassificationTypeRecordTypeNull(null, null, null, false);
    }

    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassificationTypeRecordTypeNull(Set<String> setBUs, Set<String> setProducts)
    {
        return getClassificationTypeRecordTypeNull(setBUs, setProducts, null, true);
    }

    private static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassificationTypeRecordTypeNull(Set<String> setBUs, Set<String> setProducts, Set<String> recordTypeDeveloperName, Boolean nullRecordType)
    {
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = new Map<String, Map<String, CEC_CC_PS8Classification__mdt>>();
        
        String soql  = 'SELECT BusinessUnit__c, Company__c, ChannelRequestId__c, '+
                       'ContactTypeId__c, Description__c, Product__c, '+ 
                       'Result__c, Situation__c, Legacy__c, ReasonCode1__c, '+
                       'ReasonCode2__c, ReasonCode3__c, ReasonCode4__c, ReasonCode5__c, '+
                       'LengthField__c, Mask__c, MaskMessage__c, RecordType__c '+
                       'FROM CEC_CC_PS8Classification__mdt ';

        Boolean filterByBusAndProducts = setBUs != null && !setBUs.isEmpty() && setProducts != null && !setProducts.isEmpty();               
        Boolean filterByRecordType = recordTypeDeveloperName != null && !recordTypeDeveloperName.isEmpty();               
        if(filterByBusAndProducts)               
        {
            soql +=  'WHERE BusinessUnit__c IN :setBUs '+
                     'AND Product__c IN :setProducts ';
        }

        if(nullRecordType)
        {
            soql +=  (filterByBusAndProducts ? 'AND ' : 'WHERE ') + 'RecordType__c = NULL '; 
        }
        else if(filterByRecordType)
        {
            soql +=  (filterByBusAndProducts ? 'AND ' : 'WHERE ') + 'RecordType__c IN :recordTypeDeveloperName '; 
        }

        for(CEC_CC_PS8Classification__mdt classification : Database.query(soql))
        {
            String key = filterByRecordType ? classification.BusinessUnit__c+classification.RecordType__c : classification.BusinessUnit__c;

            if(!mapClassification.containsKey(key)){
                mapClassification.put(key, new Map<String, CEC_CC_PS8Classification__mdt>());
            }
            
            if(!mapClassification.get(key).containsKey(classification.Product__c)){
                mapClassification.get(key).put(classification.Product__c, classification);
            }            
        }    

        return mapClassification;
    }
}