({
	// Função para esconder uma seção ao clicar em outro elemento (como um header/label)
    toggleVisibilidadeSecao: function(cmp, headerName) {
        var query = 'secao' + headerName;
        var queryHeader = 'header' + headerName;
        var header = document.getElementById(queryHeader);
        var element = document.querySelectorAll(`div[id^=${query}]`);
        
        if(element.length != 0){
            for (var i=0 ; i < element.length ; i++){
                $A.util.toggleClass(element[i], "slds-hide");
            }
        }
        if (header) {
            $A.util.toggleClass(header, "active");
        }
        
        return null;
    }
})