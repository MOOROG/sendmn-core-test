<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.InternationalOperation.CreditLimit.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js"></script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>

    <script type="text/javascript">
        function TopUp(id) {
            if (id == "undefined" || id == null)
                return;
              SetValueById("<%=hdnAmount.ClientID %>", GetValue("topUp_" + id), "");
              SetValueById("<%=hdnAgentId.ClientID %>", id, "");
              GetElement("<%=btnTopUp.ClientID %>").click();
          }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('international_operation')">Intl Operation</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk')">Credit Risk Management </a></li>
                            <li class="active"><a href="List.aspx">Credit Limit</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Credit Limit List
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                 <div id="rpt_grid" runat="server" enableviewstate="false"></div>
                                <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                                <asp:HiddenField ID="hdnAgentId" runat="server" />
                                <asp:HiddenField ID="hdnAmount" runat="server" />
                                <asp:Button ID="btnCallBack" runat="server" OnClick="btnCallBack_Click" Style="display: none;" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

<script language="javascript">
    function OpenLink(URL) {

        var id = PopUpWindowWithCallBack(URL, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnCallBack.ClientID %>").click();
        }
        return false;
    }
</script>
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../../Autocomplete.asmx/GetAgentNameList";
        $("#grdCrLimitsInt_agentName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urla,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdCrLimitsInt_agentName", result[0], "");
            }

        });
    }
    Autocomplete();
</script>
