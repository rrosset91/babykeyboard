({
    handleShowPopover : function(component, event, helper) {
        var selectedItem = event.target.getAttribute("data-value");
        var selectedItemCss =event.target.getAttribute("id");
        var str = "";
        str += "."+selectedItemCss;
        component.set("v.popOverValue",selectedItem);       
        
        var dinamicCss;
        if(selectedItem > 70){
            dinamicCss = 'greenPopover,greenPointer,cSolar_Cross_CEMUserExperience'
        }
        else if(selectedItem > 30){
            dinamicCss = 'yellowPopover,yellowPointer,cSolar_Cross_CEMUserExperience'
        }
        else{
            dinamicCss = 'redPopover,redPointer,cSolar_Cross_CEMUserExperience'
        }
        selectedItem += ' %';
        component.find('overlayLib').showCustomPopover({
            body: selectedItem,
            referenceSelector: str,
            // cssClass: "popoverclass,yellowPointer,cSolar_Cross_CEMUserExperience"
            cssClass: dinamicCss
        }).then(function (overlay) {
            setTimeout(function(){
                //close the popover after 1 seconds
                overlay.close();
            }, 2000);
        });
    },
})

// labels:
// CEMEmptyData
//CEMIntegrationErrorMessage