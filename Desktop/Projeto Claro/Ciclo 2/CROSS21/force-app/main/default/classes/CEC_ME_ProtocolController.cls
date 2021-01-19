/*---------------------------------------------------------------------------------------------------------------
--- Company: Sysmap Solutions
--- Author: Squad Evolutiva = Alexandre Augusto da Costa Farias
--- Update for: Alexandre Augusto da Costa Farias / Bruno Wedderhoff Tissi / David Samerson Sousa Castilho
--- Description: Classe responsável por por controlar protocolos e InteractionId recebidos pela URA "CTI".
--- CreateDate: 01/06/2019
--- UpdateDate: 20/10/2020 - Demanda CTI - Ajuste de duplicidade no CustomerInteractionId.
--- Version: 1.1
---------------------------------------------------------------------------------------------------------------*/

public class CEC_ME_ProtocolController {
    
    public PageReference callRedirect() {
        
        // Recebe e identifica os parametros da URL
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String protocolo = parameters.get('protocolnumber');
        String numeroContrato = parameters.get('contractnumber');
		String codigoCidade = parameters.get('cityCode');
        String unidadeNegocio = parameters.get('BusinessUnit');
        String customerInteractionId = parameters.get('c__customerinteraction');
        
        // Pega Id dos RecordTypes para usar como filtro na query da conta
        Id accountTypeConsumer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();  
        Id accountTypeBilling = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        // Variável para armazenar a conta a ser consultada
        Account conta = new Account();
        
        // Valida se os campos numeroContrato, codigoCidade e unidadeNegocio recebidos na URL sao nulos
        if(String.isNotBlank(numeroContrato) && String.isNotBlank(codigoCidade) && String.isNotBlank(unidadeNegocio)){
            try{
                // Consulta a conta filtrando pelos parametros da URL
                conta = [SELECT ParentId
                         FROM Account
                         WHERE contractReferenceNumber__c =: numeroContrato
                         AND RecordTypeId =: accountTypeBilling
                         AND Parent.RecordTypeId =: accountTypeConsumer
						 AND cityCode__c =: codigoCidade
						 AND BusinessUnit__c =: unidadeNegocio
                         LIMIT 1];
                // Caso o campo ParentId da conta seja nulo, retorna para a pagina de Busca de Clientes
                if(conta == null || String.isBlank(conta.ParentId)){
                    return this.redirectBuscaCliente();
                }
            }catch(queryException e){
                // Em caso de excecao na query, retorna para a pagina de Busca de Clientes
                return this.redirectBuscaCliente();
            }
        }

        else { // Caso os campos da URL sejam nulos, retorna para a pagina de Busca de Clientes
            return this.redirectBuscaCliente();
        }
        
        // Verifica se o campo CustomerInteractionId veio nulo da URL e o protocolo veio valido da URL,
        // entao cria um registro de Customer Interaction
        if(String.isBlank(customerInteractionId) && String.isNotBlank(protocolo)){
            this.createCustomerInteraction(conta.parentId, null, protocolo);            
        }
        
        // Se o protocolo estiver nulo, cria o protocolo
        else if(String.isBlank(protocolo)) {

            //Se tiver o id do customer interaction, busca o registro para verificar se o mesmo ja nao tem protocolo associado
            if(String.isNotBlank(customerInteractionId)) {

                List<vlocity_cmt__CustomerInteraction__c> listaInteracoes = [SELECT Id, ProtocolNumber__c FROM vlocity_cmt__CustomerInteraction__c WHERE Id = :customerInteractionId];

                //Interacao com protocolo, nao precisa realizar processamento, somente redireciona para a tela de conta
                if(listaInteracoes != null && listaInteracoes.size() > 0 && listaInteracoes.get(0) != null && String.isNotBlank(listaInteracoes.get(0).ProtocolNumber__c)) {

                    System.debug('CEC_ME_ProtocolController => Customer Interaction nao criado ou atualizado porque ja existe registro com protocolo ' + listaInteracoes.get(0).ProtocolNumber__c);
                    return this.redirectDadosConta(conta.parentId);

                } 
            }

            //A continuidade do fluxo se da com a necessidade de criar um protocolo, podendo inserir ou atualizar o customer interaction.
            String protocoloLegado = null;
            try {

                CEC_ProtocolNetResponse protocoloCriado = CEC_ProtocolNetService.getResponse(numeroContrato, codigoCidade);
                protocoloLegado = protocoloCriado != null && protocoloCriado.data != null ? protocoloCriado.data.protocolNumber : null;

            } catch(Exception e) {
                System.debug('CEC_ME_ProtocolController => Erro na geracao do protocolo. O Customer Interaction sera criado/atualizado sem a informacao de protocolo.');
                System.debug(e);
            }
            
            this.createCustomerInteraction(conta.parentId, customerInteractionId, protocoloLegado);
        }        
        
        // Apos os processamentos, redireciona para a pagina de visualizacao da conta pai
        return this.redirectDadosConta(conta.parentId);
    }
    
    public void createCustomerInteraction(Id accountId, String customerInteractionId, String protocolo) {
        if(accountId != null) {
            // Cria um novo registro de Customer Interaction
            vlocity_cmt__CustomerInteraction__c newCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
            newCustomerInteraction.Id = String.isNotBlank(customerInteractionId) ? customerInteractionId : null;
            newCustomerInteraction.ProtocolNumber__c = protocolo;
            newCustomerInteraction.vlocity_cmt__AccountId__c = accountId;
            upsert newCustomerInteraction;
            System.debug('CEC_ME_ProtocolController => Customer Interaction criado/atualizado => ' + newCustomerInteraction);
        } else {
            System.debug('CEC_ME_ProtocolController => Customer Interaction nao criado/atualizado porque a conta do cliente nao foi encontrada');
        }
    }

    public PageReference redirectBuscaCliente(){
        System.debug('CEC_ME_ProtocolController => Cliente nao encontrado, redirecionamento para a pesquisa de cliente');
        // Redireciona para a pagina de Busca de Clientes
        PageReference pageReference = new PageReference('/lightning/n/Buscar_Cliente');
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference redirectDadosConta(Id accountId){
        // Redireciona para a pagina de dados da conta
        if(accountId != null) {
            System.debug('CEC_ME_ProtocolController => Cliente encontrado, redirecionamento para a tela de conta');
            PageReference pageReference = new PageReference('/lightning/r/Account/' + accountId + '/view');
            pageReference.setRedirect(true);
            return pageReference;    
        } else  {
            return this.redirectBuscaCliente();
        }
    }
}