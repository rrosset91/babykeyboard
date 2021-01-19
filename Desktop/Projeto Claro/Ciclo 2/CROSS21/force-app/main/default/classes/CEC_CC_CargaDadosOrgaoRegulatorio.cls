/*
* Autor: Squad Canais Criticos
* Data: 18/09/2020
* Description: Realiza a carga do objeto CustomerBureau__c
* ---------------------------------------------------------------
*/
public without sharing class CEC_CC_CargaDadosOrgaoRegulatorio {
    @TestVisible
    private static String staticResourceName = 'cargaDadosOrgaoRegulatorio';

    private static String nomeSemUnidadePrincipal = 'SEM UNIDADE PRINCIPAL';

    private static String nomeSemSubUnidade = 'SEM SUB UNIDADE';

    private static String trimValue(String value) {
        if(value != null) {
            value = value.trim();
        }
        return value;
    }

    private static StaticResource getResource(){        
        // nome do recurso estático onde contém a tabela csv com valores.
        return [SELECT ID, body FROM StaticResource WHERE Name =: staticResourceName LIMIT 1];
    }

    private static String formatBureauName(String nome, Boolean concatEndereco) {

        if(concatEndereco) {

            if(nome.indexOf(' -> ') > -1) {

                nome = nome.split(' -> ')[0];
    
            }
    
            return trimValue(nome.toUpperCase());    

        } else {

            return trimValue(nome.toUpperCase());

        }
    }

    /**
     * Obtem o nome unico da unidade
     */
    private static String getBureauUniqueName(String[] valoresLinha, Boolean concatEndereco) {

        String nome = null;

        if(concatEndereco) {

            nome  = valoresLinha[0].toUpperCase() + 
            ' -> ' +
            (String.isNotBlank(valoresLinha[9]) ? (valoresLinha[9] + ', ') : '') + 
            valoresLinha[10] + ', ' + valoresLinha[11] +
            (String.isBlank(valoresLinha[9]) && String.isNotBlank(valoresLinha[12]) ? (', ' + valoresLinha[12]) : '');

           

        } else {
            
            nome = valoresLinha[0].toUpperCase();

        }

        nome = trimValue(nome);

        if(nome.length() > 80) {

            nome = nome.substring (0,78) + '..';

        }

        return nome;   
    }

    /**
     * Monta uma chave unica para o nome do endereco
     */
    private static String getAddressUniqueName (String[] valoresLinha) {
        /*
        String  nome =  valoresLinha[7] + ' ' +
                        valoresLinha[8] + 
                        (String.isNotBlank(valoresLinha[12]) ? ' - ' + valoresLinha[12] : '') +                         
                        (String.isNotBlank(valoresLinha[9]) ? ', ' + valoresLinha[9] : '') +                         
                        (String.isNotBlank(valoresLinha[10]) ? ', ' + valoresLinha[10] : '') +                         
                        (String.isNotBlank(valoresLinha[6]) ? ', ' + valoresLinha[6] : '');

        */                

        String nome = valoresLinha[7] + ' ' + valoresLinha[8];

        if(String.isNotBlank(valoresLinha[12])) {
            if(String.isNotBlank(trimValue(nome))) {
                nome = nome + ' - ';                
            }
            nome = nome + valoresLinha[12];
        }

        if(String.isNotBlank(valoresLinha[9])) {
            if(String.isNotBlank(trimValue(nome))) {
                nome = nome + ', ';                
            }
            nome = nome + valoresLinha[9];
        }

        if(String.isNotBlank(valoresLinha[10])) {
            if(String.isNotBlank(trimValue(nome))) {
                nome = nome + ', ';                
            }
            nome = nome + valoresLinha[10];
        }    
        
        if(String.isNotBlank(valoresLinha[6])) {
            if(String.isNotBlank(trimValue(nome))) {
                nome = nome + ', ';                
            }
            nome = nome + valoresLinha[6];
        }

        nome = trimValue(nome);

        if(nome.length() > 80) {
            nome = nome.substring (0,78) + '..';
        }
        return nome;
    }

    /**
     * Inicia a carga
     */
    public static void run() { 
        run(true);
    }

    /**
     * Inicia a carga
     */
    public static void run(Boolean concatEndereco) { 
        StaticResource sr = getResource(); //busca o CSV do recurso estático
        if(sr != null && sr.Body != null) {
            String csv = sr.Body.toString();
            run(csv,concatEndereco);
        }
    }    

    private static void logResult(List<Database.SaveResult> results) {
        if(results != null && results.size() > 0) {
            for(Database.SaveResult result : results) {
                for(Database.Error erro : result.getErrors()) {
                    System.debug(erro.getMessage());
                    System.debug(erro.getFields());
                }    
            }
        }
    }

    /**
     * Inicia a carga
     */
    @TestVisible
    private static void run(String csv, Boolean concatEndereco) { 

        //Remove os registros atuais
        List<CustomerBureau__c> orgaosDelete = [Select id, address__c from CustomerBureau__c];
        Set<Id> codigosEnderecos = new Set<Id>();
        for(CustomerBureau__c orgao : orgaosDelete) {
            if(orgao.address__c != null) {
                codigosEnderecos.add(orgao.address__c);
            }    
        }
        List<vlocity_cmt__Premises__c> enderecosDelete = [Select id from vlocity_cmt__Premises__c where id in :codigosEnderecos];
        delete enderecosDelete;
        delete orgaosDelete;


        // verifica se o resultado é nulo
        if(String.isNotBlank(csv)) { 

            System.debug('Iniciando carga');

            List<vlocity_cmt__Premises__c> enderecos = new List<vlocity_cmt__Premises__c>();
            List<CustomerBureau__c> cbusParaUpdate = new List<CustomerBureau__c>();
            List<CustomerBureau__c> cbus = new List<CustomerBureau__c>();
    
            Map<String, vlocity_cmt__Premises__c> searchEndereco = new Map<String, vlocity_cmt__Premises__c>();
            Map<String, CustomerBureau__c> cbuInseridas = new Map<String, CustomerBureau__c>();
            Map<String, string> idsCBU = new Map<String, string>();
            Map<String, string> searchParaOrgPrinc = new Map<String, string>();

            // System.debug('RESULT >>' + csv);

            String [] csvRow = csv.split('\n');

            // System.debug('csvRow tem >>' + csvRow.size());
            
            for (integer i = 1 ; i < csvRow.size(); i++)  {

                String [] valoresLinha =csvRow[i].split(';'); //quebro os valores da linha e deixo em um array;
                vlocity_cmt__Premises__c ender = new  vlocity_cmt__Premises__c ();
                ender.vlocity_cmt__PostalCode__c = trimValue(valoresLinha[6]);
                ender.vlocity_cmt__StreetAddress__c = trimValue(valoresLinha[7]);
                ender.Number__c = trimValue(valoresLinha[8]);
                ender.Neighborhood__c = trimValue(valoresLinha[9]);
                ender.vlocity_cmt__City__c = trimValue(valoresLinha[10]);
                ender.vlocity_cmt__State__c = trimValue(valoresLinha[11]);
                ender.Complement__c = trimValue(valoresLinha[12]);
                ender.Name = trimValue(getAddressUniqueName(valoresLinha));
                ender.vlocity_cmt__Country__c = 'BRASIL';

                enderecos.add(ender);
            }

            List<Database.SaveResult> resultEnderecos = Database.insert(enderecos,true);
            logResult(resultEnderecos);
            System.debug('Enderecos inseridos');

            //for para preencher um map de pesquisa, com o nome (Chave) e o objeto com o id preenchido (valor)
            for(vlocity_cmt__Premises__c ender : enderecos){
                searchEndereco.put( ender.Name , ender );
            }

            for(integer i=1; i < csvRow.size(); i++){ // quantidade de linhas pertinentes ao objeto a ser inserido

                String [] valoresLinha = csvRow[i].split(';'); //quebro os valores da linha e deixo em um array;

                CustomerBureau__c cb = new CustomerBureau__c();

                    //System.debug(csvRow[i]);

                    cb.Name = trimValue(getBureauUniqueName(valoresLinha,concatEndereco));
                    cb.MainFeedback__c = trimValue(valoresLinha[1]);
                    cb.Phones__c = trimValue(valoresLinha[2]);
                    cb.Site__c = trimValue(valoresLinha[3]);
                    cb.Emails__c = trimValue(valoresLinha[4]);
                    cb.Type__c = trimValue(valoresLinha[13]);

                    //busca no array o objeto
                    String keyAddress = trimValue(getAddressUniqueName(valoresLinha));
                    vlocity_cmt__Premises__c address =  searchEndereco.get(keyAddress); 

                    if(address != null){ // se o objeto não for nulo, insere o id do address
                        cb.address__c = address.Id;
                    }

                    cbus.add(cb);
                    cbuInseridas.put(cb.Name, cb);
                    if(String.isNotBlank(valoresLinha[5])){
                        searchParaOrgPrinc.put(formatBureauName(cb.Name,concatEndereco), trimValue(valoresLinha[5]));
                    }
                    
            }

            //insere os nomes dos órgãos.
            List<Database.SaveResult> resultBureaul = Database.insert(cbus,true);
            logResult(resultBureaul);
            System.debug('Orgaos inseridos');

            // for para preencher um map onde pesquise o nome da CBU e receba o id dela.
            for(CustomerBureau__c cbu : cbus){
                idsCBU.put(formatBureauName(cbu.Name,concatEndereco), cbu.Id);
            }

            List<CustomerBureau__c> listSemSubUnidadaes = new List<CustomerBureau__c>(); 

            // for para descobrir qual é o nome do orgão principal e preencher depois de todos os nomes dos orgãos serem inseridos.
            for(CustomerBureau__c cbu : cbus){
                String nomeOrgaoPrincipal = searchParaOrgPrinc.get(formatBureauName(cbu.Name,concatEndereco));
                if(String.isNotBlank(nomeOrgaoPrincipal)){
                    cbu.MainBureau__c = idsCBU.get(nomeOrgaoPrincipal);
                    cbusParaUpdate.add(cbu);
                } else {
                    //Aqui é um orgao principal, logo, precisa adicionar um sem sub unidade para ele
                    listSemSubUnidadaes.add(new CustomerBureau__c(Name = nomeSemSubUnidade, MainBureau__c = cbu.id));
                }
            }

            //TODO - por enquanto nao faz esse insert. Deixa a logica ainda ai em cima
            /*
            if(listSemSubUnidadaes.size() > 0) {
                insert listSemSubUnidadaes;
            }
            */

            //Atualiza os que tem orgão principal
            List<Database.SaveResult> resultBureaulUpdate = Database.update(cbusParaUpdate,true);
            logResult(resultBureaulUpdate);
            System.debug('Orgaos atualizados');

            //Por fim insere o sem unidade principal e o sem sub unidade
            //TODO - por enquanto nao faz esse insert
            /*
            CustomerBureau__c semUnidadePrincipal = new CustomerBureau__c(Name = nomeSemUnidadePrincipal);
            CustomerBureau__c semSubUnidade = new CustomerBureau__c(Name = nomeSemSubUnidade);
            insert semUnidadePrincipal;
            semSubUnidade.MainBureau__c = semUnidadePrincipal.id;
            insert semSubUnidade;
            */

            //Insere um sem unidade principal porque o campo está como obrigatorio no layout. A sub unidade esta como opcional
            CustomerBureau__c semUnidadePrincipal = new CustomerBureau__c(Name = nomeSemUnidadePrincipal);
            insert semUnidadePrincipal;

            System.debug('Carga finalizada');
        }
    }
}