$(document).ready(function () {
    $('#jmeContinueSign,#step4button').click(function (event) {
        CustomerSignature();
    });
});
var signaturePad = "";
CustomerSignature();
function CustomerSignature() {
    var isdisplayDignature = $("#" + ContentPlaceHolderId + "isDisplaySignature").val();
    if (isdisplayDignature.toLowerCase() === 'true') {
        var wrapper = document.getElementById("signature-pad");
        var clearButton = wrapper.querySelector("[data-action=clear]");
        var undoButton = wrapper.querySelector("[data-action=undo]");
        var canvas = wrapper.querySelector("canvas");
        signaturePad = new SignaturePad(canvas, {
            backgroundColor: 'rgb(255, 255, 255)'
        });

        function resizeCanvas() {
            var ratio = Math.max(window.devicePixelRatio || 1, 1);
            canvas.width = canvas.offsetWidth * ratio;
            canvas.height = canvas.offsetHeight * ratio;
            canvas.getContext("2d").scale(ratio, ratio);
            signaturePad.clear();
        }

        window.onresize = resizeCanvas;
        resizeCanvas();

        clearButton.addEventListener("click", function (event) {
            signaturePad.clear();
        });

        undoButton.addEventListener("click", function (event) {
            var data = signaturePad.toData();

            if (data) {
                data.pop(); // remove the last dot or line
                signaturePad.fromData(data);
            }
        });
    }
}
function CheckSignatureCustomer() {
    var isdisplayDignature = $("#" + ContentPlaceHolderId + "isDisplaySignature").val();
    if (isdisplayDignature.toLowerCase() === 'true') {
        var customerPassword = $('#' + ContentPlaceHolderId + 'customerPassword').val();
        //if (signaturePad.isEmpty() && (customerPassword === "" || customerPassword === null)) {
        //    alert("Customer signature or customer password is required");
        //    $('#' + ContentPlaceHolderId + 'hddImgURL').val('');
        //    return false;
        //}
        if (signaturePad.isEmpty()) {
            alert("Customer signature  is required");
            $('#' + ContentPlaceHolderId + 'hddImgURL').val('');
            return false;
        }
        if (!signaturePad.isEmpty()) {
            var dataURL = signaturePad.toDataURL('image/png');
            $('#' + ContentPlaceHolderId + 'hddImgURL').val(dataURL.replace('data:image/png;base64,', ''));
            return true;
        }
        if(signaturePad.isEmpty()) {
            $('#' + ContentPlaceHolderId + 'hddImgURL').val('');
            return true;
        }
    }
    return true;
}