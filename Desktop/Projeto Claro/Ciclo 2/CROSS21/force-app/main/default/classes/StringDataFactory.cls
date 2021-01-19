/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Fake String)
* @date: 16-09-2020
*/
@isTest
public with sharing class StringDataFactory {
	//********** Este metodo gera strings aleatorias na forma desejada ************
    public static String getMockString(String stringSample){
        String requiredData;
        switch on stringSample{
            when 'Name' {
                requiredData = 'Firstname Lastname';
            }
            when 'Email' {
                requiredData = 'randomemail'+IntegerDataFactory.getMockInteger()+'@fakeMockEmail.com';
            }
            when 'Word' {
                requiredData = 'Mock';
            }
            when else {
                requiredData = null;
            }
        }
        return requiredData;
    }
}