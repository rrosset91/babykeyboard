/*
* @author: Diogo Domingos
* @company: IBM - Bluewolf
* @description: Classe com objetivo de gerar o JSON para requisição POST do serviço "InvoiceRefund"
*/
public class JSONInvoiceRefundRequest 
{
	public String application;
    public Data data;
    
    public class Data 
    {
        public String areaCode;
        public String contractNumber;
        public String description;
        public String identifierType;
        public String login;
        public String name;
		public String note;
		public String operatorCode;
        public String sourceEvent;
        public String telephoneNumber;
    }
}