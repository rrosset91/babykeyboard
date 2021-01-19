/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Case)
* @date: 16-09-2020
*/
@isTest
public with sharing class CaseDataFactory {

    //********** Este metodo recebe como parametro o nome do tipo de registro e Id da conta associada e gera um caso**********
    public static Case getSingleCase(String recordTypeName, String accId){
        Case cs = new Case();
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            cs.OpenDateRobot__c = System.now();
            cs.ContractBillingAccount__c = accId;
            cs.Status = 'New';
            cs.Subject = StringDataFactory.getMockString('Word');
            cs.ProtocolNumber__c = String.valueOf(IntegerDataFactory.getMockInteger());
        system.debug('@@SingleCase -->'+cs);
        return cs;
    }
   
    //********** Este metodo recebe como parametro o nome do tipo de registro o Id da conta associada e quantidade desejada e gera uma lista com a quantidade de casos informada**********
    public static List<Case> getMultipleCases(String recordTypeName, String accId, Integer amount){
        Integer x = 1;
        List<Case> caseList = new List<case>();
        while (x <= amount){
        Case cs = new Case();
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            cs.OpenDateRobot__c = System.now();
            cs.ContractBillingAccount__c = accId;
            cs.Status = 'New';
            cs.Subject = StringDataFactory.getMockString('Word')+String.valueOf(x);
            cs.ProtocolNumber__c = String.valueOf(IntegerDataFactory.getMockInteger());
            caselist.add(cs);
            x++;
        }
        system.debug('@@@CasesList -->'+caseList);
        return caseList;
    }
}