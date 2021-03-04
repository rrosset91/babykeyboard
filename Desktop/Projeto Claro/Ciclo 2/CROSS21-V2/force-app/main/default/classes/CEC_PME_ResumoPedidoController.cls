/*
* Autor: Daniel Meyer Dammous - Deloitte
* Data: 23/05/2019
* Descrição: CEC FASE 1 + SQUAD PME
* Controller backend da tela Resumo Pedido
* Controle de Versão
* ---------------------------------------------------------------
*/

public class CEC_PME_ResumoPedidoController {
    private static Order currentOrder { get; set; }
    private static Set<String> sessaoGrupos;
    private static String tradeInInd;
    private static String tradeInComp;
    
    //constantes
	static final String CONST_NAO = 'Não';    
    static final String TIPO_PROD_PLUGIN = 'Plug-In';
    static final String TIPO_PROD_PASSAPORTE = 'Passaporte';
    static final String TIPO_PROD_SERVICO = 'Serviço';
    static final String TIPO_PROD_BACKUP = 'Backup Online';
    static final String TIPO_PROD_GESTOR = 'Gestor Online';
    static final String TIPO_PROD_BONUS = 'Bonus';
    static final String TIPO_PROD_APARELHO = 'Aparelho';
    static final String TIPO_PROD_APARELHOS = 'Aparelhos';
	static final String TIPO_REQ_NOVO = 'Novo';
    static final String TIPO_REQ_PORTA = 'Portabilidade';
	static final String TIPO_REQ_TRANSF = 'TT PF/PJ';    
    static final String SIMCARD_AVULSO = 'SimCard Avulso';
    static final String TIPO_FRANQUIA_IND = 'PME_PlanoClaroTotalIndividual_0001';
    static final String TIPO_FRANQUIA_COMP = 'PME_PlanoClaroTotalCompartilhado_0001';  
    static final String EMPRESA_NET = 'NET';
    static final String EMPRESA_EMBRATEL = 'Embratel';
    static final String BONUS = 'Bônus';
    static final String CONST_GB = 'GB';
    static final String CONST_TB = 'TB';
    static final String HIFEN = '--';
   
    
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Principal método da classe, conforme o parametro methodName, é definido qual o fluxo a ser executado.
    */   
    @AuraEnabled
    public static Data load(String idPedido){
        Order ord = getOrder(idPedido);
        currentOrder = ord;
        Set<Id> ordContactIds = new Set<Id>();
        ordContactIds = getRelatedContactIdList(ord.Related_Contacts__c);
        
        List<OrderItem> lstOrdItem = getOrderItem(idPedido);
        Account acc = getAccount(ord.AccountId);
        List<AccountContactRelation> cttRelation = getContactRelation(ordContactIds);
        List<Contact> ctt = getContact(cttRelation);
        
        Data data = getData(ord, lstOrdItem, acc, ctt, cttRelation);
        
        System.Debug('JSON Data: ' + JSON.Serialize(data));
        return data;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura Data de acordo com os dados parametros
    */ 
    private static Data getData(Order ord, List<OrderItem> lstOrderItem,  Account acc, List<Contact> lstCtt, List<AccountContactRelation> cttRelation){
        Data data = new Data();
        data.tipoEntrega = ord.DeliveryMethod__c;
        data.resumoDadosCliente = getResumoDadosCliente(acc, ord, lstCtt, cttRelation);
        data.resumoPedido = getResumoPedido(lstOrderItem, ord, acc);       
        data.associacaoAparelhos = getAssociacaoAparelhos(lstOrderItem);
        return data;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna um Set de AccountContactRelation Ids baseado numa dada String com Ids separados por ';'
    */     
    private static Set<Id> getRelatedContactIdList(String ids) {
        if (ids == null || String.isBlank(ids)) {
            return new Set<Id>();
        }
        ids = ids.endsWith(';') ? ids.substring(0, ids.length()-1) : ids;
        List<String> idList = ids.split(';');
        Set<Id> idSet = new Set<Id>();
        try {
            for (String rcId : idList) {
                // Validação de ID Salesforce:
                Boolean isValid = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(rcId).matches();
                if (isValid) idSet.add(Id.valueOf(rcId));
            }
        }
        catch (Exception ex) {
            System.debug('>> Exception <<\n'
                         + 'Cause: ' 		+ ex.getCause() 			+ '\n'
                         + 'Line: ' 		+ ex.getLineNumber() 		+ '\n'
                         + 'Message: ' 		+ ex.getMessage() 			+ '\n'
                         + 'Stacktrace: ' 	+ ex.getStackTraceString() 	+ '\n'
                        );
        }
        
        return idSet;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura de Associação de Aparelhos com os respectivos dados da Order
    */     
    private static AssociacaoAparelhos getAssociacaoAparelhos(List<OrderItem> lstOrderItem){
        AssociacaoAparelhos assAparelho = new AssociacaoAparelhos();
        List<Sessao> lstSessao = new List<Sessao>();
        
        for(OrderItem itemPlano : lstOrderItem){
            if(TIPO_FRANQUIA_IND.equals(itemPlano.Product2.ProductCode)){
                for(OrderItem itemFranquia : lstOrderItem){
                    if(itemFranquia.ReliesOnReferenceId__c == itemPlano.vlocity_cmt__AssetReferenceId__c){
                        System.debug('Assoc Aparelho >>');
                        Sessao sessao = new Sessao();
                        sessao.tipo = itemFranquia.TypeOfRequest__c;
                        sessao.regional = itemFranquia.ParentGroup__c;
                        sessao.uf = itemFranquia.Group__c;
                        sessao.ddd = itemFranquia.Subgroup__c;
                        sessao.franquia = itemFranquia.Product2.Name;
                        sessao.qtdLinha = String.valueof(itemFranquia.Quantity.intValue());
                        sessao.grupos = itemFranquia.PlanGroup__c;
                        
                        sessaoGrupos = new Set<String>();
                        if(TIPO_REQ_NOVO.equals(itemFranquia.TypeOfRequest__c)){
                            sessao.tipoNovo = getTipoNovo(itemFranquia, lstOrderItem);
                        }
                        
                        if(TIPO_REQ_PORTA.equals(itemFranquia.TypeOfRequest__c)){
                            sessao.tipoPortabilidade = getTipoPortabilidade(itemFranquia, lstOrderItem);
                        }
                        
                        if(TIPO_REQ_TRANSF.equals(itemFranquia.TypeOfRequest__c)){
                            sessao.tipoTransferencia = getTipoTransferencia(itemFranquia, lstOrderItem);
                        }

                        lstSessao.add(sessao);
                    }
                }
            } else if(TIPO_FRANQUIA_COMP.equals(itemPlano.Product2.ProductCode)){
                for(OrderItem itemFranquia : lstOrderItem){
                    if(itemFranquia.ReliesOnReferenceId__c == itemPlano.vlocity_cmt__AssetReferenceId__c){
                        for(OrderItem itemPlugin : lstOrderItem){
                            if(itemPlugin.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                        		Sessao sessao = new Sessao();
                                sessao.tipo = itemPlugin.TypeOfRequest__c;
                                sessao.regional = itemFranquia.ParentGroup__c;
                                sessao.uf = itemFranquia.Group__c;
                                sessao.ddd = itemPlugin.Subgroup__c;
                                sessao.franquia = itemFranquia.Product2.Name;
                                sessao.qtdLinha = String.valueof(itemPlugin.Quantity.intValue());
                                sessao.grupos = '';
                                
                                sessaoGrupos = new Set<String>();
                                if(TIPO_REQ_NOVO.equals(itemPlugin.TypeOfRequest__c)) {
                                    sessao.tipoNovo = getTipoNovo(itemPlugin, lstOrderItem);
                                }
                                
                                if(TIPO_REQ_PORTA.equals(itemPlugin.TypeOfRequest__c)) {
                                    sessao.tipoPortabilidade = getTipoPortabilidade(itemPlugin, lstOrderItem);
                                }
                                
                                if(TIPO_REQ_TRANSF.equals(itemPlugin.TypeOfRequest__c)) {
                                    sessao.tipoTransferencia = getTipoTransferencia(itemPlugin, lstOrderItem);
                                }
                                
                                for(String grp : sessaoGrupos) {
                                    sessao.grupos += grp + ', ';
                                }
                                if (sessao.grupos.length() > 1) {
                                    sessao.grupos = sessao.grupos.substring(0, sessao.grupos.length()-2);
                                }
                                lstSessao.add(sessao);
                            }
                        }
                    }
                }
            }
        }
        assAparelho.sessao = lstSessao;
        return assAparelho;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura TipoNovo usada na Associação de Aparelhos
    */ 
    private static TipoNovo getTipoNovo(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        TipoNovo tipoNovo = new TipoNovo();
        List<Itens> lstItens = new List<Itens>();
        Integer aparelhosAssoc = 0;
        Integer qtdLinha = itemFranquia.Quantity.intValue();
        
        for(OrderItem item : lstOrderItem){
            if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if (TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c) || SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)) {
                    Itens itemNovo = new Itens();
                    itemNovo.linha = item.PortabilityNumber__c;
                    itemNovo.modelo = item.Product2.Name;
                    itemNovo.iccid = item.ICCID__c;
                    itemNovo.imei = item.IMEI__c;
                    itemNovo.cor = item.Product2.Color__c;
                    itemNovo.cores = String.isNotEmpty(item.AnotherDeviceColor__c) ? item.AnotherDeviceColor__c : CONST_NAO;
                    itemNovo.operadora = item.Operator__c;
                    if (itemFranquia.PlanGroup__c != null) {
                        sessaoGrupos.add(itemFranquia.PlanGroup__c);
                    }
                    
                    lstItens.add(itemNovo);
                    System.debug('NOVO >> ' + itemNovo);
                }
            }
        }
        
        tipoNovo.itens = lstItens;
        
        tipoNovo.pendente = qtdLinha != aparelhosAssoc;
        
        return tipoNovo;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura TipoPortabilidade usada na Associação de Aparelhos
    */     
    private static TipoPortabilidade getTipoPortabilidade(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        TipoPortabilidade tipoPortabilidade = new TipoPortabilidade();
        List<Itens> lstItens = new List<Itens>();
        Integer aparelhosAssoc = 0;
        Integer qtdLinha = itemFranquia.Quantity.intValue();
        
        for(OrderItem item : lstOrderItem){
            if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if (TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c) || SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)) {
                    aparelhosAssoc++;
                    Itens itemPort = new Itens();
                    itemPort.linha = item.PortabilityNumber__c;
                    itemPort.modelo = item.Product2.Name;
                    itemPort.iccid = item.ICCID__c;
                    itemPort.imei = item.IMEI__c;
                    itemPort.cor = item.Product2.Color__c;
                    itemPort.cores = String.isNotEmpty(item.AnotherDeviceColor__c) ? item.AnotherDeviceColor__c : CONST_NAO;
                    itemPort.operadora = item.Operator__c;
                    if (itemFranquia.PlanGroup__c != null) {
                        sessaoGrupos.add(itemFranquia.PlanGroup__c);
                    }
                    
                    lstItens.add(itemPort);
                }
            }
        }
        
        tipoPortabilidade.itens = lstItens;
        
        tipoPortabilidade.pendente = qtdLinha != aparelhosAssoc;
        
        return tipoPortabilidade;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura TipoTransferencia usada na Associação de Aparelhos
    */     
    private static TipoTransferencia getTipoTransferencia(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        TipoTransferencia tipoTransferencia = new TipoTransferencia();
        List<Itens> lstItens = new List<Itens>();
        Map<String, Doadores> doadorMap = new Map<String, Doadores>();
        Integer aparelhosAssoc = 0;
        Integer qtdLinha = itemFranquia.Quantity.intValue();

        for(OrderItem item : lstOrderItem){
            if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if (TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c) || SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)) {
                    aparelhosAssoc++;
                    Itens itemTransf = new Itens();
                    itemTransf.linha = item.PortabilityNumber__c;
                    itemTransf.modelo = item.Product2.Name;
                    itemTransf.iccid = item.ICCID__c;
                    itemTransf.imei = item.IMEI__c;
                    itemTransf.cor = item.Product2.Color__c;
                    itemTransf.cores = String.isNotEmpty(item.AnotherDeviceColor__c) ? item.AnotherDeviceColor__c : CONST_NAO;
                    itemTransf.operadora = item.Operator__c;
                    if (itemFranquia.PlanGroup__c != null) {
                        sessaoGrupos.add(itemFranquia.PlanGroup__c);
                    }
                    
                    Doadores doadorAtual = doadorMap.get(item.DonatorDocumentNumber__c);
                    
                    if (doadorAtual != null) {
                        doadorAtual.itens.add(itemTransf);
                    }
                    else {
                        doadorAtual = new Doadores();
                        doadorAtual.cpf = item.DonatorDocumentNumber__c;
                        doadorAtual.nome = item.DonatorName__c;
                        doadorAtual.telefone = item.DonatorPhone__c;
                        doadorAtual.email = item.DonatorEmail__c;
                        doadorAtual.itens = new List<Itens>();
                        doadorAtual.itens.add(itemTransf);
                        
                        doadorMap.put(item.DonatorDocumentNumber__c, doadorAtual);
                    }
                }
            }
        }
        
        tipoTransferencia.doadores = doadorMap.values();
        
        tipoTransferencia.pendente = qtdLinha != aparelhosAssoc;
        
        return tipoTransferencia;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura ResumoDadosCliente com os dados baseados nos parametros passados
    */        
    private static ResumoDadosCliente getResumoDadosCliente(Account acc, Order ord, List<Contact> lstCtt, List<AccountContactRelation> cttRelation){
        ResumoDadosCliente resumo = new ResumoDadosCliente();
        
        resumo.dadosEmpresa = getDadosEmpresa(acc);
        resumo.enderecoPrincipal = getEnderecoPrincipal(acc);
        resumo.enderecoCobranca = getEnderecoCobranca(acc);
        resumo.recebedor = getRecebedor(ord);
        resumo.contatosAdministrador = getContatosAdministrador(lstCtt, cttRelation);
        
        return resumo;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna os dados da empresa que fazem parte da estrutura ResumoDadosCliente
    */       
    private static DadosEmpresa getDadosEmpresa(Account acc){
        DadosEmpresa dados = new DadosEmpresa();
        
        dados.razaoSocial = acc.Name;
        dados.cnpj = acc.CNPJFormula__c;
        dados.inscricaoEstadual = acc.StateSubscription__c;
        dados.inscricaoEstadualIsento = acc.StateRegistrationExempted__c;
        dados.inscricaoMunicipal = acc.MunicipalSubscription__c;
        dados.inscricaoMunicipalIsento = acc.MunicipalRegistrationExempted__c;
        dados.cnaePrimario = acc.CNAE__c;
        dados.cnaeSecundario = acc.CNAE2__c;
        dados.numeroFuncionarios = acc.NumberOfEmployeesList__c;
        dados.tipoEmpresa = acc.CompanyClass__c;
        dados.segmentoComercial = acc.CommercialSegment__c;
        dados.dataVencimentoFatura = acc.DueDay__c;
        dados.possuiServicos = getListPossuiServicos(acc);
        dados.numeroContrato = acc.NETContractNumber__c;
        
        return dados;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna o endereço principal que parte da estrutura ResumoDadosCliente
    */     
    private static Endereco getEnderecoPrincipal(Account acc){
        Endereco endereco = new Endereco();
        
        endereco.cep = acc.ShippingPostalCode;
        endereco.endereco = acc.ShippingStreet;
        endereco.logradouro = acc.CEC_ShippingAddressType__c;
        endereco.numero = acc.CEC_ShippingNumber__c;
        endereco.complemento = acc.CEC_ShippingComplement__c;
        endereco.bairro = acc.CEC_ShippingNeighborhood__c;
        endereco.cidade = acc.ShippingCity;
        endereco.uf = acc.ShippingState;
        
        return endereco;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna o endereço de cobrança que parte da estrutura ResumoDadosCliente
    */       
    private static Endereco getEnderecoCobranca(Account acc){
        Endereco endereco = new Endereco();
        
        endereco.cep = acc.BillingPostalCode;
        endereco.endereco = acc.BillingStreet;
        endereco.logradouro = acc.CEC_BillingAddressType__c;
        endereco.numero = acc.CEC_BillingNumber__c;
        endereco.complemento = acc.CEC_BillingComplement__c;
        endereco.bairro = acc.CEC_BillingNeighborhood__c;
        endereco.cidade = acc.BillingCity;
        endereco.uf = acc.BillingState;
        
        return endereco;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura Recebedor com os dados baseados na Ordem dada como parametro
    */    
    private static Recebedor getRecebedor(Order ord){
        Recebedor recebedor = new Recebedor();
        List<Recebedores> lstRecebedores = new List<Recebedores>();
        
        Recebedores rec1 = new Recebedores();
        rec1.nomeCompleto = ord.ReceiverFullName1__c;
        rec1.celular = ord.ReceiverMobile1__c;
        rec1.telefone = ord.ReceiverPhone1__c;
        rec1.rg = ord.ReceiverRG1__c;
        lstRecebedores.add(rec1);
        
        Recebedores rec2 = new Recebedores();
        rec2.nomeCompleto = ord.ReceiverFullName2__c;
        rec2.celular = ord.ReceiverMobile2__c;
        rec2.telefone = ord.ReceiverPhone2__c;
        rec2.rg = ord.ReceiverRG2__c;
        lstRecebedores.add(rec2);
        
        Recebedores rec3 = new Recebedores();
        rec3.nomeCompleto = ord.ReceiverFullName3__c;
        rec3.celular = ord.ReceiverMobile3__c;
        rec3.telefone = ord.ReceiverPhone3__c;
        rec3.rg = ord.ReceiverRG3__c;
        lstRecebedores.add(rec3);
        recebedor.recebedores = lstRecebedores;
        return recebedor;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna uma lista de serviços usada no ResumoDadosCliente
    */      
    private static List<PossuiServicos> getListPossuiServicos(Account acc){
        List<PossuiServicos> lstServicos = new List<PossuiServicos>();
        
        PossuiServicos servNET = new PossuiServicos();
        servNET.nome = EMPRESA_NET;
        serVNET.valor = acc.NETClient__c;
        lstServicos.add(serVNET);
        
        PossuiServicos servEmbratel = new PossuiServicos();
        servEmbratel.nome = EMPRESA_EMBRATEL;
        servEmbratel.valor = acc.EmbratelClient__c;
        lstServicos.add(servEmbratel);
        
        return lstServicos;
    }

    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Retorna a estrutura Recebedor com os dados baseados na Ordem dada como parametro
    */      
    private static List<ContatosAdministrador> getContatosAdministrador(List<Contact> lstCtt, List<AccountContactRelation> cttRelation){
        List<ContatosAdministrador> lstCttAdm = new List<ContatosAdministrador>();
        
        for(AccountContactRelation iAccountContactRelation : cttRelation) {
            ContatosAdministrador cttAdm = new ContatosAdministrador();
            
            cttAdm.nomeCompleto = iAccountContactRelation.Contact.FirstName + ' ' + iAccountContactRelation.Contact.LastName;
            cttAdm.sexo = iAccountContactRelation.Contact.Gender__c; 
            cttAdm.nascimento = String.ValueOf(iAccountContactRelation.Contact.Birthdate);
            cttAdm.telefone = iAccountContactRelation.Phone__c;
            cttAdm.celular = iAccountContactRelation.MobilePhone__c;
            cttAdm.email = iAccountContactRelation.Email__c;
            cttAdm.representante = iAccountContactRelation.ResponsibleForTheSignature__c == true;
            cttAdm.cargo = iAccountContactRelation.Roles;
            
            lstCttAdm.add(cttAdm);
        }
        
        return lstCttAdm;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém os dados para a estrutura ResumoPedido baseado nos parametros dados
    */     
    private static ResumoPedido getResumoPedido(List<OrderItem> lstOrderItem, Order ord, Account acc){
        ResumoPedido resumo = new ResumoPedido();
        resumo.tipoPagamento = currentOrder.Payment_Term__c;
        resumo.linhas = getQtdLinhas(lstOrderItem);
        resumo.servicos = getValorTotalServicos(lstOrderItem);
        resumo.aparelhos = getQtdAparelho(lstOrderItem);
        resumo.equipamentos = getValorTotalAparelho(lstOrderItem);
        resumo.pontosAcumulados = Integer.ValueOf(ord.Accumulated_Loyalty_Points__c) / 100;
        resumo.pontosUtilizados = Integer.ValueOf(ord.Consumed_Loyalty_Points__c) / 100 * (-1);
        resumo.pontosSaldo = resumo.pontosAcumulados - resumo.pontosUtilizados;
        resumo.ld21 = currentOrder.LD21__c;
        resumo.planos = getListPlanos(lstOrderItem);
        if (acc.CommercialSegment__c == 'TOP PME') {
            resumo.tradeInInd = tradeInInd;       
            resumo.tradeInComp = tradeInComp;
        }
        return resumo;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Calcula o valor total dos aparelhos de uma lista de OrderItem
    */     
    private static Decimal getValorTotalAparelho(List<OrderItem> lstOrderItem){
        Decimal valorTotal = 0;
        for(OrderItem item : lstOrderItem){
            if(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                valorTotal+= item.vlocity_cmt__RecurringTotal__c;
            }
        }
        return valorTotal;
    }

    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Calcula a quantidade total dos aparelhos de uma lista de OrderItem
    */  
    private static Integer getQtdAparelho(List<OrderItem> lstOrderItem){
        Integer qtd = 0;
        for(OrderItem item : lstOrderItem){
            if(TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                qtd+= Integer.ValueOf(item.Quantity);
            }
        }
        return qtd;
    }
    
	/*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Calcula o valor total dos serviços de uma lista de OrderItem
    */  
    private static Decimal getValorTotalServicos(List<OrderItem> lstOrderItem){
        Decimal valorTotal = 0;
        for(OrderItem item : lstOrderItem){
            if((item.vlocity_cmt__RecurringTotal__c != null && 
                !(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)))){
                valorTotal += item.vlocity_cmt__RecurringTotal__c;
            }
        }
        return valorTotal;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Calcula a quantidade total de linhas de uma lista de OrderItem
    */ 
    private static Integer getQtdLinhas(List<OrderItem> lstOrderItem) {
        Integer quantidadeLinhas = 0;
        
        Map<Id, OrderItem> mapOrderItem = new Map<Id, OrderItem>(lstOrderItem);
        for(OrderItem orderItem : lstOrderItem) {
            if(TIPO_PROD_APARELHO.equals(orderItem.Product2.vlocity_cmt__Type__c) && mapOrderItem.containsKey(orderItem.ReliesOnReferenceId__c)) {
                quantidadeLinhas += Integer.valueOf(orderItem.Quantity);
            }
        }
        return quantidadeLinhas;
    }   
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém a lista de planos de acordo com a lista de OrderItem
    */ 
    private static List<Planos> getListPlanos(List<OrderItem> lstOrderItem){
        List<Planos> lstPlanos = new List<Planos>();
		Set<Id> pluginsSet = new Set<Id>();
        Boolean quebrarLoop = false; // Quebra o loop para vir apenas um item compartilhado no JSON
        
        for(OrderItem item : lstOrderItem){
            if(TIPO_FRANQUIA_IND.equals(item.Product2.ProductCode)){
                for(OrderItem itemFranquia : lstOrderItem){
                    if(itemFranquia.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c){
                        Planos plano = new Planos();
                        plano.tipoPlano = item.Product2.Name;
                        plano.tipo = itemFranquia.TypeOfRequest__c;
                        plano.regional = itemFranquia.ParentGroup__c;
                        plano.uf = itemFranquia.Group__c;
                        plano.ddd = itemFranquia.Subgroup__c;
                        plano.qtdLinha = itemFranquia.Quantity.intValue();
                        plano.grupo = itemFranquia.PlanGroup__c;
                        plano.bonus = itemFranquia.BonusValue__c;
                        plano.kit = itemFranquia.vlocity_cmt__ItemName__c;
                        
                        if(itemFranquia.vlocity_cmt__RecurringDiscountPrice__c==null){
                            plano.discount = 0;
                        }else{
                            plano.discount = itemFranquia.vlocity_cmt__RecurringDiscountPrice__c;
                        }
						plano.descontoVolume = plano.discount * plano.qtdLinha;
                        
                        plano.total = getTotalPlano(itemFranquia, lstOrderItem);
                        
                        plano.servicosAdicionais = getServicosAdicionais(itemFranquia, lstOrderItem);

                        plano.servicosAdicionaisPassagem = getVerifyPassagem(itemFranquia, lstOrderItem);                        
                        plano.servicosAdicionaisBonus = getVerifyBonus(itemFranquia, lstOrderItem);
                        plano.servicosAdicionaisSVA = getVerifySVA(itemFranquia, lstOrderItem); 
                        
                        plano.valorComDesconto = plano.total-plano.descontoVolume;
                        
                        EquipamentosGrupo equipGrupo = new EquipamentosGrupo();
                        equipGrupo.regional = plano.regional;
                        equipGrupo.uf = plano.uf;
                        equipGrupo.ddd = plano.ddd;
                        equipGrupo.qtdLinha = plano.qtdLinha;
                        equipGrupo.franquia = itemFranquia.Product2.Name;
                        equipGrupo.grupo = itemFranquia.PlanGroup__c;
                        equipGrupo.equipamentos = getEquipamentos(itemFranquia, lstOrderItem);
                        plano.equipamentosGrupo = new List<EquipamentosGrupo>();
                        plano.equipamentosGrupo.add(equipGrupo);
                        
                        plano.totalEquipamentos = 0;
                        
                        if (equipGrupo.equipamentos != null) {
                            for (Equipamentos eq : equipGrupo.equipamentos) {
                                plano.totalEquipamentos += eq.valor * eq.quantidade;
                            }
                        }
                        tradeInInd = item.tradeIn__c;
                        lstPlanos.add(plano);
                    }
        		}
            }
            else if(TIPO_FRANQUIA_COMP.equals(item.Product2.ProductCode)) {
                for(OrderItem itemFranquia : lstOrderItem) {
                    if(itemFranquia.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c) {
                        //if (quebrarLoop) { break; }
                        //pluginsSet.add(itemPlugin.Id);
                        Planos plano = new Planos();
                        plano.tipoPlano = item.Product2.Name;
                        plano.typeVlocity = item.Product2.vlocity_cmt__Type__c;
                        //plano.tipo = itemPlugin.TypeOfRequest__c;
                        plano.tipo = HIFEN;
                        plano.regional = itemFranquia.ParentGroup__c;
                        plano.uf = itemFranquia.Group__c;
                        plano.ddd = HIFEN; //itemPlugin.Subgroup__c;
                        plano.qtdLinha = itemFranquia.Quantity.intValue();
                        plano.grupo = ''; //itemPlugin.PlanGroup__c;
                        plano.total = getTotalPlano(itemFranquia, lstOrderItem);
                        
                        plano.servicosAdicionais = getServicosAdicionais(itemFranquia, lstOrderItem);
                        plano.servicosAdicionaisPassagem = getVerifyPassagem(itemFranquia, lstOrderItem); 
                        plano.servicosAdicionaisBonus = getVerifyBonus(itemFranquia, lstOrderItem);   
                        plano.servicosAdicionaisSVA = getVerifySVA(itemFranquia, lstOrderItem);                         
                        
                        plano.equipamentosGrupo = getEquipamentosGrupo(itemFranquia, lstOrderItem);
                        plano.totalEquipamentos = 0;
                        
                        if (plano.equipamentosGrupo != null) {
                            for (EquipamentosGrupo eqGrupo : plano.equipamentosGrupo) {
                                if (eqGrupo.equipamentos != null){
                                    for (Equipamentos eq : eqGrupo.equipamentos) {
                                        plano.totalEquipamentos += eq.valor * eq.quantidade;
                                    }
                                }
                            }
                        }
                        
                        plano.grupos = getGrupos(itemFranquia, lstOrderItem);
                        plano.qtdLinha = 0;
                        for (Grupo g : plano.grupos) {
                            plano.qtdLinha += g.linhas;
                            for (Produto p : g.produtos){
                                plano.total += p.valor;
                            }
                            plano.grupo = plano.grupo != null ? (plano.grupo += (g.grupo + ', ')) : '';
                        }
                        
                        if (plano.grupo.length() > 2) {
                            plano.grupo = plano.grupo.substring(0, plano.grupo.length()-2);
                        }
                        tradeInComp = item.tradeIn__c;
                        lstPlanos.add(plano);
                        quebrarLoop = true;
                    }
                }
            }
        }
        
        return lstPlanos;
    }

    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Calcula o valor total dos planos de uma lista de OrderItem, filhos de um dado OrderItem
    */     
    private static Decimal getTotalPlano(OrderItem itemPai, List<OrderItem> lstOrderItem){
        Decimal valorTotal = 0;
        valorTotal+= itemPai.vlocity_cmt__EffectiveRecurringTotal__c;
        for(OrderItem itemFilho : lstOrderItem) {
            if(itemFilho.ReliesOnReferenceId__c == itemPai.vlocity_cmt__AssetReferenceId__c) {
                if(TIPO_PROD_SERVICO.equals(itemFilho.Product2.vlocity_cmt__Type__c) || TIPO_PROD_PASSAPORTE.equals(itemFilho.Product2.vlocity_cmt__Type__c) || TIPO_PROD_GESTOR.equals(itemFilho.Product2.vlocity_cmt__Type__c)){
                    valorTotal += itemFilho.vlocity_cmt__EffectiveRecurringTotal__c;
                }
            }
        }
        
        return valorTotal;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém uma lista da estrutura EquipamentosGrupo, que contém uma lista de equipamentos
    */  
    private static List<EquipamentosGrupo> getEquipamentosGrupo(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<EquipamentosGrupo> equipGrupos = new List<EquipamentosGrupo>();
        //getEquipamentosGrupo(itemPlugin, lstOrderItem);
        
        for (OrderItem itemGrupo : lstOrderItem) {
            if (itemGrupo.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c) {
                system.debug('itemGrupo ' + itemGrupo);
                if (TIPO_PROD_PLUGIN.equals(itemGrupo.Product2.vlocity_cmt__Type__c)) {
                    EquipamentosGrupo equipGrupo = new EquipamentosGrupo();
                    //equipGrupo.franquia = splitFranquiaNames(itemGrupo.Product2.Name)[1];
                    equipGrupo.franquia = itemFranquia.Product2.Name;
                    equipGrupo.regional = itemFranquia.ParentGroup__c;
                    equipGrupo.ddd =  itemGrupo.Subgroup__c;
                    equipGrupo.uf = itemFranquia.Group__c;
                    equipGrupo.qtdLinha = (Integer)itemGrupo.Quantity;
                    equipGrupo.equipamentos = getEquipamentos(itemGrupo, lstOrderItem);
                    for (Equipamentos eqItem : equipGrupo.equipamentos) {
                        if (equipGrupo.equipamentos != null) {
                            equipGrupo.grupo = eqItem.grupo;
                            break;
                        }
                    }
                    
                    if (equipGrupo.equipamentos.size() > 0) {
                        equipGrupos.add(equipGrupo);
                    }
                }
            }
        }
        
        return equipGrupos;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém uma lista, com dados, da estrutura Equipamentos
    */     
    private static List<Equipamentos> getEquipamentos(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<Equipamentos> lstEquipamentos = new List<Equipamentos>();
        
        for(OrderItem itemEquipamento : lstOrderItem){
            if(itemEquipamento.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if(TIPO_PROD_APARELHOS.equals(itemEquipamento.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHO.equals(itemEquipamento.Product2.vlocity_cmt__Type__c)){
                    Equipamentos equip = new Equipamentos();
                    equip.numeroLinha = itemEquipamento.PortabilityNumber__c;
                    equip.equipamento = itemEquipamento.Product2.Name;
                    equip.quantidade = itemEquipamento.Quantity;
                    equip.pontosUtilizados = itemEquipamento.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c;
                    equip.faixaUtilizada = '';
                    equip.faixaUtilizada = itemEquipamento.vlocity_cmt__OneTimeLoyaltyTotal__c == 0 
                        && itemEquipamento.Product2.vlocity_cmt__Type__c.equals(TIPO_PROD_APARELHOS) ? itemFranquia.Product2.Name : '';
                    equip.valor = itemEquipamento.vlocity_cmt__RecurringCharge__c;
                    equip.grupo = itemFranquia.PlanGroup__c;
                    for (OrderItem parent : lstOrderItem) {
                        if (parent.vlocity_cmt__AssetReferenceId__c == itemEquipamento.ReliesOnReferenceId__c && parent.PlanGroup__c != null) {
                            equip.grupo = parent.PlanGroup__c; 
                            break;
                        }
                    }
                    
                    lstEquipamentos.add(equip);
                    
                    if (TIPO_PROD_APARELHOS.equals(itemEquipamento.Product2.vlocity_cmt__Type__c)) {
                        lstEquipamentos.AddAll(getEquipamentos(itemEquipamento, lstOrderItem));
                    }
                }
            }
        }
        
        return lstEquipamentos;
    }

    private static ServicosAdicionaisPassagem getVerifyPassagem(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<Servicos> lstServicos = new List<Servicos>();
        ServicosAdicionaisPassagem servAdicPassagem = new ServicosAdicionaisPassagem();

        for(OrderItem itemServico : lstOrderItem){
            if(itemServico.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if(TIPO_PROD_PASSAPORTE.equals(itemServico.Product2.vlocity_cmt__SubType__c)){
                    Servicos servico = new Servicos();
                    String[] tuple = splitFranquiaNames(itemServico.Product2.Name);
                       
                    servico.nome = itemServico.Product2.Name;
                    servico.type = itemServico.Product2.vlocity_cmt__Type__c;
                    servico.subtype = itemServico.Product2.vlocity_cmt__SubType__c;
                    servico.detalhes = tuple[1];
                    
                    servico.valor = itemServico.vlocity_cmt__RecurringCharge__c;
                    lstServicos.add(servico);
                }
            }
        }    

        if(lstServicos.size() >=1){
           servAdicPassagem.passagem = true;
           servAdicPassagem.servicos = lstServicos;
        }
        else{
           servAdicPassagem.passagem = false;
        }
        
        //servAdicSVA.servicos = lstServicos;
        return servAdicPassagem;
    }
    
    private static ServicosAdicionaisBonus getVerifyBonus(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<Servicos> lstServicos = new List<Servicos>();
        ServicosAdicionaisBonus servAdicBonus = new ServicosAdicionaisBonus();

        for(OrderItem itemServico : lstOrderItem){
            if(itemServico.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if(TIPO_PROD_BONUS.equals(itemServico.Product2.vlocity_cmt__Type__c)){
                    Servicos servico = new Servicos();
                       
                    servico.nome = itemServico.Product2.Name;
                    servico.subtype = itemServico.Product2.vlocity_cmt__SubType__c;
                    lstServicos.add(servico);
                }
            }
        }    

        if(lstServicos.size() >=1){
           servAdicBonus.bonus = true;
           servAdicBonus.servicos = lstServicos;
        }
        else{
           servAdicBonus.bonus = false;
        }
        
        return servAdicBonus;
    }
    
    private static ServicosAdicionaisSVA getVerifySVA(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<Servicos> lstServicos = new List<Servicos>();
        ServicosAdicionaisSVA servAdicSVA = new ServicosAdicionaisSVA();
        
        //servAdicSVA.franquia = itemFranquia.Product2.Name;
        //servAdicSVA.valor = itemFranquia.vlocity_cmt__RecurringCharge__c;

        for(OrderItem itemServico : lstOrderItem){
            if(itemServico.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if((TIPO_PROD_SERVICO.equals(itemServico.Product2.vlocity_cmt__Type__c) 
                   || TIPO_PROD_BACKUP.equals(itemServico.Product2.vlocity_cmt__Type__c)
                   || TIPO_PROD_GESTOR.equals(itemServico.Product2.vlocity_cmt__Type__c)) 
                   && !TIPO_PROD_PASSAPORTE.equals(itemServico.Product2.vlocity_cmt__SubType__c)){
                    Servicos servico = new Servicos();
                    String[] tuple = splitFranquiaNames(itemServico.Product2.Name);
                       
                    servico.nome = itemServico.Product2.Name;
                    servico.type = itemServico.Product2.vlocity_cmt__Type__c;
                    servico.subtype = itemServico.Product2.vlocity_cmt__SubType__c;
                    servico.detalhes = tuple[1];
                    
                    //servico.valor = itemServico.TotalPrice;
                    servico.valor = itemServico.vlocity_cmt__RecurringCharge__c;
                    lstServicos.add(servico);
                }
            }
        }    

        if(lstServicos.size() >=1){
           servAdicSVA.sva = true;
           servAdicSVA.servicos = lstServicos;
        }
        else{
           servAdicSVA.sva = false;
        }
        
        //servAdicSVA.servicos = lstServicos;
        return servAdicSVA;
    }
                       
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém a estrutura ServicosAdicionais com os respectivos dados
    */     
    private static ServicosAdicionais getServicosAdicionais(OrderItem itemFranquia,List<OrderItem> lstOrderItem){
        List<Servicos> lstServicos = new List<Servicos>();
        ServicosAdicionais servAdicionais = new ServicosAdicionais();
        
        servAdicionais.franquia = itemFranquia.Product2.Name;
        //servAdicionais.valor = itemFranquia.TotalPrice;
        servAdicionais.valor = itemFranquia.vlocity_cmt__RecurringCharge__c;
        
        for(OrderItem itemServico : lstOrderItem){
            if(itemServico.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                if(TIPO_PROD_SERVICO.equals(itemServico.Product2.vlocity_cmt__Type__c) || TIPO_PROD_PASSAPORTE.equals(itemServico.Product2.vlocity_cmt__Type__c) 
                   || TIPO_PROD_BACKUP.equals(itemServico.Product2.vlocity_cmt__Type__c) || TIPO_PROD_BONUS.equals(itemServico.Product2.vlocity_cmt__Type__c) || TIPO_PROD_GESTOR.equals(itemServico.Product2.vlocity_cmt__Type__c) ){
                    Servicos servico = new Servicos();
                    String[] tuple = splitFranquiaNames(itemServico.Product2.Name);
                       
                    servico.nome = itemServico.Product2.Name;
                    servico.type = itemServico.Product2.vlocity_cmt__Type__c;
                    servico.subtype = itemServico.Product2.vlocity_cmt__SubType__c;
                    servico.detalhes = tuple[1];
                    
                    //servico.valor = itemServico.TotalPrice;
                    servico.valor = itemServico.vlocity_cmt__RecurringCharge__c;
                    lstServicos.add(servico);
                }
            }
        }    
        
        servAdicionais.servicos = lstServicos;
        return servAdicionais;
        
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Separa o nome da franquia para obter a quantidade de dados e exibir com mais precisão no Resumo
    * Ex. <Nome da Franquia> <valor>GB
    */ 
    @TestVisible
    private static String[] splitFranquiaNames(String nomeFranquia) {
        String nome = '';
        String[] splitName = nomeFranquia.split(' ');
        String detalhes = HIFEN; 
        String[] tuple = new String[2];
        if (splitName.size() > 1) {
            nome = '';
            detalhes = splitName[splitName.size()-1];
            for (Integer i=0; i < splitName.size()-1; i++) {
                nome += splitName[i] + ' ';
            }
            if (!detalhes.contains(CONST_GB) || !detalhes.contains(CONST_TB)) {
                detalhes = HIFEN;
            }
            else {
                tuple[0] = nome.trim();
                tuple[1] = detalhes.trim();
                return tuple;
            }
        }
        
        tuple[0] = nomeFranquia;
        tuple[1] = detalhes;
        
        return tuple;
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Obtém a lista de Grupos do Compartilhado
    */
    private static List<Grupo> getGrupos(OrderItem itemFranquia,List<OrderItem> lstOrderItem){
        List<Grupo> lstGrupo = new List<Grupo>();
        
        List<OrderItem> lstServicos = new List<OrderItem>();
        List<Produto> lstProdutos = new List<Produto>();
        
        // Filho do plugin -> reliesOn == plugin.assetId;
        for (OrderItem itemGrupo : lstOrderItem) {
            if (itemGrupo.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c) {
                if (TIPO_PROD_PLUGIN.equals(itemGrupo.Product2.vlocity_cmt__Type__c)) {
                    Grupo grupo = new Grupo();
                    grupo.ddd =  Integer.valueOf(itemGrupo.Subgroup__c);
                    grupo.grupo = itemGrupo.PlanGroup__c;
                    grupo.linhas = (Integer)itemGrupo.Quantity;
                    grupo.tipo = itemGrupo.TypeOfRequest__c;
                    grupo.produtos = new List<Produto>();
                    Produto p = new Produto();
                    p.nome = itemGrupo.Product2.Name;
                    p.valor = itemGrupo.vlocity_cmt__RecurringTotal__c;
                    grupo.produtos.add(p);
                    
                    for (OrderItem subItem : lstOrderItem) {
                        if (subItem.ReliesOnReferenceId__c == itemGrupo.vlocity_cmt__AssetReferenceId__c && !(TIPO_PROD_APARELHOS.equals(subItem.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHO.equals(subItem.Product2.vlocity_cmt__Type__c))) {
                            Produto prod = new Produto();
                            prod.nome = subItem.Product2.Name ;
                            prod.valor = subItem.vlocity_cmt__RecurringTotal__c;
                            Integer prodDDD = Integer.valueOf(subItem.Subgroup__c);
                            grupo.produtos.add(prod);
                        }
                    }
                    lstGrupo.add(grupo);
                }
            }
        }
        
        return lstGrupo;
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Query que retorna a Order de acordo com o Order Id
    */
    private static Order getOrder(String idPedido){
        return [SELECT id,
                AccountId,
                Related_Contacts__c,
                DeliveryMethod__c,
                vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c,
                Consumed_Loyalty_Points__c,
                Accumulated_Loyalty_Points__c,
                Payment_Term__c,
                ReceiverFullName1__c,
                ReceiverFullName2__c,
                ReceiverFullName3__c,
                ReceiverMobile1__c,
                ReceiverMobile2__c,
                ReceiverMobile3__c,
                ReceiverPhone1__c,
                ReceiverPhone2__c,
                ReceiverPhone3__c,
                ReceiverRG1__c,
                ReceiverRG2__c,
                ReceiverRG3__c,
                LD21__c
                FROM Order
                WHERE id =: idPedido];
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Query que retorna uma lista de OrderItem de acordo com o Order Id
    */
    private static List<OrderItem> getOrderItem(String idPedido){
        return [SELECT id,
                PlanGroup__c,
                Product2.Name,
                Product2.ProductCode,
                Product2.vlocity_cmt__Type__c,
                Product2.vlocity_cmt__SubType__c,
                PortabilityNumber__c,
                Operator__c,
                Product2.Color__c,
                DeviceSecondOptionColor__c,
                AnotherDeviceColor__c,
                ReliesOnReferenceId__c,
                vlocity_cmt__AssetReferenceId__c,
                TypeOfRequest__c,
                ParentGroup__c,
                Group__c,
                Subgroup__c,
                Quantity,
                TotalPrice,
                DonatorDocumentNumber__c,
                DonatorEmail__c,
                DonatorName__c,
                DonatorPhone__c,
                vlocity_cmt__OneTimeLoyaltyTotal__c,
                vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c,
                vlocity_cmt__EffectiveRecurringTotal__c,
                vlocity_cmt__RecurringTotal__c,
                vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__RecurringDiscountPrice__c,
                ICCID__c,
                IMEI__c,
                BonusValue__c,
                TradeIn__c,
                vlocity_cmt__ItemName__c
                FROM OrderItem
                WHERE OrderId =: idPedido];
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Query que retorna uma Account de acordo com o Id da conta
    */
    private static Account getAccount(String idConta){
        return [SELECT id, 
                Name,
                CNPJFormula__c,
                MunicipalSubscription__c,
                MunicipalRegistrationExempted__c,
                StateSubscription__c,
                StateRegistrationExempted__c,
                CNAE__c	,
                CNAE2__c,
                NumberOfEmployeesList__c,
                CompanyClass__c,
                CommercialSegment__c,
                DueDay__c,
                NETClient__c,
                EmbratelClient__c,
                NetEmbratelClient__c,
                NETContractNumber__c,
                BillingPostalCode,
                BillingStreet,
                BillingCity,
                BillingState,
                CEC_BillingAddressType__c,
                CEC_BillingNumber__c,
                CEC_BillingComplement__c,
                CEC_BillingNeighborhood__c,
                ShippingPostalCode,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                CEC_ShippingNumber__c,
                CEC_ShippingAddressType__c,
                CEC_ShippingNeighborhood__c,
                CEC_ShippingComplement__c
                FROM Account
                WHERE id =: idConta];
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Query que retorna uma lista de contatos de acordo com uma lista de AccountContactRelation
    */
    private static List<Contact> getContact(List<AccountContactRelation> acrList){
        List<Id> contactIdList = new List<Id>();
        for (AccountContactRelation acr : acrList) {
            contactIdList.add(acr.ContactId);
        }
        
        return [SELECT Id,
                FirstName,
                LastName,
                Gender__c,
                Birthdate
                FROM Contact
                WHERE Id IN :contactIdList
                AND DocumentNumber__c != null];
    }
    
    /*
    * Autores: 
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Query que retorna uma lista de AccountContactRelation de acordo com um set de Ids de AccountContactRelation
    */
    private static List<AccountContactRelation> getContactRelation(Set<Id> idSet) {       
        return [SELECT Id,
                AccountId,
                ContactId,
                Email__c,
                MobilePhone__c,
                Phone__c,
                ResponsibleForTheSignature__c,
                Roles,
                Contact.FirstName,
                Contact.LastName,
                Contact.Gender__c,
                Contact.Birthdate
                FROM AccountContactRelation
                WHERE Id IN :idSet
                AND Contact.DocumentNumber__c != null];
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Data, raíz dos dados de Resumo
    */
    public class Data {
        @AuraEnabled public String tipoEntrega 							{ get; set; }
        @AuraEnabled public ResumoDadosCliente resumoDadosCliente 		{ get; set; }
        @AuraEnabled public ResumoPedido resumoPedido 					{ get; set; }
        @AuraEnabled public AssociacaoAparelhos associacaoAparelhos		{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura ResumoDadosCliente
    */
    public class ResumoDadosCliente {
        @AuraEnabled public DadosEmpresa dadosEmpresa 					{ get; set; }
        @AuraEnabled public Endereco enderecoPrincipal 					{ get; set; }
        @AuraEnabled public Endereco enderecoCobranca 					{ get; set; }
        @AuraEnabled public Recebedor recebedor 						{ get; set; }
        @AuraEnabled public List<ContatosAdministrador> contatosAdministrador { get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Recebedor (Dados do Cliente)
    */
    public class Recebedor {
        @AuraEnabled public List<Recebedores> recebedores 				{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Sessao
    */
    public class Sessao {
        @AuraEnabled public String tipo									{ get; set; }
        @AuraEnabled public String regional								{ get; set; }
        @AuraEnabled public String uf									{ get; set; }
        @AuraEnabled public String ddd									{ get; set; }
        @AuraEnabled public String franquia								{ get; set; }
        @AuraEnabled public String qtdLinha								{ get; set; }
        @AuraEnabled public String grupos								{ get; set; }
        @AuraEnabled public TipoNovo tipoNovo 							{ get; set; }
        @AuraEnabled public TipoTransferencia tipoTransferencia 		{ get; set; }
        @AuraEnabled public TipoPortabilidade tipoPortabilidade 		{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura TipoNovo
    */
    public class TipoNovo {
        @AuraEnabled public Boolean pendente							{ get; set; }
        @AuraEnabled public List<Itens> itens							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura TipoTransferencia
    */
    public class TipoTransferencia {
        @AuraEnabled public Boolean pendente							{ get; set; }
        @AuraEnabled public List<Doadores> doadores						{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura TipoPortabilidade
    */
    public class TipoPortabilidade {
        @AuraEnabled public Boolean pendente							{ get; set; }
        @AuraEnabled public List<Itens> itens							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Doadores (para Transferência)
    */
    public class Doadores {
        @AuraEnabled public String nome 								{ get; set; }
        @AuraEnabled public String cpf 									{ get; set; }
        @AuraEnabled public String telefone 							{ get; set; }
        @AuraEnabled public String email 								{ get; set; }
        @AuraEnabled public List<Itens> itens 							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Grupo (para Compartilhado)
    */
    public class Grupo {
        @AuraEnabled public Integer ddd 								{ get; set; }
        @AuraEnabled public Integer linhas 								{ get; set; }
        @AuraEnabled public String grupo								{ get; set; }
        @AuraEnabled public String tipo									{ get; set; }
        @AuraEnabled public List<Produto> produtos						{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Produto
    */
    public class Produto {
        @AuraEnabled public String nome									{ get; set; }
        @AuraEnabled public Decimal valor								{ get; set; }
        @AuraEnabled public Integer ddd									{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Itens (Associação de Aparelhos)
    */
    public class Itens {
        @AuraEnabled public String linha								{ get; set; }
        @AuraEnabled public String modelo								{ get; set; }
        @AuraEnabled public String iccid								{ get; set; }
        @AuraEnabled public String imei									{ get; set; }
        @AuraEnabled public String cor									{ get; set; }
        @AuraEnabled public String cores								{ get; set; }
        @AuraEnabled public String operadora							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Recebedores (Dados do Cliente)
    */
    public class Recebedores {
        @AuraEnabled public String nomeCompleto							{ get; set; }
        @AuraEnabled public String rg									{ get; set; }
        @AuraEnabled public String telefone								{ get; set; }
        @AuraEnabled public String celular								{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura ResumoPedido (Total de linhas, planos etc)
    */
    public class ResumoPedido {
        @AuraEnabled public Integer linhas								{ get; set; }
        @AuraEnabled public Decimal servicos							{ get; set; }
        @AuraEnabled public Integer aparelhos							{ get; set; }
        @AuraEnabled public Decimal equipamentos						{ get; set; }
        @AuraEnabled public Integer pontosAcumulados					{ get; set; }
        @AuraEnabled public Integer pontosUtilizados					{ get; set; }
        @AuraEnabled public Integer pontosSaldo							{ get; set; }
        @AuraEnabled public String tipoPagamento						{ get; set; }
        @AuraEnabled public String ld21									{ get; set; }
        @AuraEnabled public String tradeInInd							{ get; set; }
        @AuraEnabled public String tradeInComp							{ get; set; }
        @AuraEnabled public List<Planos> planos							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura ContatosAdministrador
    */
    public class ContatosAdministrador {
        @AuraEnabled public String nomeCompleto							{ get; set; }
        @AuraEnabled public String sexo									{ get; set; }
        @AuraEnabled public String nascimento							{ get; set; }
        @AuraEnabled public String telefone								{ get; set; }
        @AuraEnabled public String celular								{ get; set; }
        @AuraEnabled public String email								{ get; set; }
        @AuraEnabled public Boolean representante						{ get; set; }
        @AuraEnabled public String cargo								{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Equipamentos
    */
    public class Equipamentos {
        @AuraEnabled public String numeroLinha							{ get; set; }
        @AuraEnabled public String equipamento							{ get; set; }
        @AuraEnabled public Decimal quantidade							{ get; set; }
        @AuraEnabled public Decimal pontosUtilizados					{ get; set; }
        @AuraEnabled public String faixaUtilizada						{ get; set; }
        @AuraEnabled public String grupo								{ get; set; }
        @AuraEnabled public Decimal valor								{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura EquipamentosGrupo
    */
    public class EquipamentosGrupo {
        @AuraEnabled public String regional								{ get; set; }
        @AuraEnabled public String uf									{ get; set; }
        @AuraEnabled public String ddd									{ get; set; }
        @AuraEnabled public String franquia								{ get; set; }
        @AuraEnabled public Integer qtdLinha							{ get; set; }
        @AuraEnabled public String grupo								{ get; set; }
        @AuraEnabled public List<Equipamentos> equipamentos				{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura AssociacaoAparelhos
    */
    public class AssociacaoAparelhos {
        @AuraEnabled public List<Sessao> sessao							{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Planos
    */
    public class Planos {
        @AuraEnabled public String tipoPlano							{ get; set; }
        @AuraEnabled public String typeVlocity							{ get; set; }        
        @AuraEnabled public String tipo									{ get; set; }
        @AuraEnabled public String regional								{ get; set; }
        @AuraEnabled public String franquia								{ get; set; }
        @AuraEnabled public String uf									{ get; set; }
        @AuraEnabled public String ddd									{ get; set; }
        @AuraEnabled public Integer qtdLinha							{ get; set; }
        @AuraEnabled public String grupo								{ get; set; }
        @AuraEnabled public String bonus								{ get; set; }
        @AuraEnabled public Decimal total								{ get; set; }
        @AuraEnabled public ServicosAdicionais servicosAdicionais		{ get; set; }
        @AuraEnabled public ServicosAdicionaisPassagem servicosAdicionaisPassagem { get; set; }
        @AuraEnabled public ServicosAdicionaisSVA servicosAdicionaisSVA { get; set; }
        @AuraEnabled public ServicosAdicionaisBonus servicosAdicionaisBonus { get; set; }
        @AuraEnabled public List<Grupo> grupos							{ get; set; }
        @AuraEnabled public List<EquipamentosGrupo> equipamentosGrupo	{ get; set; }
        @AuraEnabled public Decimal totalEquipamentos					{ get; set; }
        @AuraEnabled public Decimal discount							{ get; set; }
        @AuraEnabled public Decimal descontoVolume						{ get; set; }
        @AuraEnabled public Decimal valorComDesconto					{ get; set; }
        @AuraEnabled public String kit									{ get; set; }
        
       
    }

    public class ServicosAdicionaisPassagem {
        @AuraEnabled public List<Servicos> servicos						{ get; set; }
        @AuraEnabled public Boolean passagem							{ get; set; }        
    }
    
    public class ServicosAdicionaisBonus {
        @AuraEnabled public List<Servicos> servicos						{ get; set; }
        @AuraEnabled public Boolean bonus								{ get; set; }        
    }
    
    public class ServicosAdicionaisSVA {
        @AuraEnabled public List<Servicos> servicos						{ get; set; }
        @AuraEnabled public Boolean sva									{ get; set; }        
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura ServicosAdicionais
    */
    public class ServicosAdicionais {
        @AuraEnabled public String franquia								{ get; set; }
        @AuraEnabled public Decimal valor								{ get; set; }
        @AuraEnabled public List<Servicos> servicos						{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Servicos
    */
    public class Servicos {
        @AuraEnabled public String nome									{ get; set; }
        @AuraEnabled public String subtype								{ get; set; }
        @AuraEnabled public String type									{ get; set; }  
        @AuraEnabled public String detalhes								{ get; set; }
        @AuraEnabled public Decimal valor								{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura Endereco
    */
    public class Endereco {
        @AuraEnabled public String cep									{ get; set; }
        @AuraEnabled public String endereco								{ get; set; }
        @AuraEnabled public String logradouro							{ get; set; }
        @AuraEnabled public String numero								{ get; set; }
        @AuraEnabled public String complemento							{ get; set; }
        @AuraEnabled public String bairro								{ get; set; }
        @AuraEnabled public String cidade								{ get; set; }
        @AuraEnabled public String uf									{ get; set; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura DadosEmpresa
    */
    public class DadosEmpresa {
        @AuraEnabled public String razaoSocial 							{ get; set ; }
        @AuraEnabled public String cnpj 								{ get; set ; }
        @AuraEnabled public String inscricaoEstadual 					{ get; set ; }
        @AuraEnabled public Boolean inscricaoEstadualIsento 			{ get; set ; }
        @AuraEnabled public String inscricaoMunicipal 					{ get; set ; }
        @AuraEnabled public Boolean inscricaoMunicipalIsento 			{ get; set ; }
        @AuraEnabled public String cnaePrimario 						{ get; set ; }
        @AuraEnabled public String cnaeSecundario 						{ get; set ; }
        @AuraEnabled public String numeroFuncionarios 					{ get; set ; }
        @AuraEnabled public String tipoEmpresa 							{ get; set ; }
        @AuraEnabled public String segmentoComercial 					{ get; set ; }
        @AuraEnabled public String dataVencimentoFatura 				{ get; set ; }
        @AuraEnabled public List<PossuiServicos> possuiServicos 		{ get; set ; }
        @AuraEnabled public String numeroContrato 						{ get; set ; }
    }
    
    /*
    * Autores: 
    * Marcos Aurelio - Deloitte
    * Daniel Meyer Dammous - Deloitte
    * Descrição: CEC FASE 1 + SQUAD PME
    * Classe da estrutura PossuiServicos (NET | Embratel)
    */
    public class PossuiServicos {
        @AuraEnabled public String nome									{ get; set; }
        @AuraEnabled public Boolean valor								{ get; set; }
    }
    
}