/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
Classe de teste que cobre os códigos contidos na classe CEC_PME_TimeLine.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
@isTest
public with sharing class CEC_PME_TimeLineTest {
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
        Método de setup para criar os cenários a serem testados.
*/  


    @testSetup static void setup() {
        Account acc = new Account();
            acc.name = 'Name acc';
            
            insert acc;
            
            Product2 prd = new Product2();
            prd.name = 'PME_Linha_Claro Total_Compartilhado';
            prd.ProductCode = 'PME_Plano_Claro_Total_Compartilhado';
            prd.isActive = true;
            
            insert prd;
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id = prd.id;
            pbe.UnitPrice = 1.00;
            pbe.UseStandardPrice = false;
            pbe.isActive = true;
            
            insert pbe;
            
            Order ord = new Order();
            ord.Pricebook2Id= Test.getStandardPricebookId();
            ord.name = 'Name Order';
            ord.accountid = acc.id;
            ord.EffectiveDate = Date.today();
            ord.Status = 'Em andamento';
            insert ord;
            
            OrderItem ordI = new OrderItem();
            ordI.OrderId = ord.id;
            ordI.PricebookEntryId = pbe.id;
            ordI.DDD__c = '11';
            ordI.Regional__c = 'SP';
            //ordI.Franchise__c = 'Franchise';
            ordI.Quantity = 1;
            ordI.UnitPrice = 1.00;
            ordI.vlocity_cmt__EffectiveOneTimeTotal__c = 1.00;
            ordI.vlocity_cmt__EffectiveRecurringTotal__c = 1.00;
            ordI.vlocity_cmt__JSONAttribute__c = '{}';
            insert ordI;
            
            OrderTimeLineGroup__c lineGroup = new OrderTimeLineGroup__c();
            lineGroup.Name = 'Classe teste';
            lineGroup.NomeGrupo__c='Input';
            lineGroup.Status__c='Executando Input Automático';
            
            insert lineGroup;
            
            OrderTimeLineGroup__c lineGroup2 = new OrderTimeLineGroup__c();
            lineGroup2.Name = 'Classe teste 2';
            lineGroup2.NomeGrupo__c='Input';
            lineGroup2.Status__c='Executando Input Manual';
            
            insert lineGroup2;
        
            
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
        Testa o cenário cujo status seja Em andamento.
*/      
    @isTest static void test1() {
        Order ord = [SELECT Id,Status FROM Order];
        Test.startTest();
        List<CEC_PME_TimeLine.TimeLine> lstTl = CEC_PME_TimeLine.getTimeLine(ord.Id);
        Test.stopTest();
                
        for(CEC_PME_TimeLine.TimeLine tl : lstTl){
            if('slds-path__item slds-is-current'.equals(tl.option)){
                System.assertEquals(ord.Status, tl.DescricaoFase);
            }    
        }
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
        Testa o cenário cujo status seja Executando Input Automático.
*/    
    @isTest static void test2() {
        Order ord = [SELECT Id,Status FROM Order];
        ord.Status = 'Executando Input Automático';
        update ord;
        
        Test.startTest();
        List<CEC_PME_TimeLine.TimeLine> lstTl = CEC_PME_TimeLine.getTimeLine(ord.Id);
        Test.stopTest();
        
        for(CEC_PME_TimeLine.TimeLine tl : lstTl){
            if('slds-path__item slds-is-current'.equals(tl.option)){
                System.assertEquals(ord.Status, tl.DescricaoFase);
            }    
        }
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
        Testa o cenário cujo status seja Executando Input Manual.
*/        
    @isTest static void test3() {
        Order ord = [SELECT Id,Status FROM Order];
        ord.Status = 'Executando Input Manual';
        update ord;
        
        Test.startTest();
        List<CEC_PME_TimeLine.TimeLine> lstTl = CEC_PME_TimeLine.getTimeLine(ord.Id);
        Test.stopTest();
        
        for(CEC_PME_TimeLine.TimeLine tl : lstTl){
            if('slds-path__item slds-is-current'.equals(tl.option)){
                System.assertEquals(ord.Status, tl.DescricaoFase);
            }    
        }
        
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
        Testa o cenário cujo status seja Calculando Cashback.
*/    
    @isTest static void test4() {
        Order ord = [SELECT Id,Status FROM Order];
        ord.Status = 'Calculando Cashback';
        update ord;
        
        Test.startTest();
        List<CEC_PME_TimeLine.TimeLine> lstTl = CEC_PME_TimeLine.getTimeLine(ord.Id);
        Test.stopTest();
        
        for(CEC_PME_TimeLine.TimeLine tl : lstTl){
            if('slds-path__item slds-is-current'.equals(tl.option)){
                System.assertEquals(ord.Status, tl.DescricaoFase);
            }    
        }
    }
}