/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:     Test class for Solar_Cross_ParametersHandler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-23      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_ParametersHandlerTest {
    private static final Id ATTENDENCE_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AttendanceTree').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Parameters__c> lAttendenceRecordsLst = new List<Parameters__c>{new Parameters__c( RecordTypeId = ATTENDENCE_RECTYPE, 
                                                                                            TypeService__c = 'Negativação', 
                                                                                            Solar_Cross_ServiceModality__c = 'TV', 
                                                                                            EntryReason__c = 'Validação de Contestação de Valores', 
                                                                                            LeavingReason__c = 'Contestação aprovada',
                                                                                            FirstCallResolution__c = false,
                                                                                            Active__c = true,
                                                                                            Journey__c = 'Financial',
                                                                                            Business_Unit__c = 'Net',
                                                                                            Channel__c = 'Anatel'),

                                                                                            new Parameters__c( RecordTypeId = ATTENDENCE_RECTYPE, 
                                                                                            TypeService__c = 'Negativação', 
                                                                                            Solar_Cross_ServiceModality__c = 'TV', 
                                                                                            EntryReason__c = 'Validação de Contestação de Valores', 
                                                                                            LeavingReason__c = 'Contestação aprovada',
                                                                                            FirstCallResolution__c = true,
                                                                                            Active__c = true,
                                                                                            Journey__c = 'Financial',
                                                                                            Business_Unit__c = 'Net',
                                                                                            Channel__c = 'URA')
                                                                                        };
        insert lAttendenceRecordsLst;
    }

    static testMethod void duplicateTest(){
        List<Parameters__c> lInsertDuplicatedRecord = [SELECT Id, Channel__c, Business_Unit__c, FirstCallResolution__c FROM Parameters__c WHERE Channel__c = 'URA'];
        lInsertDuplicatedRecord[0].Id = null;
        
        List<Parameters__c> lUpdateDuplicatedRecordLst = [SELECT Id, Channel__c, Business_Unit__c, FirstCallResolution__c FROM Parameters__c WHERE Channel__c = 'URA'];
        lUpdateDuplicatedRecordLst[0].FirstCallResolution__c = false;
        lUpdateDuplicatedRecordLst[0].Business_Unit__c = 'NET';
        lUpdateDuplicatedRecordLst[0].Channel__c = 'Anatel';        
        
        Test.startTest();
            try{
                insert lInsertDuplicatedRecord;
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.Solar_Cross_ParametersDuplicatedError) ? true : false;
                System.assertEquals(true,expectedExceptionThrown);
            }       
            
            try{
                update lUpdateDuplicatedRecordLst;
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.Solar_Cross_ParametersDuplicatedError) ? true : false;
                System.assertEquals(true,expectedExceptionThrown);
            }       
        Test.stopTest();
    }
}