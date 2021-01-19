/**
 * @description       : Classe wrapper padrao para retorno de api
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos-Atendimentos
 * @last modified on  : 30-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/

public with sharing class JSONBasicStructure {
    public String apiVersion;
	public String transactionId;
	public Data data;

	public class Data {
		public Object response;
	}
}