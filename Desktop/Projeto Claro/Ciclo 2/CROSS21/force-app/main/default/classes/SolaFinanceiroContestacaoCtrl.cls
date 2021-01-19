/**

 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 11-12-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   12-11-2020   Joao Neves   Initial Version
 **/
public without sharing class SolaFinanceiroContestacaoCtrl {
	@AuraEnabled(cacheable=true)
	public static List<SolaFinanceiroContestacaoWrapper> getInvoices(String contractId) {
		List<SolaFinanceiroContestacaoWrapper> lst = new List<SolaFinanceiroContestacaoWrapper>();

		SolaFinanceiroContestacaoWrapper wrp = new SolaFinanceiroContestacaoWrapper();
		wrp.itemId = 2039904;

        wrp.item = 'Cloudhub Claro';
        wrp.lineNumber = '13999187721';
        wrp.saldo = 145000;
        wrp.valorOriginal = 55016;
        lst.add(wrp);

        return lst;
    }


}