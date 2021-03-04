/*Versão 2.0
* - Lucas Barbosa - 09/04/2019 
	Consolidação dos dados da venda para realizar a chamada do RDA via post https
* - Henrique Almeida - 14/06/2019 
	Inclusão de dados para a criação de novo HP.
*/
public without sharing class CEC_SendToRobotController
{  
    @AuraEnabled
    public static String getObjects(String idObj)
    {
        list<Order> lLstObj = [select Id, 
                               Account.Name, 
                               Account.MothersName__c, 
                               Account.Phone,
                               Account.DocumentNumber__c,
                               Account.BirthDate__c, 
                               Account.MaritalStatus__c, 
                               Account.Occupation__c, 
                               Account.SalaryRange__c,
                               Account.Gender__c,
                               Account.Origin__c,
                               Account.Email__c,
                               Account.CellPhone__c,
                               Account.Media__c,
                               Account.CNPJFormula__c,
                               Account.DocumentType__c,
                               Account.RG__c,
                               Account.RGEmitter__c,
                               Account.StateSubscription__c,
                               Account.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                               Account.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                               BillingPostalCode,
                               Forma_de_Pagamento__c,
                               TipoFatura__c,
                               DiaVencimento__c,
                               Banco__c,
                               Agencia__c,
                               DvAgencia__c,
                               NumeroConta__c,
                               DvConta__c,
                               BillingNumber__c,
                               BillingStreet,
                               TipoComplemento1__c,
                               Complemento1__c,
                               TipoComplemento2__c,
                               Complemento2__c,
                               TipoComplemento3__c,
                               Complemento3__c,
                               TipoComplemento4__c,
                               Complemento4__c,
                               NovoEndereco__c,
                               NumeroHP__c,
                               ShippingNumber__c,
                               Unidade__c,
                               Premises__r.vlocity_cmt__PostalCode__c
                               from Order where Id = : idObj.length() > 25 ? idObj.right(18): idObj.right(15)];
        
        list<OrderItem> lstOrderItem = [Select Id, 
                                        NumeroProvisorio__c, 
                                        DDD__c,
                                        MSISDN__c,
                                        Product2.vlocity_cmt__SubType__c,
                                        Product2.Unidade__c,
                                        vlocity_cmt__SerialNumber__c
                                        from orderItem where OrderId = : idObj.length() > 25 ? idObj.right(18): idObj.right(15)
                                        ORDER BY vlocity_cmt__LineNumber__c, CreatedDate ASC];
        
        map<String, Object> mapObj = new map<String,object>();
        
        if(!lLstObj.isEmpty()){
			mapObj.put('sTipoProduto', lLstObj[0].Unidade__c);            
            mapObj.put('sIdVenda', lLstObj[0].Id);
            mapObj.put('sStatus', 'Ativa');
            mapObj.put('sNomeProspect', lLstObj[0].Account.Name);
            mapObj.put('sCEP', lLstObj[0].BillingPostalCode);
            //mapObj.put('sGenero', lLstObj[0].Account.Gender__c);
            mapObj.put('sGenero', 'Masculino');
            //mapObj.put('sEstadoCivil', lLstObj[0].Account.MaritalStatus__c);
            mapObj.put('sEstadoCivil', 'Outros');
            //mapObj.put('sProfissao', lLstObj[0].Account.Occupation__c);
            mapObj.put('sProfissao', 'Não informado');
            //mapObj.put('sFaixaSalarial', lLstObj[0].Account.SalaryRange__c);
            mapObj.put('sFaixaSalarial', 'Não possui');
            mapObj.put('sEscolaridade', 'Não informado');
            mapObj.put('sNomeDaMae', lLstObj[0].Account.MothersName__c == null ? '' : lLstObj[0].Account.MothersName__c);
            //mapObj.put('sOrigemCliente', lLstObj[0].Account.Origin__c);
            mapObj.put('sOrigemCliente', 'Novo Comprador');
            mapObj.put('sEmail', lLstObj[0].Account.Email__c == null ? '' : lLstObj[0].Account.Email__c);
            //mapObj.put('sDDD', String.isNotEmpty(lLstObj[0].Account.Phone) ? lLstObj[0].Account.Phone.substring(0, 2) : '');
            mapObj.put('sTelefoneFixo', lLstObj[0].Account.Phone == null ? '' : lLstObj[0].Account.Phone);
			//mapObj.put('sDDDCel', String.isNotEmpty(lLstObj[0].Account.CellPhone__c) ? lLstObj[0].Account.CellPhone__c.substring(0, 2) : '');
            mapObj.put('sCelular', lLstObj[0].Account.CellPhone__c);     
            mapObj.put('sMidia', lLstObj[0].Account.Media__c == null ? '' : lLstObj[0].Account.Media__c); 
            mapObj.put('sEstado', lLstObj[0].Account.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c);
            mapObj.put('sCidade', lLstObj[0].Account.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c);
            mapObj.put('sBairro', 'Bairro Teste');           
            mapObj.put('sTipoDocumento', lLstObj[0].Account.DocumentType__c);            
           
            if(lLstObj[0].Account.DocumentType__c.equals('CPF'))
            {
                mapObj.put('sOrgaoExpedidor', 'NAO INF.');
                mapObj.put('sRG', lLstObj[0].Account.RG__c == null ? '' : lLstObj[0].Account.RG__c);
                mapObj.put('sCPF', lLstObj[0].Account.DocumentNumber__c);
                String dt = Datetime.newInstance(lLstObj[0].Account.BirthDate__c, Time.newInstance(0,0,0,0)).format('dd-MM-yyyy');
                dt = dt.replaceAll('-', '/');
                mapObj.put('sDataNasc', dt);
            }
            else
            {
                mapObj.put('sCNPJ', lLstObj[0].Account.DocumentNumber__c);
                mapObj.put('sIE', lLstObj[0].Account.StateSubscription__c);
            }
            
            // Novos Dados Residencial
            mapObj.put('sTipoCobranca', lLstObj[0].Forma_de_Pagamento__c == null ? '' : lLstObj[0].Forma_de_Pagamento__c);
            mapObj.put('sFormaEnvio', lLstObj[0].TipoFatura__c == null ? '' : lLstObj[0].TipoFatura__c);    
            mapObj.put('sDiaVencimento', lLstObj[0].DiaVencimento__c == null ? '' : lLstObj[0].DiaVencimento__c);
            mapObj.put('sBanco', lLstObj[0].Banco__c == null ? '' : lLstObj[0].Banco__c);
            mapObj.put('sAgencia', lLstObj[0].Agencia__c == null ? '' : lLstObj[0].Agencia__c);
            mapObj.put('sDVAgencia', lLstObj[0].DvAgencia__c == null ? '' : lLstObj[0].DvAgencia__c);
            mapObj.put('sConta', lLstObj[0].NumeroConta__c == null ? '' : lLstObj[0].NumeroConta__c);
            mapObj.put('sDVConta', lLstObj[0].DvConta__c == null ? '' : lLstObj[0].DvConta__c);
            //mapObj.put('sOrgaoExpedidor', lLstObj[0].Account.RGEmitter__c);
            mapObj.put('sNovo', lLstObj[0].NovoEndereco__c);
            //cadastro endereço
            if(lLstObj[0].NovoEndereco__c == true)
            { 
                mapObj.put('sNumEndereco', lLstObj[0].ShippingNumber__c );
                mapObj.put('sLogradouro', lLstObj[0].BillingStreet);
                mapObj.put('sCEP', lLstObj[0].BillingPostalCode);
                mapObj.put('sTipoComplemento1', lLstObj[0].TipoComplemento1__c == null ? '' :lLstObj[0].TipoComplemento1__c);
                mapObj.put('sValorComplemento1', lLstObj[0].Complemento1__c == null ? '' :lLstObj[0].Complemento1__c);
                mapObj.put('sTipoComplemento2', lLstObj[0].TipoComplemento2__c == null ? '' :lLstObj[0].TipoComplemento2__c);
                mapObj.put('sValorComplemento2', lLstObj[0].Complemento2__c == null ? '' :lLstObj[0].Complemento2__c);
                mapObj.put('sTipoComplemento3', lLstObj[0].TipoComplemento3__c == null ? '' :lLstObj[0].TipoComplemento3__c);
                mapObj.put('sValorComplemento3', lLstObj[0].Complemento3__c == null ? '' :lLstObj[0].Complemento3__c);
                mapObj.put('sTipoComplemento4', lLstObj[0].TipoComplemento4__c == null ? '' :lLstObj[0].TipoComplemento4__c);
                mapObj.put('sValorComplemento4', lLstObj[0].Complemento4__c == null ? '' : lLstObj[0].Complemento4__c); 
            }else
            {
                mapObj.put('sHP', lLstObj[0].NumeroHP__c);
            }
            
            
            
        }else{throwException('O Pedido não foi encontrado');}
        
        if(!lstOrderItem.isEmpty()){
            mapObj.put('sTipoPlano', lstOrderItem[0].Product2.vlocity_cmt__SubType__c == 'Pós-Pago' ? 'Claro Conta' : 'Claro Controle');
            mapObj.put('sMSISDNPortabilidade', lstOrderItem[0].vlocity_cmt__SerialNumber__c != null ? lstOrderItem[0].DDD__c + lstOrderItem[0].vlocity_cmt__SerialNumber__c : '');  
            mapObj.put('bNumeroProvisorio', lstOrderItem[0].NumeroProvisorio__c);
            mapObj.put('sDDD', lstOrderItem[0].DDD__c != null ? lstOrderItem[0].DDD__c : '');    
        }else{throwException('O Pedido não contem produtos');}
        
        lLstObj[0].Status = 'Enviado ao Legado';
        update lLstObj;
        system.debug('RoboParams: '+json.serializePretty(mapObj));
        return JSON.serialize(new list<map<String, Object>>{mapObj}, true);
    }
    @AuraEnabled
    /* Metodo para exibir a mensagem de erro */
    public static void throwException(String aMensagem)
    {
        AuraHandledException e = new AuraHandledException(aMensagem);
        e.setMessage(aMensagem);
        throw e;
    }    
}