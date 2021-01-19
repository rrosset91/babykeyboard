({
    setCssPathItem : function(component, event, helper) {
        var item = component.get("v.pathItem");
        var cssClasses = 'slds-path__item';
        if(item != null) {
            if(item.isShowMedium) {
                cssClasses = cssClasses.concat(' slds-show_medium');
            }
            
            switch (item.type) {
                case 'current':
                    cssClasses = cssClasses.concat(' slds-is-active', ' slds-is-current');
                    break;
                case 'incomplete':
                    cssClasses = cssClasses.concat(' slds-is-incomplete');
                    break;
                case 'lost':
                    cssClasses = cssClasses.concat(' slds-is-lost');
                    break;
                case 'error':
                    cssClasses = cssClasses.concat(' slds-is-lost');
                    break;
                case 'complete':
                    cssClasses = cssClasses.concat(' slds-is-complete');
                    break;
                default:
                    cssClasses = cssClasses.concat(' slds-is-incomplete');
                    break;
            }
            
            component.set("v.pathItem.listCssClass", cssClasses);
        }
    },
    
})