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

    @IsTest
    static void insertOfferMatrixOk(){
        Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        Parameters__c newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='0',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );

        Test.startTest();
            insert(newParam);
            List<Parameters__c> lstParam = [SELECT Id FROM Parameters__c WHERE Name = 'testParameterOk'];
            System.assertEquals(1, lstParam.size());
        Test.stopTest();

    }

    @IsTest
    static void deleteOfferMatrixOk(){
        Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        Parameters__c newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='0',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );

        Test.startTest();
            insert(newParam);
            List<Parameters__c> lstParam = [SELECT Id FROM Parameters__c WHERE Name = 'testParameterOk'];
            delete(lstParam);
            List<Parameters__c> deletParam = [SELECT Id FROM Parameters__c WHERE Name = 'testParameterOk'];
            System.assertEquals(0, deletParam.size());
        Test.stopTest();

    }

    @IsTest
    static void insertOfferMatrixError(){
        Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        Parameters__c newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='2',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );
        String exMessage;
        List<String> splitStringMessage;
        Test.startTest();
        try {
            insert(newParam);
        } catch(Exception e) {
            System.debug('exMessage==>' +e.getMessage());
            exMessage = e.getMessage();
            splitStringMessage = exMessage.split('\\.');
        }
        System.assertEquals('Insert failed', splitStringMessage[0]);

        Test.stopTest();

    }
    @IsTest
    static void deleteOfferMatrixError(){
        Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        List<Parameters__c> insertParam = new List<Parameters__c>();
        Parameters__c newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='0',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );
        insertParam.add(newParam);
        newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='1',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );
        insertParam.add(newParam);

        String exMessage;
        List<String> splitStringMessage;

        Test.startTest();
            insert(insertParam);
            List<Parameters__c> lstParam = [SELECT Id FROM Parameters__c WHERE Name = 'testParameterOk' AND Installments__c = '0'];
            System.debug('lstParam==>' +lstParam);
            Solar_Cross_ParametersHandler.firstRun=true;
            try {
                delete(lstParam);
            } catch(Exception e) {
                exMessage = e.getMessage();
                System.debug('exMessage==>' +exMessage);

                splitStringMessage = exMessage.split('\\.');
                System.debug('splitStringMessage==>' +splitStringMessage);

            }
            System.assertEquals('Delete failed', splitStringMessage[0]);
        Test.stopTest();

    }

    @IsTest
    static void updateOfferMatrixOK(){
        Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        List<Parameters__c> insertParam = new List<Parameters__c>();
        Parameters__c newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='0',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );
        insertParam.add(newParam);
        newParam = new Parameters__c (
            DefaultTargeting__c= 'MÉDIO',
            AnatelProconProneTargeting__c='1',
            Segment__c='BLACK',
            Name='testParameterOk',
            Active__c=true,
            Installments__c='1',
            InstallmentDiscount__c=30,
            DebtLimitValue__c=400.00,
            RecordTypeId = OFFER_MATRIX_RECTYPE
        );
        insertParam.add(newParam);

        String exMessage;
        List<String> splitStringMessage;
        insert(insertParam);
        List<Parameters__c> lstParam = [SELECT Id,InstallmentDiscount__c  FROM Parameters__c WHERE Name = 'testParameterOk' AND Installments__c = '0'];
        System.debug('lstParam==>' +lstParam);

        Test.startTest();

            Solar_Cross_ParametersHandler.firstRun=true;

            lstParam[0].InstallmentDiscount__c = 29;
            update(lstParam);

            List<Parameters__c> assertParam = [SELECT Id, InstallmentDiscount__c FROM Parameters__c WHERE Name = 'testParameterOk' AND Installments__c = '0'];
            System.assertEquals(29, assertParam[0].InstallmentDiscount__c);

        Test.stopTest();

    }
}