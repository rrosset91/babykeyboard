({
    
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.filteredData");
        //function to return the value stored in the field
        // if(fieldName == 'consentCreationDate'){
        //     fieldName = 'timestamp';
        // }
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'consentCreationDate'){ 
            key = function(a) { return a['timestamp']; }
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to consentsData attribute
        component.set("v.filteredData",data);
    }

})