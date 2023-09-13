function MenuControl() {
    if (ALT && CHAR_CODE == 76) {
        if (confirm("Are you sure you want to lock application?")) {
            //            Session("url") = document.getElementById("frmame_main").contentWindow.location.href;
            var url = document.getElementById("frmame_main").contentWindow.location.href;
            window.location.replace('Lock.aspx?url=' + url);
        }
    }
    //SEND DOMESTIC PAGE
    else if (CHAR_CODE == 114) {
        window.parent.frames['frmame_main'].location.href = "/Remit/Transaction/Agent/Send/Domestic/Send.aspx";
    }
    //SEND INTERNATIONAL PAGE
    else if (CHAR_CODE == 113) {
        window.parent.frames['frmame_main'].location.href = "/Remit/Transaction/International/Send/Send.aspx";
    }
    //PAYMENT PAGE
    else if (CHAR_CODE == 115) {
        window.parent.frames['frmame_main'].location.href = "/Remit/Transaction/Agent/Pay/Pay.aspx";
    }
    //Statement Of Account
    else if (CHAR_CODE == 117) {
        window.parent.frames['frmame_main'].location.href = "/Remit/Transaction/Reports/AgentReport/StmtOfAC_Agent.aspx";
    }
    //Enroll PAGE
    else if (CHAR_CODE == 118) {
        window.parent.frames['frmame_main'].location.href = "/Remit/Administration/AgentCustomerSetup/List.aspx";
    };
}