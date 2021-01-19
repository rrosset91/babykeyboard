({
    onfocus : function(component,event,helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
    },
    
    callSearch : function(component,event,helper) {
        var forclose = component.find("lookup-search");
        $A.util.addClass(forclose, 'slds-hide');
        $A.util.removeClass(forclose, 'slds-show');
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
    },
    
    onblur : function(component,event,helper) {       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) { 
        var field = component.get("v.field");

        if (field == "MasterLabel") {
            var getInputkeyWord = component.get("v.SearchKeyWord");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[àáâãäå]/g),"a");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ÀÁÂÃ]/g),"a");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/ç/g),"c");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/Ç/g),"c");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[èéêë]/g),"e");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ÈÉÊË]/g),"e");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ìíîï]/g),"i");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ÌÍÎÏ]/g),"i");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/ñ/g),"n");                
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/Ñ/g),"n");                
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[òóôõö]/g),"o");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ÒÓÔÕÖ]/g),"o");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ùúûü]/g),"u");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ÙÚÛÜ]/g),"u");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[ýÿ]/g),"y");
            getInputkeyWord = getInputkeyWord.replace(new RegExp(/[Ý]/g),"y");
            getInputkeyWord = getInputkeyWord.toUpperCase();
            component.set("v.getInputkeyWord", getInputkeyWord);
      
            console.log('getInputkeyWord: ' + getInputkeyWord);
        } 

        if (field == "CodigoOperadora__c") {
            var cod = component.get("v.SearchKeyWord");
            var rep = cod.replace(/[^0-9]/g,"");
            var getInputkeyWord = rep.substring(0, 3);
            component.set("v.getInputkeyWord", getInputkeyWord);
            component.set("v.SearchKeyWord", getInputkeyWord);
            console.log('getInputkeyWord: ' + getInputkeyWord);
            console.log('SearchKeyWord: ' + getInputkeyWord);
        }
        
      
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    clear :function(component,event,heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        var forclose = component.find("lookup-search");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
        
        var p = component.get("v.parent");
        p.callClear();
    },
    
    clearCalledOutside :function(component,event,heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        var forclose = component.find("lookup-search");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
  
    handleComponentEvent : function(component, event, helper) {	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var p = component.get("v.parent");
        p.callSearch();
        
        var forclose = component.find("lookup-search");
        $A.util.addClass(forclose, 'slds-hide');
        $A.util.removeClass(forclose, 'slds-show');
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
})