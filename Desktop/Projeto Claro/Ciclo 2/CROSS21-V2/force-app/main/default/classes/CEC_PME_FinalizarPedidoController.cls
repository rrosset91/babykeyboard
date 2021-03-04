/*
* Autor: Marcos Aurelio - Deloitte
* Data: 21/05/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
Classe que implementa a lógica reponsável pela tela de finalização de pedido.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public class CEC_PME_FinalizarPedidoController {
    
    static final String CONST_SIM = 'Sim'; 
    static final String CONST_SIM_MAIUSC = 'SIM';
    static final String CONST_NAO = 'Não'; 
    static final String CONST_NAO_MAIUSC = 'NÃO';
    static final String CONST_ORDER = 'Order';
    static final String CONST_SUMMARY = 'Summary';
    static final String TIPO_PROD_APARELHOS = 'Aparelhos';
    static final String PROD_SIMCARD_AVULSO = 'SimCard Avulso';    
    static final String PLANO_IND = 'Individual';    
    static final String PLANO_COMP= 'Compartilhado';   
    static final String TIPO_REQ_TRANSF = 'TT PF/PJ';
    static final String TIPO_REQ_PORT = 'Portabilidade';
    static final String TIPO_PROD_PLUGIN = 'Plug-In';
	static final String TIPO_PROD_SERVICO = 'Serviço';    
	static final String TIPO_PROD_PASS = 'Passaporte'; 
    static final String TIPO_FRANQUIA_IND = 'PME_PlanoClaroTotalIndividual_0001';
    static final String TIPO_FRANQUIA_COMP = 'PME_PlanoClaroTotalCompartilhado_0001';  
    static final String TIPO_PEDIDO_NOVO = 'Novo'; 
    static final String CONST_ZERO = '0';
    static final String STATUS_EM_ANDAMENTO = 'Em Andamento';
    static final String STATUS_AGUARD_CONTRATO = 'Aguardando criação contrato';
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Método responsável por montar todos os dados utilizados na tela de finalização de pedido.
    * Consome a informação do OrderItem com base no id do pedido.
    */    
    @AuraEnabled
    public static List<Data> carregarDados(String idPedido){
        List<Data> lstData = new List<Data>();   
        
        try {
            Order pedido = [SELECT Id, DeliveryMethod__c, Status FROM Order WHERE Id =: idPedido];
            
            //Melhorar este ponto. Redirecionar para o pedido.
            if(pedido.Status != STATUS_EM_ANDAMENTO){
                return lstData;
            }
            
            List<OrderItem> lstItemPedido = [SELECT Id, PlanGroup__c, 
                                             Product2.Name, 
                                             Product2.ProductCode, 
                                             Product2.vlocity_cmt__type__c, 
                                             Product2.vlocity_cmt__subType__c, 
                                             Product2.Color__c, 
                                             Product2.Manufacturer__c, 
                                             Product2.Model__c, 
                                             TypeOfRequest__c, 
                                             ParentGroup__c, 
                                             ReliesOnReferenceId__c, 
                                             vlocity_cmt__AssetReferenceId__c, 
                                             Group__c, Subgroup__c, 
                                             Quantity ,
                                             vlocity_cmt__ItemName__c
                                             FROM OrderItem WHERE OrderId =: pedido.Id];
            
            for(OrderItem item : lstItemPedido){
                if(TIPO_FRANQUIA_IND.equals(item.Product2.ProductCode)){
                    lstData.add(getPlano(PLANO_IND, item, lstItemPedido, pedido));
                } else if(TIPO_FRANQUIA_COMP.equals(item.Product2.ProductCode)){
                    lstData.add(getPlano(PLANO_COMP, item, lstItemPedido, pedido));
                }
            }
            
            System.Debug('Data: ' + JSON.Serialize(lstData));    
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return lstData;        
    }
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Monta a estrutura do plano que será enviado a tela.
    */        
    private static Data getPlano(String plano, OrderItem item,List<OrderItem> lstItemPedido, Order pedido){
        Data retData = new Data();
          
        try {
            retdata.planName = item.Product2.Name;
            retdata.idPedido = pedido.Id;
            retData.sessao = getSessao(plano, item, lstItemPedido, pedido);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return retData;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Monta a estrutura da lista das sessões que será enviado a tela.
    */            
    private static List<Sessao> getSessao(String plano, OrderItem item,List<OrderItem> lstItemPedido, Order pedido){
        List<Sessao> lstSessao = new List<Sessao>();
        
        try {
            for(OrderItem itemPedido : lstItemPedido){
                if(PLANO_IND.equals(plano)){
                    if(itemPedido.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c){
                        Sessao itemSessao = new Sessao();
                        itemSessao.tipo = itemPedido.TypeOfRequest__c;
                        itemSessao.regional = itemPedido.ParentGroup__c;
                        itemSessao.uf = itemPedido.Group__c;
                        itemSessao.ddd = itemPedido.Subgroup__c;
                        itemSessao.qtdLinha = String.valueof(itemPedido.Quantity.intValue());
                        itemSessao.kit = itemPedido.vlocity_cmt__ItemName__c;
                        itemSessao.grupo = String.valueOf(itemPedido.PlanGroup__c);
                        itemSessao.franquia = itemPedido.Product2.Name;
                        itemSessao.plugin = CONST_ZERO; //Valor default para plano individual.
                        itemSessao.aparelhos = getQtdAparelhos(itemPedido, lstItemPedido);
                        itemSessao.simcardAvulso = getQtdSimCardAvulso(itemPedido, lstItemPedido);
                        itemSessao.lstAparelhos = getListAparelhos(itemPedido, lstItemPedido);
                        
                        if(TIPO_PEDIDO_NOVO.equals(itemPedido.TypeOfRequest__c)){
                            itemSessao.tipoNovo = getTipoNovo(itemPedido, lstItemPedido, pedido);    
                        } else if(TIPO_REQ_PORT.equals(itemPedido.TypeOfRequest__c)){
                            itemSessao.tipoPortabilidade = getTipoPortabilidade(itemPedido, lstItemPedido);    
                        } else if(TIPO_REQ_TRANSF.equals(itemPedido.TypeOfRequest__c)){
                            itemSessao.tipoTransferencia = getTipoTransferencia(itemPedido, lstItemPedido, pedido);    
                        }
                        
                        lstSessao.add(itemSessao);
                    }    
                } else if(PLANO_COMP.equals(plano)){
                    //Dados da franquia
                    if(itemPedido.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c){
                        for(OrderItem itemFranquia : lstItemPedido){
                            //Dados do plug-in
                            if(itemFranquia.ReliesOnReferenceId__c == itemPedido.vlocity_cmt__AssetReferenceId__c){
                                if(TIPO_PROD_PLUGIN.equals(itemFranquia.Product2.vlocity_cmt__Type__c)){
                                    Sessao itemSessao = new Sessao();
                                    itemSessao.regional = itemPedido.ParentGroup__c;
                                    itemSessao.uf = itemPedido.Group__c;
                                    itemSessao.grupo = itemFranquia.PlanGroup__c;
                                    itemSessao.franquia = itemPedido.Product2.Name;
                                    itemSessao.ddd = itemFranquia.Subgroup__c;
                                    itemSessao.qtdLinha = String.valueof(itemFranquia.Quantity.intValue());
                                    itemSessao.tipo = itemFranquia.TypeOfRequest__c;
                                    itemSessao.plugin = String.valueof(itemFranquia.Quantity.intValue());
                                    itemSessao.aparelhos = getQtdAparelhos(itemFranquia, lstItemPedido);
                                    itemSessao.simcardAvulso = getQtdSimCardAvulso(itemFranquia, lstItemPedido);
                                    itemSessao.lstAparelhos = getListAparelhos(itemFranquia, lstItemPedido);
                                    
                                    if(TIPO_PEDIDO_NOVO.equals(itemFranquia.TypeOfRequest__c)){
                                        itemSessao.tipoNovo = getTipoNovo(itemFranquia, lstItemPedido, pedido);    
                                    } else if(TIPO_REQ_PORT.equals(itemFranquia.TypeOfRequest__c)){
                                        itemSessao.tipoPortabilidade = getTipoPortabilidade(itemFranquia, lstItemPedido);    
                                    } else if(TIPO_REQ_TRANSF.equals(itemFranquia.TypeOfRequest__c)){
                                        itemSessao.tipoTransferencia = getTipoTransferencia(itemFranquia, lstItemPedido, pedido);    
                                    }
                                    
                                    lstSessao.add(itemSessao);
                                }
                            }
                        }
                    }    
                }
                
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstSessao;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém a quantidade de aparelhos por sessão da tela.
    */            
    private static String getQtdAparelhos(OrderItem item,List<OrderItem> lstItemPedido){
        Decimal retorno = 0;
        
        try {
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_APARELHOS.equals(itemPedido.Product2.vlocity_cmt__Type__c)){
                        retorno+= itemPedido.Quantity;
                    }
                }
            }
            
            return String.valueof(retorno.intValue());
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }             
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém a quantidade de simcard avulso por sessão da tela.
    */                
    private static String getQtdSimCardAvulso(OrderItem item,List<OrderItem> lstItemPedido){
        Decimal retorno = 0;
        
        try {
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(PROD_SIMCARD_AVULSO.equals(itemPedido.Product2.vlocity_cmt__subType__c)){
                        retorno+= itemPedido.Quantity;
                    }
                }
            }            
            
            return String.valueof(retorno.intValue());
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }             
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Monta a lista de aparelhos por sessão para ser exibida no combo de aparelhos.
    */                
    private static List<Aparelhos> getListAparelhos(OrderItem item,List<OrderItem> lstItemPedido){
    	List<Aparelhos> lstAparelhos = new List<Aparelhos>();
        
        try {
            Map<String, Set<String>> mapCores = getCoresDisponiveis(item, lstItemPedido);
            
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_APARELHOS.equals(itemPedido.Product2.vlocity_cmt__Type__c) || PROD_SIMCARD_AVULSO.equals(itemPedido.Product2.vlocity_cmt__SubType__c)){
                        Aparelhos aparelho = new Aparelhos();
                        Map<String, String> itemAparelho = new Map<String, String>();
                        itemAparelho.put(itemPedido.Id, itemPedido.Product2.Name);
                        
                        Set<String> lstCoresDisponiveis = mapCores.get(itemPedido.Product2.Manufacturer__c + itemPedido.Product2.Model__c);
                        Set<String> lstCoresClone = lstCoresDisponiveis.clone();
                        lstCoresClone.remove(itemPedido.Product2.Color__c);
                        aparelho.aparelho = itemAparelho;
                        aparelho.cor = itemPedido.Product2.Color__c;
                        aparelho.lstCoresDisponiveis = lstCoresClone;
                        
                        lstAparelhos.add(aparelho);            
                    }
                }
            }
            System.Debug(lstAparelhos);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return lstAparelhos;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém as cores disponíveis por aparelho.
    */                    
    private static Map<String, Set<String>> getCoresDisponiveis(OrderItem item,List<OrderItem> lstItemPedido){
        Map<String, Set<String>> apCores = new Map<String, Set<String>>();
        Set<String> manufactured = new Set<String>();
        Set<String> model = new Set<String>();
        
        try {
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_APARELHOS.equals(itemPedido.Product2.vlocity_cmt__Type__c) || PROD_SIMCARD_AVULSO.equals(itemPedido.Product2.vlocity_cmt__SubType__c)){
                        manufactured.add(itemPedido.Product2.Manufacturer__c);
                        model.add(itemPedido.Product2.Model__c);
                    }
                }
            }
            
            List<Product2> lstPrd = [SELECT Manufacturer__c, Model__c, Color__c FROM Product2 Where Manufacturer__c =: manufactured and Model__c = : model];
            for(Product2 prd : lstPrd){
                if(!apCores.containsKey(prd.Manufacturer__c + prd.Model__c)){
                    Set<String> setCor = new Set<String>();
                    for(Product2 prd2 : lstPrd){
                        if(prd.Manufacturer__c == prd2.Manufacturer__c && prd.Model__c == prd2.Model__c){
                            setCor.add(prd2.Color__c);
                        }
                    }
                    apCores.put(prd.Manufacturer__c + prd.Model__c, setCor);    
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return apCores;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém as informações a serem exibidas em tela quando o tipo é novo.
    */                    
    private static TipoNovo getTipoNovo(OrderItem item,List<OrderItem> lstItemPedido, Order pedido){
        TipoNovo tipoNovo = new TipoNovo();
        List<itensTipoNovo> lstTipoNovo = new List<itensTipoNovo>();
        String servicos = '';
        
        try {
            tipoNovo.tipoEntrega = pedido.DeliveryMethod__c;
            
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_SERVICO.equals(itemPedido.Product2.vlocity_cmt__Type__c) || TIPO_PROD_PASS.equals(itemPedido.Product2.vlocity_cmt__Type__c)){
                        servicos+= itemPedido.Product2.Name + ', ';
                    }
                }
            }
            
            servicos = servicos.mid(0, servicos.length() - 2);
            tipoNovo.servicosSelecionados = servicos; 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
        
        return tipoNovo;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém as informações a serem exibidas em tela quando o tipo é portabilidade.
    */                    
    private static TipoPortabilidade getTipoPortabilidade(OrderItem item,List<OrderItem> lstItemPedido){
        TipoPortabilidade tipoPortabilidade = new TipoPortabilidade();
        List<itensTipoPortabilidade> lstTipoPortabilidade = new List<itensTipoPortabilidade>();
        
        try {
            tipoPortabilidade.itensTipoPortabilidade = lstTipoPortabilidade;
            String servicos = '';
            
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_SERVICO.equals(itemPedido.Product2.vlocity_cmt__Type__c) || TIPO_PROD_PASS.equals(itemPedido.Product2.vlocity_cmt__Type__c)){
                        servicos+= itemPedido.Product2.Name + ', ';
                    }
                }
            }
            
            servicos = servicos.mid(0, servicos.length() - 2);
            tipoPortabilidade.servicosSelecionados = servicos; 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return tipoPortabilidade;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém as informações a serem exibidas em tela quando o tipo é transferência.
    */                        
    private static TipoTransferencia getTipoTransferencia(OrderItem item,List<OrderItem> lstItemPedido, Order pedido){
        TipoTransferencia tipoTransferencia = new TipoTransferencia();
        List<ItemTipoTransferencia> lstTipoTransferencia = new List<ItemTipoTransferencia>();
        
        try {
            tipoTransferencia.itemTipoTransferencia = lstTipoTransferencia;
            
            String servicos = '';
            tipoTransferencia.tipoEntrega = pedido.DeliveryMethod__c;
            
            for(OrderItem itemPedido : lstItemPedido){
                if(item.vlocity_cmt__AssetReferenceId__c == itemPedido.ReliesOnReferenceId__c){
                    if(TIPO_PROD_SERVICO.equals(itemPedido.Product2.vlocity_cmt__Type__c) || TIPO_PROD_PASS.equals(itemPedido.Product2.vlocity_cmt__Type__c)){
                        servicos+= itemPedido.Product2.Name + ', ';
                    }
                }
            }
            
            servicos = servicos.mid(0, servicos.length() - 2);
            tipoTransferencia.servicosSelecionados = servicos; 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
        
        return tipoTransferencia;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Executa a lógica de gravação dos dados que foram associados em tela.
    */                        
    @AuraEnabled
    public static DataRetorno saveOrder(String strData){
        DataRetorno retorno = new DataRetorno();
        
        try {
            System.Debug('>>>>INICIO SALVAR');
            List<CEC_PME_FinalizarPedidoController.Data> lstData = (List<CEC_PME_FinalizarPedidoController.Data>)System.JSON.deserializeStrict(strData, List<CEC_PME_FinalizarPedidoController.Data>.Class);
            
            retorno = validarInput(lstData);
            if(retorno.contemErro == false){
                System.Debug('>>>>PASSOU VALIDAÇÃO');
                saveData(lstData, CONST_ORDER);    
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
        
        return retorno;
    }
    
	/*
    * Autor: Otavio Fonseca] - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Executa uma pré gravação, para que os dados apareçam corretamente no resumo.
    */                        
    @AuraEnabled
    public static void saveResumo(String strData){
        DataRetorno retorno = new DataRetorno();
        
        try {
            List<CEC_PME_FinalizarPedidoController.Data> lstData = (List<CEC_PME_FinalizarPedidoController.Data>)System.JSON.deserializeStrict(strData, List<CEC_PME_FinalizarPedidoController.Data>.Class);
            
            saveData(lstData, CONST_SUMMARY);    
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
    }    
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Valida o input de dados no momento de salvar as associações de tela.
    */    
    private static DataRetorno validarInput(List<Data> lstData){
        Set<String> setTodasLinhas = new set<String>();
        List<String> lstError = new List<String>();
        DataRetorno retorno = new DataRetorno();
        
        try {
            retorno.contemErro = false;
            retorno.msgErro = '';
            
            for(Data dados : lstData){
                for(Sessao sessao : dados.sessao){
                    if(CONST_SIM.equals(sessao.associacaoPendente)){
                        List<String> labelParam = new List<String>();
                        labelParam.add(dados.planName);
                        labelParam.add(sessao.tipo);
                        lstError.add(String.format(Label.CEC_PME_PED_ASSOC_PEN, labelParam) + '\r');
                    }
                    
                    if(sessao.tipoPortabilidade != Null){
                        for(ItensTipoPortabilidade item : sessao.tipoPortabilidade.itensTipoPortabilidade){
                            if(setTodasLinhas.contains(item.linha)){
                                List<String> labelParamGrp = new List<String>();
                       			labelParamGrp.add(item.linha);
                        		labelParamGrp.add(sessao.grupo);
                        		lstError.add(String.format(Label.CEC_PME_NUMERO_GRUPO, labelParamGrp) + '\r');
                            }
                            setTodasLinhas.add(item.linha);
                        }
                    }
                    
                    if(sessao.tipoTransferencia != Null){
                        for(ItemTipoTransferencia item : sessao.tipoTransferencia.itemTipoTransferencia){
                            for(AparelhoTransferencia aparelho : item.aparelhoTransferencia){
                                System.Debug('AP: ' + aparelho);
                                System.Debug('Set: ' + setTodasLinhas);
                                if(setTodasLinhas.contains(aparelho.linha)){
                                    lstError.add('Número ' + aparelho.linha + ' já inserido no grupo ' + sessao.grupo + '. Por favor, corrigir e enviar novamente.\r');
                                }    
                                setTodasLinhas.add(aparelho.linha);
                            }
                        }
                    }
                }
            }
            
            for(String msg : lstError){
                retorno.contemErro = true;
                retorno.msgErro+= msg;
            } 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return retorno;
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Método que grava as informações na base de dados.
    */        
    private static void saveData(List<Data> lstData, String dataType){
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Order ord = new Order();
        
        try {
            for(Data item : lstData){
                ord.id = item.idPedido;
                for(Sessao sessao : item.sessao){
                    if(sessao.TipoNovo != Null){
                        if(sessao.TipoNovo.itensTipoNovo != null){
                            System.Debug('>>>>Gravando Tipo Novo');
                            for(ItensTipoNovo itemNovo : sessao.TipoNovo.itensTipoNovo){
                                OrderItem ordItem = new OrderItem();
                                ordItem.Id = itemNovo.chave;
                                ordItem.IMEI__c = itemNovo.imei;
                                ordItem.ICCID__c = itemNovo.iccid;
                                ordItem.DeviceSecondOptionColor__c = itemNovo.outraCor == CONST_NAO ? CONST_NAO_MAIUSC : CONST_SIM_MAIUSC;
                                ordItem.AnotherDeviceColor__c = itemNovo.outraCor;
                                
                                lstOrderItem.add(ordItem);
                            }
                        }
                    }
                    
                    if(sessao.TipoPortabilidade != Null){
                        System.Debug('>>>>Gravando Tipo Portabilidade');
                        for(ItensTipoPortabilidade itemPort : sessao.TipoPortabilidade.itensTipoPortabilidade){
                            OrderItem ordItem = new OrderItem();
                            ordItem.Id = itemPort.chave;
                            ordItem.PortabilityNumber__c = itemPort.linha;
                            ordItem.Operator__c = itemPort.operadora;
                            ordItem.DeviceSecondOptionColor__c = itemPort.outraCor == CONST_NAO ? CONST_NAO_MAIUSC : CONST_SIM_MAIUSC;
                            ordItem.AnotherDeviceColor__c = itemPort.outraCor;
                            
                            lstOrderItem.add(ordItem);
                        }
                    }
                    
                    if(sessao.TipoTransferencia != Null){
                        System.Debug('>>>>Gravando Tipo Transferência');
                        for(ItemTipoTransferencia itemTransf : sessao.tipoTransferencia.itemTipoTransferencia){
                            for(AparelhoTransferencia apTransf : itemTransf.AparelhoTransferencia){
                                OrderItem ordItem = new OrderItem();
                                ordItem.Id = apTransf.chave;
                                ordItem.DonatorDocumentNumber__c = itemTransf.cpf;
                                ordItem.DonatorEmail__c = itemTransf.email;
                                ordItem.DonatorName__c = itemTransf.nomeDoador;
                                ordItem.DonatorPhone__c = itemTransf.telefone;
                                ordItem.PortabilityNumber__c = apTransf.linha.replace('-','').replace(' ','');
                                ordItem.ICCID__c = apTransf.iccid;
                                ordItem.IMEI__c = apTransf.imei;
                                ordItem.DeviceSecondOptionColor__c = apTransf.outraCor == CONST_NAO ? CONST_NAO_MAIUSC : CONST_SIM_MAIUSC;
                                ordItem.AnotherDeviceColor__c = apTransf.outraCor;
                                
                                lstOrderItem.add(ordItem);    
                            }
                        }
                    }
                    
                }
            }
            
            update lstOrderItem;
            
            if (!dataType.equals(CONST_SUMMARY)) {
                ord.Status = STATUS_AGUARD_CONTRATO;
                update ord;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
    }
    
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
    * Obtém a operadora das linhas digitadas na sessão de portabilidade.
    */            
    @AuraEnabled
    public static Map<String, String> getOperadora(List<String> lstLinhas){
        List<String> retorno = new List<String>();
        
        try {
            return PME_ConsultarOperadoraTelefone.getListTelephoneInfo(lstLinhas);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }             
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 22]
    * Método responsável por atualizar a escolha do LD 21 do pedido
    */    
    @AuraEnabled
    public static void updateLD21Order(String recordId, String ld21Seleted) {
       
        Order varOrder = new Order();
        
        varOrder.Id = recordId;
        varOrder.LD21__c = ld21Seleted;
        update varOrder;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Inicio da criação de objetos a serem usados na integração
    */      
    public class Data {
        @AuraEnabled public String idPedido					{ get; set; }
        @AuraEnabled public String planName					{ get; set; }
        @AuraEnabled public List<Sessao> sessao 			{ get; set; }
    }
    
    public class Sessao{
        @AuraEnabled public String tipo									{ get; set; }
        @AuraEnabled public String regional								{ get; set; }
        @AuraEnabled public String uf									{ get; set; }
        @AuraEnabled public String ddd									{ get; set; }
        @AuraEnabled public String qtdLinha								{ get; set; }
        @AuraEnabled public String kit								{ get; set; }
        @AuraEnabled public String grupo								{ get; set; }
        @AuraEnabled public String franquia								{ get; set; }
        @AuraEnabled public String plugin								{ get; set; }
        @AuraEnabled public String aparelhos							{ get; set; }
        @AuraEnabled public String simcardAvulso						{ get; set; }
        @AuraEnabled public String associacaoPendente					{ get; set; }
        @AuraEnabled public List<Aparelhos> lstAparelhos		 		{ get; set; }
        @AuraEnabled public TipoNovo tipoNovo							{ get; set; }
        @AuraEnabled public TipoPortabilidade tipoPortabilidade			{ get; set; }
        @AuraEnabled public TipoTransferencia tipoTransferencia			{ get; set; }
    }
    
    public class Aparelhos{
        @AuraEnabled public Map<String, String> aparelho				{ get; set;	}
        @AuraEnabled public String cor									{ get; set;	}
        @AuraEnabled public Set<String> lstCoresDisponiveis				{ get; set; }
    }

    public class TipoNovo{
        @AuraEnabled public String tipoEntrega					{ get; set; }
        @AuraEnabled public String servicosSelecionados			{ get; set; }
        @AuraEnabled public List<itensTipoNovo> itensTipoNovo	{ get; set; }
    }

    public class itensTipoNovo{
        @AuraEnabled public String chave					{ get; set; }
    	@AuraEnabled public String modelo					{ get; set; }
        @AuraEnabled public String imei						{ get; set; }
        @AuraEnabled public String iccid					{ get; set; }
        @AuraEnabled public String cor						{ get; set; }    
        @AuraEnabled public String outraCor					{ get; set; }    
    }
    
    public class TipoPortabilidade{
        @AuraEnabled public String servicosSelecionados									{ get; set; }
        @AuraEnabled public String linhas												{ get; set; } // Definir tipo do campo
        @AuraEnabled public List<ItensTipoPortabilidade> itensTipoPortabilidade			{ get; set; }
    }
    
    public class ItensTipoPortabilidade{
        @AuraEnabled public String chave				{ get; set; }
        @AuraEnabled public String modelo				{ get; set; }
        @AuraEnabled public String cor					{ get; set; }
        @AuraEnabled public String outraCor				{ get; set; }
        @AuraEnabled public String linha				{ get; set; }
        @AuraEnabled public String operadora			{ get; set; }
    }
    
    public class TipoTransferencia{
        @AuraEnabled public String tipoEntrega										{ get; set; }
        @AuraEnabled public String servicosSelecionados								{ get; set; }
        @AuraEnabled public List<ItemTipoTransferencia> itemTipoTransferencia		{ get; set; }
    }
    
    public class ItemTipoTransferencia{
        @AuraEnabled public String nomeDoador 										{ get; set; }
        @AuraEnabled public String cpf 												{ get; set; }
        @AuraEnabled public String telefone 										{ get; set; }
        @AuraEnabled public String email 											{ get; set; }
        @AuraEnabled public List<AparelhoTransferencia> aparelhoTransferencia 		{ get; set; }
    }
    
    public class AparelhoTransferencia{
        @AuraEnabled public String chave				{ get; set; }
        @AuraEnabled public String linha				{ get; set; }
        @AuraEnabled public String iccid				{ get; set; }
        @AuraEnabled public String modelo				{ get; set; }
        @AuraEnabled public String imei					{ get; set; }
        @AuraEnabled public String cor					{ get; set; }
        @AuraEnabled public String outraCor				{ get; set; }
   }
    
    public class DataRetorno{
        @AuraEnabled public Boolean contemErro			{ get; set; }
        @AuraEnabled public String msgErro				{ get; set; }
    }   
}