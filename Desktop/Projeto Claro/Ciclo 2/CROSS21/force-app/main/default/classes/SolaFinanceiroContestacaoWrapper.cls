/**
 * @description       : Wrapper de envio de dados para o componente LWC solarFinanceiroContestacao
 * @author            : Diogo Domingos
 * @group             : IBM

 * @last modified on  : 11-06-2020

 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-05-2020   Diogo Domingos
**/
    public without sharing class SolaFinanceiroContestacaoWrapper 
    {
        @AuraEnabled

	public Long itemId;
	@AuraEnabled

        public String item;
        @AuraEnabled
        public String lineNumber;
        @AuraEnabled
        public Decimal saldo;
        @AuraEnabled
        public Decimal valorOriginal;
        @AuraEnabled


        public Decimal valorCorrigido;
    }