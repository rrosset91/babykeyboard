({
    //Construção body, chamada post para envio dos dados ao Robo
    postToURL: function(path, params) {
        
        var form = document.createElement('form');
        
        form.setAttribute('method', 'post');
        form.setAttribute('action', path);
        form.setAttribute('target', '_parent');
        
        for (var key in params) {
            if (key != 'attributes' && params.hasOwnProperty(key)) {
                
                var hiddenField = document.createElement('input');
                hiddenField.setAttribute('type', 'hidden');
                hiddenField.setAttribute('name', key);
                hiddenField.setAttribute('value', params[key]);
                
                form.appendChild(hiddenField);
            }
        }
        
        document.body.appendChild(form);
        form.submit();
    },
    displayError: function(component, type)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Alerta",
            "type": type,
            "duration": 10000,
            "message":component.get("v.errorMessage"),
        });
        toastEvent.fire();
    },
})