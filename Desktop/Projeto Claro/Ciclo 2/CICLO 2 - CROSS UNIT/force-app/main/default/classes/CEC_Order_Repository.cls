/**
* Created by 93668256 on 18/11/2019.
*/

public class CEC_Order_Repository extends CEC_Generic_Repository {

    public Order getOrderById(String id) {
        try {
            String sql = 'select Id, OwnerId,BillingPostalCode, UF__c, BillingNeighborhood__c, BillingComplement__c, BillingNumber__c,BillingStatus__c,vlocity_cmt__BillingName__c,' +
                    ' BillingStreet, CodigoOperadora__c, BillingState, BillingCity, Forma_de_Pagamento__c, NumeroConta__c,BillingId__c,ContractId,' +
                    ' Agencia__c, Banco__c, vlocity_cmt__ExpirationDate__C, vlocity_cmt__DueDate__C, TipoFatura__c, OrderNumber,BillingDescription__c,NumProtocolo__c,' +
                    '( select id, DDD__c, Fidelidade__c, vlocity_cmt__SerialNumber__c, NumeroProvisorio__c, Portabilidade__c, CodigoBonus__c,' +
                	' CodigoPromocao__c, vlocity_cmt__LineNumber__c, Product2.vlocity_cmt__subType__c, Product2.Name,' +
                    ' Product2.id, Product2.vlocity_cmt__Type__c, DescricaoMulta__c, Meses_de_Fidelidade__c, Operator__c, vlocity_cmt__RecurringCharge__c from OrderItems ORDER BY Product2.vlocity_cmt__Type__c ASC), Account.id, Account.DocumentNumber__c, Account.RG__c, ' +
                    ' Account.RGEmitter__c, Account.SalaryRange__c, Account.Occupation__c, Account.Email__c, Account.Phone, Account.ReceiveSMS__c,' +
                    ' Account.MaritalStatus__c, Account.Name, Account.BirthDate__c, Unidade__c,TotalAmount, Account.MothersName__c, Account.Gender__c,' +
                    ' Description, Owner.id from Order where id=' + concatString(id);
			System.debug(sql);
            Order order = Database.query(sql);
            return order;
        } catch (Exception e) {
            return null;
        }
    }

    public List<OrderItem> getOrderItemById(String id) {
        try {
            String sql = createSelectAllGeneric(new OrderItem());
            sql += ' where OrderId= '+ concatString(id);
            List<OrderItem> item = Database.query(sql);
            return item;
        } catch (Exception e) {
            return null;
        }
    }

    public Product2 getProductById(String id) {
        try {
            String sql = createSelectAllGeneric(new Product2());
            sql += ' where id= '+concatString(id);
            Product2 product2s = Database.query(sql);
            return product2s;
        } catch (Exception e) {
            return null;
        }
    }

    public Map<Id, List<vlocity_cmt__DecompositionRelationship__c>> getDecompositionRelationshipByLitsProduct2(List<OrderItem> orderItens, Boolean portability, Boolean fidelity) {
        try {
            List<Id> ids = new List<Id>();
            set<String> setBonusPromotion = new set<String>();
            Map<Id, List<vlocity_cmt__DecompositionRelationship__c>> mapDecompositionOffer = new Map<Id, List<vlocity_cmt__DecompositionRelationship__c>>();

            for (OrderItem o : orderItens){
                if(o.Product2.vlocity_cmt__Type__c == 'Plano' || o.Product2.vlocity_cmt__Type__c == 'Dependente'){
                    ids.add(o.Product2.Id);
                }
                if(o.CodigoBonus__c != null){
                    setBonusPromotion.add(o.CodigoBonus__c);
                }
                if(o.CodigoPromocao__c != null){
                    setBonusPromotion.add(o.CodigoPromocao__c);
                }
            }

            List<vlocity_cmt__DecompositionRelationship__c> lstDecomposition = [
                    SELECT Fidelity__c, Legacy_Offer__c,Legacy_Offer__r.Billing_Offer_Code__c,
                            Legacy_Offer__r.Billing_Offer_Name__c, Legacy_Offer__r.Billing_System__c, CreatedDate , Legacy_Offer__r.InActive_As_Of__c,
                            Legacy_Offer__r.Description__c,
                            Multi__c, Portability__c, Type__c, CodigoBonus__c, CodigoPromocao__c, vlocity_cmt__SourceProductId__c, Id, Name
                    FROM
                            vlocity_cmt__DecompositionRelationship__c
                    where vlocity_cmt__SourceProductId__c = :ids OR CodigoBonus__c =:setBonusPromotion OR CodigoPromocao__c =:setBonusPromotion ORDER BY Multi__c NULLS FIRST
            ];
            System.debug('QUERY ids>>'+ids);
            System.debug('Query Cod Bonus>>'+setBonusPromotion);
            System.debug('Query Ordem Itens>>'+ orderItens.size());
            System.debug('Query Ordem Itens>>'+ JSON.serializePretty(orderItens));
            for (OrderItem o : orderItens)
            {
                List<vlocity_cmt__DecompositionRelationship__c> lstDecompositionOffer = new List<vlocity_cmt__DecompositionRelationship__c>();
                for(vlocity_cmt__DecompositionRelationship__c  dr : lstDecomposition)
                {
                    if(o.Product2Id == dr.vlocity_cmt__SourceProductId__c)
                    {
                        if(validateFidelityDecomposition(o,dr)){
                            //if(dr.Fidelity__c != null && !o.Fidelidade__c) break;
                            if('sim'.equalsIgnoreCase(dr.Multi__c)) break;
                            
                            if(dr.vlocity_cmt__SourceProductId__c == o.Product2Id){
                                if(dr.Type__c != 'Promoção'){
                                    dr.Type__c = 'OPCIONAL';
                                }
                                lstDecompositionOffer.add(dr);
                            }
                            else if(dr.CodigoBonus__c != null && dr.CodigoBonus__c == o.CodigoBonus__c){
                                if(dr.Type__c != 'Promoção'){
                                    dr.Type__c = 'OPCIONAL';
                                }
                                lstDecompositionOffer.add(dr);
                            }
                            else if(dr.CodigoPromocao__c != null && dr.CodigoPromocao__c == o.CodigoPromocao__c){
                                if(dr.Type__c != 'Promoção'){
                                    dr.Type__c = 'OPCIONAL';
                                }
                                lstDecompositionOffer.add(dr);
                            }
                        }
                    }
                }
                mapDecompositionOffer.put(o.id, lstDecompositionOffer);
            }
            system.debug('mapDecompositionOfferDEBUG: '+json.serializePretty(mapDecompositionOffer));
            return mapDecompositionOffer;

        } catch (Exception e) {
            return null;
        }
    }


    private Boolean validateFidelityDecomposition(OrderItem ordItem, vlocity_cmt__DecompositionRelationship__c decomposition){
        if(decomposition.Fidelity__c != null && !ordItem.Fidelidade__c) return false;
        return true;
    }
}