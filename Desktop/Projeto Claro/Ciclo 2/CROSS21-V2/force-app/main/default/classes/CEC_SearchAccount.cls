/*Versão 5.0
* US_179 - Leticia Freitas - 23/11 (CPF/CNJP)
* US_180 - Letícia Freitas - 28/11 (Endereço)
* US_182 - Letícia Freitas - 03/12 (Contrato)
* US_181 - Leticia Freitas - 05/12 (Nome)
* US_183 - Letícia Freitas - 10/12 (MSIDN)
* [12/12] - Letícia Freitas - Ajustes na formatação das mascáras do Campo Tipo de Documento.
* [18/12] - Letícia Freitas - Transporte de Mensagens de Erro para o Front-End.
* [17/01] - Lucas Barbosa  - (Pesquisa de documento nos sistemas da claro para os usuários com perfil comercial).
* [23/04] - Letícia Freitas - Ajuste de otimização das querys com subquerys.
* [07/05] - Letícia Freitas - Ajustes nos métodos para Busca 2.0.
*  Classe que recebe dados para realizar uma busca no objeto cliente.
*  Caso exista o registro, retorna as informações: Nome, Tipo de Documento (CPF ou CNPJ), Número do documento, Número do Documento Formatado, Logradouro, CEP, Cidade e Estado.
* [27/05] - Danilo Fucuhara - Corrigido erro de documento formatado na busca.
* [18/07] - Danilo Fucuhara - Desenvolvimento US18860 adicionado os métodos getContractNBONBA, getProfileNBONBA.
* [19/07] - Letícia Freitas - Otimização de busca.
* [05/08] - Letícia Freitas - Desenvolvimento US19211 adicionado o método getProfileCanaisCriticos.
* [16/01/20] - Victor Araujo - Alteração na busca por CEP no método getByAddress.
*/

public class CEC_SearchAccount
{
    static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    static Id recTypeBusinessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    static Id recTypeConsumerAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId(); 
    
    @AuraEnabled
    public static List<String> getDocumentType()
    {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.DocumentType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple)
        {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static Boolean getProfileNBONBA() {
        return FeatureManagement.checkPermission('Perfil_NBO_NBA');
    }
    
    @AuraEnabled
    public static Boolean getProfileCanaisCriticos() {
        return FeatureManagement.checkPermission('Perfil_Canais_Criticos');
    }
    
    @AuraEnabled
    public static Boolean getProfileComercialUsers() {
        return FeatureManagement.checkPermission('Comercial_Users');
    }

    @AuraEnabled
    public static void throwException(String aMensagem)
    {
        AuraHandledException e = new AuraHandledException(aMensagem);
        e.setMessage(aMensagem);
        throw e; 
    }
    
    
    
    public static List<String> getContractNumber (String id){
        
        List <String> lstContract = new List<String> ();
        
        List<Contract> lstCtc = [Select ContractNumber__c from Contract 
                                 where AccountId =: id];
        
        for (Contract aux : lstCtc){
            String str = aux.ContractNumber__c;
            lstContract.add(str);
        }
        
        return lstContract;
    }
    
    
    @AuraEnabled 
    public static List<searchAccount> getDocument(String text, string type){
        List<SearchAccount> lstSearchAcc = new List<SearchAccount> ();
        String docAux = (type == 'RNE') ? text.replace('-', '') : text.replaceAll('\\D', '');
        Boolean ret;
        
        //CPF
        if (docAux.length() == 11 && type == 'CPF')
        {
            ret = CEC_Utils.validateCPF(text);
        }
        //Cnpj
        else if (docAux.length() == 14 && type == 'CNPJ') 
        {
            ret = CEC_Utils.validateCNPJ(text);
        }
        else if ((String.isNotBlank(type)) && (type != 'CNPJ') && (type != 'CPF'))
        {
            ret = true;
        }else
        {
            throwException('Documento Inválido.');
        }
        
        //Documento válido.
        if (ret)
        {
            List<Account> Conta  = [SELECT
                                    Id,
                                    Name,
                                    Site,
                                    DocumentType__c,
                                    DocumentNumber__c,
                                    ContractNumber__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                    vlocity_cmt__PremisesId__r.Number__c,
                                    vlocity_cmt__PremisesId__r.Complement__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                                    vlocity_cmt__Status__c,
                                    FormattedDocument__c
                                    FROM Account
                                    WHERE DocumentType__c =: type
                                    AND DocumentNumber__c =: docAux
                                    AND (RecordTypeId =: recTypeBusinessAccount OR RecordTypeId =: recTypeConsumerAccount )];
            
            for(Account acc : Conta) {
                acc.ContractReferenceNumber__c = acc.ContractNumber__c;
            }
            
            lstSearchAcc = formatToSearchObject(Conta);
            
        }else{
            throwException('Documento Inválido.');
        }
        
        return lstSearchAcc;
        
    }
    
     @AuraEnabled
    public static map<String, Object> getvalidKeyDocument(String text, String type)
    {
        boolean ret;
        List<Account> Conta  = new List<Account>();
        String docAux = (type == 'RNE') ? text.replace('-', '') : text.replaceAll('\\D', '');
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        lOutMap.put('searchAccountIntegration', false);
        lOutMap.put('accountBase', false);
        
        //CPF
        if (docAux.length() == 11 && type == 'CPF')
        {
            ret = CEC_Utils.validateCPF(text);
        }
        //Cnpj
        else if (docAux.length() == 14 && type == 'CNPJ') 
        {
            ret = CEC_Utils.validateCNPJ(text);
        }
        else if ((String.isNotBlank(type)) && (type != 'CNPJ') && (type != 'CPF'))
        {
            ret = true;
        }else
        {
            throwException('Documento Inválido.');
        }
        
        //Documento válido.
        if (ret)
        {
            Conta  = [SELECT
                      Id,
                      Name,
                      DocumentType__c,
                      DocumentNumber__c,
                      ContractNumber__c,
                      vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                      vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                      vlocity_cmt__PremisesId__r.Number__c,
                      vlocity_cmt__PremisesId__r.Complement__c,
                      vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                      vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                      vlocity_cmt__Status__c,
                      FormattedDocument__c
                      FROM Account
                      WHERE DocumentType__c =: type
                      AND DocumentNumber__c =: docAux
                      AND (RecordTypeId =: recTypeBusinessAccount OR RecordTypeId =: recTypeConsumerAccount )];
            
            for(Account acc : Conta) {
                acc.ContractReferenceNumber__c = acc.ContractNumber__c;
            }
            
            //LB - Se a conta não for encontrada e o usuário fizer parte de um dos perfis comerciais o documento é verificado nos sistemas legados da Claro
            Boolean hasCustomPermission = getPermissionCom();
            
            if ( ( type == 'CPF' || type == 'CNPJ' ) && hasCustomPermission  )
            {
                lOptions.put('CPF', docAux);
                lOptions.put('documentNumberCPF', docAux);
                
                CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
                lInteg.invokeMethod('checkProspect', lInputMap, lOutMap, lOptions);
                
                List<Account> accInt = new list<Account>();
                accInt.add((Account) lOutMap.get('account'));
                
                if (!Conta.isEmpty())
                {
                    for (Account acc: Conta)
                    {
                        if (accInt[0].DocumentNumber__c == acc.DocumentNumber__c)
                        {
                            acc.vlocity_cmt__Status__c = ((Boolean) lOutMap.get('isProspect') ? accInt[0].vlocity_cmt__Status__c : 'Cliente Base');
                            lOutMap.put('accountBase', true);
                        }
                    }
                }
                else
                {
                    Conta.add((Boolean) lOutMap.get('isProspect') ? (Account)lOutMap.get('account') : null);
                }
                
                lOutMap.put('searchAccountIntegration', true);
                // if (lOutMap.get('error') != null) throwException(system.Label.CEC_ServIndisponivel);
            }
                }else{
                    throwException('Documento Inválido.');
                }
        lOutMap.put('account', Conta);
        
        return lOutMap;
    }
   
    
    public static List<searchAccount> premissesToAcc(List<vlocity_cmt__Premises__c> lstPremisses){
        
        Set<ID> setAccId = new set<ID>();
        
        for (vlocity_cmt__Premises__c pre : lstPremisses){
            if(lstPremisses != null){
                for(Account acc: pre.vlocity_cmt__Accounts__r)
                {
                    if(acc.RecordTypeId==recTypeBusinessAccount || acc.RecordTypeId==recTypeConsumerAccount)
                        setAccId.add(acc.Id);
                }
            }
        }
        
        String query = 'Select ID, Name,Site,ContractNumber__c,DocumentType__c,DocumentNumber__c,FormattedDocument__c,'+
            'ContractReferenceNumber__c,'+
            'vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,'+
            'vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,'+
            'vlocity_cmt__Status__c,'+
            'vlocity_cmt__PremisesId__r.Number__c,'+
            'vlocity_cmt__PremisesId__r.Complement__c,'+
            'vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,'+
            'vlocity_cmt__PremisesId__r.vlocity_cmt__State__c '+
            'From Account where Id in: setAccId';
        
        List <Account> lstAcc = database.query(query);
        return formatToSearchObject(lstAcc);
    }
    
    @AuraEnabled
    public static List<searchAccount> getByAddressCepAndNumber(string cep, string numero){
            System.debug('getByAddress: cep>>' + cep + ' >>numero: ' + numero);
        String strQuery = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        String strQuery1 = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        String strQuery2 = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        strQuery += 'from  vlocity_cmt__Premises__c where Id != null';
        strQuery1 += 'from  vlocity_cmt__Premises__c where Id != null';
        strQuery2 += 'from  vlocity_cmt__Premises__c where Id != null';

        if (string.isNotBlank(cep) && string.isNotBlank(numero)){
            String auxCep = string.valueof(cep);
            String auxCep1 = '';
            String auxCep2 = '';

            System.debug('buscar por cep: |' + cep + '|');
            System.debug('auxCep: |' + auxCep + '|');
            strQuery += ' and vlocity_cmt__PostalCode__c =:auxCep ';
            strQuery += ' AND number__c= :numero ';
            
            auxCep1 = auxCep.replace('-','');
            strQuery1 += ' and vlocity_cmt__PostalCode__c =:auxCep1 ';
            strQuery1 += ' AND number__c= :numero ';

            auxCep2 = auxCep1.substring(1);
            strQuery2 += ' and vlocity_cmt__PostalCode__c =:auxCep2 '; 
            strQuery2 += ' AND number__c= :numero '; 
        }
        System.debug('squery: ' + strQuery);
        System.debug('squery1: ' + strQuery1);
        System.debug('squery2: ' + strQuery2);

        List<vlocity_cmt__Premises__c> lstPremisses = database.query(strQuery);
         System.debug('get by addres size: ' + lstPremisses.size());
        List<vlocity_cmt__Premises__c> lstPremisses1 = database.query(strQuery1);
         System.debug('get by addres size1: ' + lstPremisses1.size());
        List<vlocity_cmt__Premises__c> lstPremisses2 = database.query(strQuery2);
         System.debug('get by addres size2: ' + lstPremisses2.size());
         
         if (lstPremisses.size() != 0){
         return premissesToAcc (lstPremisses);
         } else if (lstPremisses1.size() != 0){
         return premissesToAcc (lstPremisses1);
         } else {
         return premissesToAcc (lstPremisses2); 
         }

    }

    @AuraEnabled
    public static List<searchAccount> getByAddress(string cep, string logradouro, string numero, string complemento, string cidade, string uf){
         System.debug('getByAddress: cep>>' + cep + '>>endereco: ' + logradouro + ' >>numero: ' + numero + ' >>complemento: ' + complemento + ' >>cidade:' + cidade + ' >>uf:' + uf);
        String strQuery = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        String strQuery1 = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        String strQuery2 = 'Select Id,(select ID,RecordTypeID from vlocity_cmt__Accounts__r) ';
        strQuery += 'from  vlocity_cmt__Premises__c where Id != null';
        strQuery1 += 'from  vlocity_cmt__Premises__c where Id != null';
        strQuery2 += 'from  vlocity_cmt__Premises__c where Id != null';

        if (string.isNotBlank(cep)){

            String auxCep = string.valueof(cep);
            String auxCep1 = '';
            String auxCep2 = '';

            System.debug('buscar por cep: |' + cep + '|');
            System.debug('auxCep: |' + auxCep + '|');
            strQuery += ' and vlocity_cmt__PostalCode__c =:auxCep ';
            
            auxCep1 = auxCep.replace('-','');
            strQuery1 += ' and vlocity_cmt__PostalCode__c =:auxCep1 ';

            auxCep2 = auxCep1.substring(1);
            strQuery2 += ' and vlocity_cmt__PostalCode__c =:auxCep2 ';

        }

        if (string.isNotBlank(logradouro)){
            logradouro = '%' + logradouro + '%';
            strQuery += ' and vlocity_cmt__StreetAddress__c like :logradouro ';
            strQuery1 += ' and vlocity_cmt__StreetAddress__c like :logradouro ';
            strQuery2 += ' and vlocity_cmt__StreetAddress__c like :logradouro ';
        }

        if (string.isNotBlank(numero)){
            strQuery += ' AND number__c= :numero ';
            strQuery1 += ' AND number__c= :numero ';
            strQuery2 += ' AND number__c= :numero ';
        }

        if (string.isNotBlank(complemento)){
            complemento = '%' + complemento + '%';
            strQuery += ' AND Complement__c like :complemento ';
            strQuery1 += ' AND Complement__c like :complemento ';
            strQuery2 += ' AND Complement__c like :complemento ';
        }

        if (string.isNotBlank(cidade)){
            strQuery += ' AND vlocity_cmt__City__c = :cidade ';
            strQuery1 += ' AND vlocity_cmt__City__c = :cidade ';
            strQuery2 += ' AND vlocity_cmt__City__c = :cidade ';
        }

        if (string.isNotBlank(uf)){
            strQuery += ' AND vlocity_cmt__State__c = :uf ';
            strQuery1 += ' AND vlocity_cmt__State__c = :uf ';
            strQuery2 += ' AND vlocity_cmt__State__c = :uf ';
        }

        List<vlocity_cmt__Premises__c> lstPremisses = database.query(strQuery);
         System.debug('get by addres size: ' + lstPremisses.size());
        List<vlocity_cmt__Premises__c> lstPremisses1 = database.query(strQuery1);
         System.debug('get by addres size: ' + lstPremisses1.size());
        List<vlocity_cmt__Premises__c> lstPremisses2 = database.query(strQuery2);
         System.debug('get by addres size: ' + lstPremisses2.size());
         
         if (lstPremisses.size() != 0){
         return premissesToAcc (lstPremisses);
         } else if (lstPremisses1.size() != 0){
         return premissesToAcc (lstPremisses1);
         } else {
         return premissesToAcc (lstPremisses2); 
         }
    }
    
    @AuraEnabled
    public static List<searchAccount> getContract(String numeroContrato, String codOperadora) {
        Set<Id> setAccId = new Set<Id> ();
        String bu = 'Claro';
        
        if(string.isNotEmpty(codOperadora)) {
            bu = 'Net';
        }
        
        List<Account> lstContract = [SELECT ParentId From Account where ContractReferenceNumber__c=:numeroContrato
                                     AND CityCode__c =:codOperadora
                                     AND businessUnit__c=:bu
                                     AND RecordTypeId =: recTypeBillingAccount];
        
        for(Account acc :lstContract){
            setAccId.add(acc.ParentId);
        }
        
        return getAccount(setAccId);
    }
    
    @AuraEnabled
    public static List<searchAccount> getContractNBONBA(String numeroContrato, String codOperadora) {
        Set<Id> setAccId = new Set<Id>();
        List<Contract> lstCon = new List<Contract>();
        List<Account> lstAccFinal = new List<Account>();
        
        if(codOperadora !=null) {
            lstCon = [SELECT 
                      Id, 
                      BusinessUnit__c,
                      AccountId,
                      ContractNumber__c,
                      
                      vlocity_cmt__ContractReferenceNumber__c,
                      CityCode__c
                      FROM Contract 
                      WHERE vlocity_cmt__ContractReferenceNumber__c =: numeroContrato
                      AND CityCode__c =: codOperadora
                      AND BusinessUnit__c =: 'NET'];
        } else {
            lstCon = [SELECT 
                      Id, 
                      AccountId,
                      BusinessUnit__c,
                      ContractNumber__c,
                      vlocity_cmt__ContractReferenceNumber__c,
                      CityCode__c
                      FROM Contract 
                      WHERE vlocity_cmt__ContractReferenceNumber__c =: numeroContrato
                      AND BusinessUnit__c =: 'CLARO'];
        }
        
        for(Contract con : lstCon){
            setAccId.add(con.AccountId);
        }
        
        List<Account> lstAccInfos = [SELECT 
                                     ID,
                                     Site,
                                     Name,
                                     ContractNumber__c,
                                     DocumentType__c,
                                     DocumentNumber__c,
                                     vlocity_cmt__Status__c,
                                     vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                     vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                     vlocity_cmt__PremisesId__r.Number__c,
                                     vlocity_cmt__PremisesId__r.Complement__c,
                                     vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                     vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                                     FormattedDocument__c FROM Account
                                     WHERE Id in: setAccId
                                     AND (RecordTypeId =: recTypeBusinessAccount OR RecordTypeId =: recTypeConsumerAccount)];
        
        for(Contract con : lstCon) {
            for(Account acc : lstAccInfos) {
                if(con.AccountId == acc.Id){
                    acc.ContractReferenceNumber__c = con.ContractNumber__c;
                    lstAccFinal.add(acc);
                }
            }
        }
        
        return formatToSearchObject(lstAccFinal);
    }
    
    @AuraEnabled
    public static Id getContractId(String contractNumber) {
        return [SELECT Id FROM Contract WHERE ContractNumber__c =: contractNumber LIMIT 1].Id;
    }
    
    @AuraEnabled
    public static List<searchAccount> getAccountName(String nome)
    {
        Set<Id> setAccId = new Set<Id>();

        nome = '%' + nome + '%';
        system.debug('nome: ' + nome);          
        
        List<Account> lstContract = [SELECT Id FROM Account WHERE Name LIKE :nome];
        
        for(Account acc :lstContract){
            setAccId.add(acc.Id);
        }
        
        return getAccount(setAccId);
        
    }
    
    public static List<searchAccount> getAccount(Set<Id> setAccIds) {
        
        List<Account> lstAccount = [SELECT ID,
                                    Site,
                                    Name,
                                    ContractReferenceNumber__c,
                                    DocumentType__c,
                                    vlocity_cmt__Status__c,
                                    DocumentNumber__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                    vlocity_cmt__PremisesId__r.Number__c,
                                    vlocity_cmt__PremisesId__r.Complement__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                    vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                                    FormattedDocument__c 
                                    FROM Account
                                    WHERE (RecordTypeId =: recTypeConsumerAccount OR RecordTypeId =: recTypeBusinessAccount)
                                    AND Id IN: setAccIds];
        
        return formatToSearchObject (lstAccount);
        
    }
    
    public static List<searchAccount> formatToSearchObject (List<Account> lstAcc){
        List<searchAccount> lstFinal = new List <SearchAccount>();
        
        for(Account acc : lstAcc) {
            SearchAccount objSearch = new SearchAccount();
            objSearch.Id = acc.Id;
            objSearch.City = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c;
            objSearch.Complement = acc.vlocity_cmt__PremisesId__r.Complement__c;
            objSearch.UnformattedComplement = (acc.vlocity_cmt__PremisesId__r.Complement__c <> null) ? acc.vlocity_cmt__PremisesId__r.Complement__c : 'A';
            objSearch.DocumentNumber = acc.DocumentNumber__c;
            objSearch.DocumentType = acc.DocumentType__c;
            objSearch.name = acc.Name;
            objSearch.numberAddress = acc.vlocity_cmt__PremisesId__r.Number__c;
            objSearch.PostalCode = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c;
            objSearch.State = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c;
            objSearch.StreetAddress = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c;
            objSearch.isExpandable = false;
            objSearch.FormattedDocument = acc.FormattedDocument__c;
            objSearch.Site = acc.Site;
            objSearch.contractNumber = acc.ContractReferenceNumber__c;
            objSearch.Status = acc.vlocity_cmt__Status__c;

            try{
                if(String.isBlank(acc.vlocity_cmt__PremisesId__r.Number__c))
                    objSearch.FormattedNumberAddress = 0;
                else
                    objSearch.FormattedNumberAddress = Integer.valueOf(acc.vlocity_cmt__PremisesId__r.Number__c);
            }     
            catch(Exception ex){
                objSearch.FormattedNumberAddress = 0;
                system.debug(ex.getMessage());
            }
            lstFinal.add(objSearch);
        }
        
        return lstFinal;
        
    }
    
    @AuraEnabled
    public static List<searchAccount> getMSISDN(String msdn) {
        String linha = msdn.replace('(','').replace(')','').replace(' ','').replace('-','');
        system.debug('getMSISDN >> ' + linha);            
        List<searchAccount> lstAcc = new List<searchAccount> ();
        Set<Id> setAccId = new Set<Id> ();
        
        List<Asset> lstAst = [Select accountId from Asset where msisdn__c =: linha LIMIT 1];
        
        if(lstAst.size() != 0){
            system.debug(lstAst[0].accountId);
            setAccId.add(lstAst[0].accountId);
            lstAcc = getAccount(setAccId);
        }
        
        return lstAcc;
    }
    
    
    @AuraEnabled
    public static boolean getPermissionCom()
    {
        // return FeatureManagement.checkPermission('Comercial_Users');
        Boolean comercial = FeatureManagement.checkPermission('Comercial_Users');
        Boolean cross = FeatureManagement.checkPermission('CRM_Cross');
        boolean permission = comercial || cross == true ? true : false;
        return permission;
    }
    
    @AuraEnabled
    public static CEC_City_CarrierCode__mdt getCityByCarrierCode(String carrierCode) {
        system.debug('carrierCode: ' + carrierCode);
        CEC_City_CarrierCode__mdt cityCarrier = [SELECT Id, MasterLabel, Estado__c FROM CEC_City_CarrierCode__mdt 
                                                 WHERE CodigoOperadora__c =: carrierCode LIMIT 1];
        return cityCarrier;
    }
    
    @AuraEnabled
    public static CEC_City_CarrierCode__mdt getCityByName(String name) {
        system.debug('name: ' + name);
        //string cityName = '%' + name + '%';
        CEC_City_CarrierCode__mdt cityCarrier = [SELECT Id, CodigoOperadora__c, MasterLabel, Estado__c FROM CEC_City_CarrierCode__mdt 
                                                 WHERE MasterLabel = :name LIMIT 1];
        return cityCarrier;
    }
    
    @AuraEnabled
    public static CEC_OmniScript__mdt getParametersByOmniscriptName(String omniscriptName)
    {
        CEC_OmniScript__mdt mc = null;
        
        try
        {
            mc = [SELECT
                  MasterLabel,
                  strOmniScriptType__c,
                  strOmniScriptSubType__c,
                  strOmniScriptLang__c FROM CEC_OmniScript__mdt WHERE MasterLabel =: omniscriptName
                 ];
        }
        catch (Exception e)
        {
            system.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        return mc;
    }
    
    @AuraEnabled
    public static List<Contract> getContractList(String accountId){
        List<Contract> lstContract = [Select Id,
                                      ContractNumber__c
                                      From Contract 
                                      where AccountId =:accountId];
        return lstContract;
    }
    
    //------ Classe de Busca de Contas ---------//
    
    public class searchAccount {
        @AuraEnabled public String Id;
        @AuraEnabled public String name;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public String FormattedDocument;
        @AuraEnabled public String DocumentNumber;
        @AuraEnabled public String PostalCode;
        @AuraEnabled public String StreetAddress;
        @AuraEnabled public Integer FormattedNumberAddress;
        @AuraEnabled public String numberAddress;
        @AuraEnabled public String UnformattedComplement;
        @AuraEnabled public String Complement;
        @AuraEnabled public String City;
        @AuraEnabled public String State;
        @AuraEnabled public Boolean isExpandable;
        @AuraEnabled public String Site;
        @AuraEnabled public String Status;
        @AuraEnabled public String contractNumber;        
    }
}