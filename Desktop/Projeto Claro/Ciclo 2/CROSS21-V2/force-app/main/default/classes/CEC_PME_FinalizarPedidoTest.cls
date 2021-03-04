/*
* Autor: Marcos Silva - Deloitte
* Data: 09/01/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe  CEC_PME_FinalizarPedidoController
*/
@isTest
private class  CEC_PME_FinalizarPedidoTest {
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */      
	@testSetup static void setup() {
		CEC_PME_OrderTestMethods.generateAllData();
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do carregamento de dados da tela
    */      
    @isTest static void test() {
    	Order ord = [SELECT Id, Status FROM Order LIMIT 1];
        ord.status = 'Confirmar Entrega';
        update ord;
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        
        System.assertEquals(lstData.size(), 0);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da atualização dos dados do pedido
    */      
    @isTest static void test1() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        
        OrderItem ordItem = [SELECT Id, TypeOfRequest__c FROM OrderItem Where Product2.Name = 'Franquia_Individual_Novo' LIMIT 1];
        OrderItem ordItemComp = [SELECT Id, TypeOfRequest__c FROM OrderItem Where Product2.Name = 'Plugin_Comp_Novo' LIMIT 1];
        ordItem.TypeOfRequest__c = 'Portabilidade';
        ordItemComp.TypeOfRequest__c = 'Portabilidade';
        
        ordItem.Avoid_vlc_pricing__c = false;
        ordItem.vlocity_cmt__EffectiveQuantity__c = 10;
        ordItem.vlocity_cmt__RecurringCalculatedPrice__c = 10;
        ordItem.vlocity_cmt__RecurringCharge__c = 10;
        ordItem.vlocity_cmt__OneTimeLoyaltyPrice__c = 10;
        ordItem.vlocity_cmt__EffectiveRecurringTotal__c = 10;
        ordItem.vlocity_cmt__RecurringTotal__c = 10;
        ordItem.vlocity_cmt__OneTimeLoyaltyTotal__c = 10;
        ordItem.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c = 10;
        
        update ordItem;
        update ordItemComp;
        lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        
        ordItem.TypeOfRequest__c = 'TT PF/PJ';
        ordItemComp.TypeOfRequest__c = 'TT PF/PJ';
        update ordItem;
        update ordItemComp;
        lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        
        ordItem.Avoid_vlc_pricing__c = true;
        ordItem.vlocity_cmt__EffectiveQuantity__c = 1;
        ordItem.vlocity_cmt__RecurringCalculatedPrice__c = 1;
        ordItem.vlocity_cmt__RecurringCharge__c = 1;
        ordItem.vlocity_cmt__OneTimeLoyaltyPrice__c = 1;
        ordItem.vlocity_cmt__EffectiveRecurringTotal__c = 1;
        ordItem.vlocity_cmt__RecurringTotal__c = 1;
        ordItem.vlocity_cmt__OneTimeLoyaltyTotal__c = 1;
        ordItem.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c = 1;
        
        update ordItem;
        
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado em outro teste da atualização dos dados do pedido
    */     
    @isTest static void test2() {
        //Order ord = [SELECT Id FROM Order LIMIT 1];
        OrderItem od =  [SELECT Id, TypeOfRequest__c, Avoid_vlc_pricing__c,
                                    vlocity_cmt__EffectiveQuantity__c,
                                    vlocity_cmt__RecurringCalculatedPrice__c,
                                    vlocity_cmt__RecurringCharge__c,
                                    vlocity_cmt__EffectiveRecurringTotal__c,
                                    vlocity_cmt__RecurringTotal__c,
                                    vlocity_cmt__OneTimeLoyaltyPrice__c,
                                    vlocity_cmt__OneTimeLoyaltyTotal__c,
                                    vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c,
                                    Product2Id
                                    FROM OrderItem
                                   LIMIT 1];
        
        od.TypeOfRequest__c = 'Portabilidade';
        od.vlocity_cmt__RecurringCalculatedPrice__c = 10;
        od.vlocity_cmt__EffectiveQuantity__c = 10;
        od.vlocity_cmt__OneTimeLoyaltyPrice__c = 10;
        update od;
        
        od.Avoid_vlc_pricing__c = true;
        od.vlocity_cmt__RecurringCalculatedPrice__c = 20;
        od.vlocity_cmt__EffectiveQuantity__c = 20;
        od.vlocity_cmt__OneTimeLoyaltyPrice__c = 20;
        update od;
        
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da gravação do pedido
    */     
    @isTest static void testNovo() {
        Order ord = [SELECT Id FROM Order];
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        CEC_PME_FinalizarPedidoController.DataRetorno dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
        
        for(CEC_PME_FinalizarPedidoController.Data data : lstData){
            for(CEC_PME_FinalizarPedidoController.Sessao sessao : data.sessao){
                if('Novo'.equals(sessao.tipo)){
                    System.Debug('TipoNovo: ' + JSON.Serialize(sessao));
                    List<CEC_PME_FinalizarPedidoController.ItensTipoNovo> lstItensTipoNovo = new List<CEC_PME_FinalizarPedidoController.ItensTipoNovo>();
                    CEC_PME_FinalizarPedidoController.ItensTipoNovo itensTipoNovo = new CEC_PME_FinalizarPedidoController.ItensTipoNovo();
					
                    if(sessao.lstAparelhos.size() == 0){
                        continue;
                    }
                    
                    String chave = '';
					for(String key : sessao.lstAparelhos[0].aparelho.keySet()){
                        System.Debug('Chave: ' + key);
                        chave = key;
                    }
                    
                    sessao.associacaoPendente = 'Não';
                    itensTipoNovo.chave = chave;
                    itensTipoNovo.modelo = 'modelo';
                    itensTipoNovo.imei = '0000000000';
                    itensTipoNovo.iccid = '00000000000000000000';
                    itensTipoNovo.cor = 'cor';
                    itensTipoNovo.outraCor = 'Não';
                    
                    lstItensTipoNovo.add(itensTipoNovo);
                    sessao.tipoNovo.itensTipoNovo = lstItensTipoNovo;
                }
            }
        }
        
        dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da portabilidade
    */     
    @isTest static void testPortabilidade() {
        Order ord = [SELECT Id FROM Order];
        OrderItem ordItem = [SELECT Id FROM OrderItem WHERE Product2.Name = 'Franquia_Individual_Novo'];
        ordItem.TypeOfRequest__c = 'Portabilidade';
        update ordItem;
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        CEC_PME_FinalizarPedidoController.DataRetorno dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
        
        for(CEC_PME_FinalizarPedidoController.Data data : lstData){
            for(CEC_PME_FinalizarPedidoController.Sessao sessao : data.sessao){
                if('Portabilidade'.equals(sessao.tipo)){
                    System.Debug('TipoPortabilidade: ' + JSON.Serialize(sessao));
                    List<CEC_PME_FinalizarPedidoController.ItensTipoPortabilidade> lstItensTipoPortabilidade = new List<CEC_PME_FinalizarPedidoController.ItensTipoPortabilidade>();
                    CEC_PME_FinalizarPedidoController.ItensTipoPortabilidade itensTipoPortabilidade = new CEC_PME_FinalizarPedidoController.ItensTipoPortabilidade();
					
                    if(sessao.lstAparelhos.size() == 0){
                        continue;
                    }
                    
                    String chave = '';
					for(String key : sessao.lstAparelhos[0].aparelho.keySet()){
                        System.Debug('Chave: ' + key);
                        chave = key;
                    }
                    
                    sessao.associacaoPendente = 'Não';
                    itensTipoPortabilidade.chave = chave;
                    itensTipoPortabilidade.modelo = 'modelo';
                    itensTipoPortabilidade.cor = 'cor';
                    itensTipoPortabilidade.outraCor = 'Não';
                    itensTipoPortabilidade.linha = '11999999999';
                    itensTipoPortabilidade.operadora = 'Teste';
                    
                    lstItensTipoPortabilidade.add(itensTipoPortabilidade);
                    sessao.tipoPortabilidade.itensTipoPortabilidade = lstItensTipoPortabilidade;
                }
			}
        }
        
        dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da transferencia
    */     
    @isTest static void testTransferencia() {
        Order ord = [SELECT Id FROM Order];
        OrderItem ordItem = [SELECT Id FROM OrderItem WHERE Product2.Name = 'Franquia_Individual_Novo'];
        ordItem.TypeOfRequest__c = 'TT PF/PJ';
        update ordItem;
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        CEC_PME_FinalizarPedidoController.DataRetorno dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
        
        for(CEC_PME_FinalizarPedidoController.Data data : lstData){
            for(CEC_PME_FinalizarPedidoController.Sessao sessao : data.sessao){
                if('TT PF/PJ'.equals(sessao.tipo)){
                    System.Debug('TipoTransferencia: ' + JSON.Serialize(sessao));
                    CEC_PME_FinalizarPedidoController.TipoTransferencia tipoTransferencia = new CEC_PME_FinalizarPedidoController.TipoTransferencia();
                    tipoTransferencia.tipoEntrega = 'Logística';
                    tipoTransferencia.servicosSelecionados = 'Nenhum';
                        
                    List<CEC_PME_FinalizarPedidoController.ItemTipoTransferencia> lstItensTipoTransferencia = new List<CEC_PME_FinalizarPedidoController.ItemTipoTransferencia>();
                    CEC_PME_FinalizarPedidoController.ItemTipoTransferencia ItensTipoTransferencia = new CEC_PME_FinalizarPedidoController.ItemTipoTransferencia();
					ItensTipoTransferencia.nomeDoador = 'Nome doador';
                    ItensTipoTransferencia.cpf = '00000000000';
                    ItensTipoTransferencia.telefone = '11999999999';
                    ItensTipoTransferencia.email = 'teste@teste.com';
                    
                    List<CEC_PME_FinalizarPedidoController.AparelhoTransferencia> lstAparelhoTransferencia = new List<CEC_PME_FinalizarPedidoController.AparelhoTransferencia>();
                    CEC_PME_FinalizarPedidoController.AparelhoTransferencia aparelhoTransferencia = new CEC_PME_FinalizarPedidoController.AparelhoTransferencia();
                    
                    
                    if(sessao.lstAparelhos.size() == 0){
                        continue;
                    }
                    
                    String chave = '';
					for(String key : sessao.lstAparelhos[0].aparelho.keySet()){
                        System.Debug('Chave: ' + key);
                        chave = key;
                    }
                    
                    sessao.associacaoPendente = 'Não';
                    aparelhoTransferencia.chave = chave;
                    aparelhoTransferencia.modelo = 'modelo';
                    aparelhoTransferencia.imei = '0000000000';
                    aparelhoTransferencia.iccid = '00000000000000000000';
                    aparelhoTransferencia.cor = 'cor';
                    aparelhoTransferencia.outraCor = 'Não';
                    aparelhoTransferencia.linha = '';
                    
                    lstAparelhoTransferencia.add(aparelhoTransferencia);
                    itensTipoTransferencia.aparelhoTransferencia = lstAparelhoTransferencia;
                    lstItensTipoTransferencia.add(itensTipoTransferencia);
                    tipoTransferencia.itemTipoTransferencia = lstItensTipoTransferencia;
                    sessao.tipoTransferencia = tipoTransferencia;
                }
			}
        }
        
        dr = CEC_PME_FinalizarPedidoController.saveOrder(JSON.serialize(lstData));
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da operadora
    */     
    @isTest static void testOperadora(){
        List<String> lstLinha = new List<String>();
        lstLinha.add('11945867706');
        
        Test.startTest();
        Map<String, String> mapOperadora = CEC_PME_FinalizarPedidoController.getOperadora(lstLinha);
        System.assertEquals(mapOperadora.get('11945867706').replace('[REJECTED]', ''), 'Telefones não podem ser portados pois já estão na Claro.');
        Test.stopTest();
    }
    
	/*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da gravação do pedido para abertura do resumo
    */     
    @isTest static void testNovoResumo() {
        Order ord = [SELECT Id FROM Order];
        
        List<CEC_PME_FinalizarPedidoController.Data> lstData = CEC_PME_FinalizarPedidoController.carregarDados(ord.Id);
        CEC_PME_FinalizarPedidoController.saveResumo(JSON.serialize(lstData));
        
        for(CEC_PME_FinalizarPedidoController.Data data : lstData){
            for(CEC_PME_FinalizarPedidoController.Sessao sessao : data.sessao){
                if('Novo'.equals(sessao.tipo)){
                    System.Debug('TipoNovo: ' + JSON.Serialize(sessao));
                    List<CEC_PME_FinalizarPedidoController.ItensTipoNovo> lstItensTipoNovo = new List<CEC_PME_FinalizarPedidoController.ItensTipoNovo>();
                    CEC_PME_FinalizarPedidoController.ItensTipoNovo itensTipoNovo = new CEC_PME_FinalizarPedidoController.ItensTipoNovo();
					
                    if(sessao.lstAparelhos.size() == 0){
                        continue;
                    }
                    
                    String chave = '';
					for(String key : sessao.lstAparelhos[0].aparelho.keySet()){
                        System.Debug('Chave: ' + key);
                        chave = key;
                    }
                    
                    sessao.associacaoPendente = 'Não';
                    itensTipoNovo.chave = chave;
                    itensTipoNovo.modelo = 'modelo';
                    itensTipoNovo.imei = '0000000000';
                    itensTipoNovo.iccid = '00000000000000000000';
                    itensTipoNovo.cor = 'cor';
                    itensTipoNovo.outraCor = 'Não';
                    
                    lstItensTipoNovo.add(itensTipoNovo);
                    sessao.tipoNovo.itensTipoNovo = lstItensTipoNovo;
                }
            }
        }
        
        CEC_PME_FinalizarPedidoController.saveResumo(JSON.serialize(lstData));
    }    
}