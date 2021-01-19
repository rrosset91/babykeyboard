/* Autor: Magno Rocha - Deloitte 
Criação: 06/05/2019
Descrição: Classe teste para a classe customLookUpController.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360*/

@isTest
public class customLookUpControllerTest {

    static testMethod void testCustomLookupController(){

		customLookUpController.fetchLookUpValues('323', 'CEC_City_CarrierCode__mdt' , 'CodigoOperadora__c');
    }
}