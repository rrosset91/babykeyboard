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
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = new Map<String, Map<String, CEC_CC_PS8Classification__mdt>>();
        
        for(CEC_CC_PS8Classification__mdt classification : [SELECT BusinessUnit__c, Company__c, ChannelRequestId__c, 
                                                            ContactTypeId__c, Description__c, Product__c, 
                                                            Result__c, Situation__c, Legacy__c, ReasonCode1__c,
                                                            ReasonCode2__c, ReasonCode3__c, ReasonCode4__c, ReasonCode5__c,
                                                            LengthField__c, Mask__c, MaskMessage__c
                                                            FROM CEC_CC_PS8Classification__mdt 
                                                            WHERE BusinessUnit__c IN: setBUs
                                                            AND Product__c IN: setProducts])
        {
            if(!mapClassification.containsKey(classification.BusinessUnit__c)){
                mapClassification.put(classification.BusinessUnit__c, new Map<String, CEC_CC_PS8Classification__mdt>());
            }
            
            if(!mapClassification.get(classification.BusinessUnit__c).containsKey(classification.Product__c)){
                mapClassification.get(classification.BusinessUnit__c).put(classification.Product__c, classification);
            }
        }
        
        return mapClassification;
    }

    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassificationType(Set<String> setBUs, Set<String> setProducts,Set<String> recordTypeDeveloperName)
    {
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = new Map<String, Map<String, CEC_CC_PS8Classification__mdt>>();
        
        for(CEC_CC_PS8Classification__mdt classification : [SELECT BusinessUnit__c, Company__c, ChannelRequestId__c, 
                                                            ContactTypeId__c, Description__c, Product__c, 
                                                            Result__c, Situation__c, Legacy__c, ReasonCode1__c,
                                                            ReasonCode2__c, ReasonCode3__c, ReasonCode4__c, ReasonCode5__c,
                                                            LengthField__c, Mask__c, MaskMessage__c,RecordType__c
                                                            FROM CEC_CC_PS8Classification__mdt 
                                                            WHERE BusinessUnit__c IN: setBUs
                                                            AND Product__c IN: setProducts
                                                            AND RecordType__c IN: recordTypeDeveloperName ])
        {
            if(!mapClassification.containsKey(classification.BusinessUnit__c+classification.RecordType__c)){
                mapClassification.put(classification.BusinessUnit__c+classification.RecordType__c, new Map<String, CEC_CC_PS8Classification__mdt>());
            }
            
            if(!mapClassification.get(classification.BusinessUnit__c+classification.RecordType__c).containsKey(classification.Product__c)){
                mapClassification.get(classification.BusinessUnit__c+classification.RecordType__c).put(classification.Product__c, classification);
            }
        }
        
        return mapClassification;
    }
    
    public static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getAllClassificationType()
    {
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = new Map<String, Map<String, CEC_CC_PS8Classification__mdt>>();
        
        for(CEC_CC_PS8Classification__mdt classification : [SELECT BusinessUnit__c, Company__c, ChannelRequestId__c,  
                                                            ContactTypeId__c, Description__c, Product__c, 
                                                            Result__c, Situation__c, Legacy__c, ReasonCode1__c,
                                                            ReasonCode2__c, ReasonCode3__c, ReasonCode4__c, ReasonCode5__c,
                                                            LengthField__c, Mask__c, MaskMessage__c
                                                            FROM CEC_CC_PS8Classification__mdt])
        {
            if(!mapClassification.containsKey(classification.BusinessUnit__c)){
                mapClassification.put(classification.BusinessUnit__c, new Map<String, CEC_CC_PS8Classification__mdt>());
            }
            
            if(!mapClassification.get(classification.BusinessUnit__c).containsKey(classification.Product__c)){
                mapClassification.get(classification.BusinessUnit__c).put(classification.Product__c, classification);
            }
        }
        
        return mapClassification;
    }

}