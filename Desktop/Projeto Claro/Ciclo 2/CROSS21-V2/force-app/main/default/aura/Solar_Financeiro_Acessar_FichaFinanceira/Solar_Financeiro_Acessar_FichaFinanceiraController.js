/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 04-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-02-2021   Diego Almeida   BUG 113351 -BUG PROD RELEASE - Acesso a ficha financeiro sem caso
**/
({
    init: function(component, event, helper) {
        console.log('Solar_Financeiro_Acessar_FichaFinanceira', 'INIT');

        var myPageRef = component.get("v.pageReference");
        var encodedAttributes = myPageRef.state.c__encodedattributes;
        var componentName = myPageRef.state.c__lwc;

        component.set("v.encodedbaseAttributes", encodedAttributes);
        component.set("v.componentName", componentName);

        console.log('Solar_Financeiro_Acessar_FichaFinanceira > v.encodedbaseAttributes', component.get("v.encodedbaseAttributes"));
        console.log('Solar_Financeiro_Acessar_FichaFinanceira > v.componentName', component.get("v.componentName"));


    }
})