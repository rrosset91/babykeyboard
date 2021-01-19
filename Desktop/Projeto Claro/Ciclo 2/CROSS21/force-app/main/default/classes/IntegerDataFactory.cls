/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Random Integer)
* @date: 16-09-2020
*/
@isTest
public with sharing class IntegerDataFactory {
	//********** Este metodo gera Integers aleatorios ************
    public static Integer getMockInteger(){
        Integer randomNumber = Integer.valueof((Math.random() * 1000));
        return randomNumber;
    }
}