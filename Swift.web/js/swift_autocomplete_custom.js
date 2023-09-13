function LoadAutoCompleteTextBoxCustom(url, id, width, data) { 
    var aValue = id + "_aValue";
    var aText = id + "_aText";
    var aSearch = id + "_aSearch";
    var aCustom = id + "_aCustom";
    if (width != "") {
        //$(aText).width(width);
    }
    

    //$(aSearch).width($(aText).width());

    $(aText).focus(function () {
        $(aSearch).val($(aText).val());
        $(aSearch).show();
        $(aSearch).focus();
        $(aText).hide();
        $(aSearch).select();
    });

    $(aSearch).blur(function () {
        $(this).hide();
        if ($(aSearch).val() == "") {
            $(aValue).val("");
            $(aText).val("");
        }
        $(aText).show();

    });


    $(aSearch).autocomplete({
        source: function (request, response) {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: url,
                data: "{" + data + ", 'searchText' : '" + request.term + "'}",
                dataFilter: function (data) { return data; },
                success: function (data) {
                    response($.map(data.d, function (item) {
                        return {
                            value: item.Value,
                            id: item.Id
                        }
                    }))
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Oops,there is an error in ssytem, please contact HO");
                    //alert(errorThrown);
                    //alert(textStatus);
                }
            });
        },
        minLength: 1,
        select: function (event, ui) {
            
            if (ui.item) {
                
                
                
                var a = ui.item.value;
                var custom = a.split(":");
                $(aText).val(custom[0]);
                $(aCustom).val(custom[1]);
                $(aValue).val(ui.item.id);
                
                try {
                    CallBackAutocomplete(id);
                } catch (ex) { }
            }
        }
    });
}

function GetItem(id) {
    var text = $("#" + id + "_aText").val();
    var value = $("#" + id + "_aValue").val();

    var DataList = new Array();
    DataList[0] = value;
    DataList[1] = text;
    return DataList;
}

function SetItem(id, data) {
    $("#" + id + "_aValue").val(data[0]);
    $("#" + id + "_aText").val(data[1]);
}