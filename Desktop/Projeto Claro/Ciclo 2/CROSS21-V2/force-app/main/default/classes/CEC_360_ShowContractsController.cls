/*
* Autor: [Letícia Freitas] + Squad V360 - Deloitte
* Data: [28/05/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 06/01/2019  
* Autor: Squad Visão 360 [Cintia Sousa]
* Alterações: Refact do Componente para carregar as listas e sublistas no init, ao invés de chamar o callback a cada click
* ---------------------------------------------------------------
*/
public class CEC_360_ShowContractsController 
{       
    @AuraEnabled 
    public static List<TreeProducts> getAssets(string id, string recordType)
    {
        Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        List<TreeProducts> lstProducts = new List<TreeProducts>();
        Set<String> setSpot = new Set<String>();
        Set<String> setAccountId = new Set<String>();
        
        List<Asset> lstAsset = [SELECT Id, 
                                 Name, 
                                 Status,
                                 Msisdn__c,
                                 AccountId,
                                 SpotId__c,
                                 BusinessUnit__c
                                 FROM Asset WHERE (Status = 'Ativo' Or Status ='Pendente' Or Status = 'Suspenso')
                                 And (SpotType__c = 'Principal' OR SpotType__c = 'Adicional')
                                 AND vlocity_cmt__BillingAccountId__c =: id
                                 AND RecordTypeId =: recordTypeAsset];
        
        for(Asset asset : lstAsset){
            setAccountId.add(asset.AccountId);
            setSpot.add(asset.SpotId__c);
        }    
                
        Map<String, Map<String, List<Asset>>> mapSubAssetsRes = getSubAssetsRes(setAccountId, setSpot);
        
        for (Asset varAsset: lstAsset)
        {
            TreeProducts objNode = formatWrapper(varAsset);          
            if(mapSubAssetsRes.containsKey(varAsset.AccountId) && 
               mapSubAssetsRes.get(varAsset.AccountId).containsKey(varAsset.SpotId__c))
            {
                objNode.hasRecords = true;
                objNode.subTreeProduct = new List<SubTreeProduct>();
                objNode.subTreeProduct.addAll(formatSubWrapper(mapSubAssetsRes.get(varAsset.AccountId).get(varAsset.SpotId__c)));  
            }
            lstProducts.add(objNode);
        }       
        
        return lstProducts;
    }
    
    @AuraEnabled 
    public static List<TreeProducts> getAssetsMov(string id)
    {
        List<TreeProducts> lstProducts = new List<TreeProducts>();
        Set<String> setMSISDNId = new Set<String>();
                
        List<Asset> lstAsset = [SELECT Id, 
                                Name,
                                Status,
                                Msisdn__c,
                                AccountId,
                                SpotId__c,
                                businessUnit__c
                                FROM Asset WHERE Status = 'Ativo' 
                                AND businessUnit__c != 'NET'
                                AND SpotType__c = 'PLANO_PRECO'
                                AND vlocity_cmt__BillingAccountId__c =: id];
        
        for(Asset asset : lstAsset){
            setMSISDNId.add(asset.Msisdn__c);
        }   
        
        Map<String, List<Asset>> mapSubAssetsMov = getSubAssetsMov(setMSISDNId);
        
        for (Asset varAsset: lstAsset)
        {
            TreeProducts objNode = formatWrapper(varAsset);                        
            if(mapSubAssetsMov.containsKey(varAsset.Msisdn__c))
            {
                objNode.hasRecords = true;
                objNode.subTreeProduct = new List<SubTreeProduct>();
                objNode.subTreeProduct.addAll(formatSubWrapper(mapSubAssetsMov.get(varAsset.Msisdn__c)));  
            }
            lstProducts.add(objNode);
        }
        
        return lstProducts;
    }
    
    
    public static Map<String, Map<String, List<Asset>>> getSubAssetsRes(Set<String> setAccountId, Set<String> setSpotId)
    {
        Map<String, Map<String, List<Asset>>> mapSubAssetsRes = new  Map<String, Map<String, List<Asset>>>();
        
        List<Asset> lstAsset = [SELECT ID,
                                Name, 
                                Status, 
                                Msisdn__c,
                                AccountId,
                                SpotId__c
                                FROM asset WHERE AccountId IN: setAccountId
                                AND SpotId__c IN: setSpotId
                                AND SpotType__c != 'ADICIONAL' 
                                AND SpotType__c != 'PRINCIPAL'
                                AND Status != 'Cancelado'];
        
        for(Asset asset : lstAsset)
        {
            if(!mapSubAssetsRes.containsKey(asset.AccountId))
                mapSubAssetsRes.put(asset.AccountId, new Map<String, List<Asset>>());
            
            if(!mapSubAssetsRes.get(asset.AccountId).containsKey(asset.SpotId__c)){
                mapSubAssetsRes.get(asset.AccountId).put(asset.SpotId__c, new List<Asset> { asset });
            }
            else
                mapSubAssetsRes.get(asset.AccountId).get(asset.SpotId__c).add(asset);
        }
        
        return mapSubAssetsRes;
    }
    
    public static Map<String, List<Asset>> getSubAssetsMov(Set<String> setMSISDNId)
    {
        Map<String, List<Asset>> mapSubAssetsMov = new  Map<String, List<Asset>>();
        
        List<Asset> lstAsset = [SELECT Id,
                                 Name, 
                                 Status,
                                 Msisdn__c
                                 FROM Asset
                                 WHERE Msisdn__c IN: setMSISDNId
                                 AND (ServiceType__c  LIKE 'Assinante')
                                 AND (NOT SpotType__c LIKE 'Plano Pre')
                                 AND (NOT SpotType__c LIKE 'PLANO_PRECO')
                                ];      
                                
        for(Asset asset : lstAsset)
        {
            if(!mapSubAssetsMov.containsKey(asset.Msisdn__c))
                mapSubAssetsMov.put(asset.Msisdn__c, new List<Asset> { asset });
            else
                mapSubAssetsMov.get(asset.Msisdn__c).add(asset);
        }
        
        return mapSubAssetsMov;
    }
    
    
    @AuraEnabled 
    public static TreeProducts formatWrapper(Asset varAsset)
    {
        TreeProducts objNode = new TreeProducts();
        
        objNode.id = varAsset.id;
        objNode.accountId = varAsset.AccountId;
        objNode.bu = varAsset.BusinessUnit__c;
        objNode.name = varAsset.Name; 
        objNode.status = varAsset.Status;
        objNode.msisdn = varAsset.Msisdn__c;
        objNode.spotid = varAsset.SpotId__c;
        objNode.isExpandable = false;           
        objNode.hasRecords = false;
        
        return objNode;
    }

    @AuraEnabled 
    public static List<SubTreeProduct> formatSubWrapper(List<Asset> lstAsset){
        
        List<SubTreeProduct> lstTree = new List<SubTreeProduct>();
        for (Asset ast: lstAsset){
            SubTreeProduct objNode = new SubTreeProduct();
            objNode.id = ast.id;
            objNode.name = ast.Name; 
            objNode.status = ast.status;
            objNode.msisdn = ast.msisdn__c;
            lstTree.add(objNode);
        }
        
        return lstTree;
    }
    
    public class TreeProducts {
        @AuraEnabled public String Id;
        @AuraEnabled public String accountId;
        @AuraEnabled public String name;
        @AuraEnabled public String msisdn;
        @AuraEnabled public String spotid;
        @AuraEnabled public String status;
        @AuraEnabled public String bu;
        @AuraEnabled public String contractNumber;        
        @AuraEnabled public Boolean isExpandable;
        @AuraEnabled public Boolean hasRecords;
        
        @AuraEnabled public List<SubTreeProduct> subTreeProduct;
    }
    
    public class SubTreeProduct{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String msisdn;
        @AuraEnabled public String preco;	
        @AuraEnabled public String status;
    }
}