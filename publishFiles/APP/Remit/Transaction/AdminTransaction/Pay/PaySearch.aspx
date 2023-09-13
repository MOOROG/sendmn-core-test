<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaySearch.aspx.cs" Inherits="Swift.web.Remit.Transaction.PayTransaction.PaySearch" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/ui/js/metisMenu.min.js" type="text/javascript"></script>
    <style type="text/css">
        #progressBar {
            border: 1px solid #ccc;
            display: none;
        }
    </style>
    <script type="text/javascript">
        $.validator.messages.required = "Required!";
        $(document).ready(function () {
            $.ajaxSetup({ cache: false });
        });

        function CallBackAutocomplete(id) {
            if (id == null || id == "") {
                alert("Agent Id Returned while choosing Agent/Branch");
                return false;
            }

            var agentId = GetItem("<%=agentName.ClientID %>")[0];

            var dataToSend = { branchid: agentId, MethodName: "loadbranchuser" };
            $.post('PaySearch.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
                populateBranchUser(response);
            }).fail(function () {
                alert("Error from populate branch user");
            });
            return true;

        }

        function populateBranchUser(response) {
            var data = jQuery.parseJSON(response);
            var ddl = document.getElementById("<%=ddlUser.ClientID%>");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'Select Branch User';
            option.value = '';

            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].text;
                option.value = data[i].value;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function SearchTxnPriority() {
            var partener = $("#partner").val();
            var controlNo = $("#icn").val();
            var branchId = GetItem("<% = agentName.ClientID %>")[0];
            var branchUser = $('#<%=ddlUser.ClientID%> option:selected').text();
            var branchUserID = $('#<%=ddlUser.ClientID%>').val();

            if (branchUser == null || branchUser == "" || branchUserID == null || branchUserID == "") {
                alert("Please select branch user.");
                return false;
            }

            if (branchId == "") {
                alert("Please select payout agent.");
                return false;
            }

            if (controlNo == "") {
                alert("Please enter control number.");
                return false;
            }

            var dataToSend = { branchuser: branchUser, branchId: branchId, partener: partener, controlNo: controlNo, MethodName: "search" };

            $.ajax({
                type: "POST",
                url: '<%=ResolveUrl("PaySearch.aspx") %>?x=1232',
                data: dataToSend,
                success: function (response, status, xhr) {
                    if (response == null || response == "")
                        return false;

                    var data = eval("[" + response + "]");
                    var url = "";
                    if (data[0].ErrorCode == "0") {
                        url = "Pay.aspx?id=" + data[0].Id + "&branchId=" + data[0].Extra + "&partenerId=" + data[0].Extra2 + "&username=" + data[0].TpErrorCode;

                        if (data[0].Id != "") {
                            window.location.href = url;
                        }
                    }
                    else if (data[0].ErrorCode == "101") {
                        url = "PayCompliance.aspx?id=" + data[0].Id + "&branchId=" + data[0].Extra + "&partenerId=" + data[0].Extra2;
                        if (data[0].Id != "") {
                            window.location.href = url;
                        }
                    }
                    else {
                        alert(data[0].Msg);

                    }
                },
                error: function (request, error) {
                    alert(request);

                }
            });
            return false;
        }

        $(document).ajaxStart(function () {
            $("#btnGo").hide();
            $("#progressBar").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#progressBar").hide();
            $("#btnGo").show();
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="PaySearch.aspx">Pay Transaction </a></li>
                        </ol>
                        <li class="active">
                            <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                        </li>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        <asp:Label ID="header" runat="server"> Pay  Transaction</asp:Label>
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-6 form-group">
                                            <div class="row">
                                                <div class="form-group">
                                                    <div id="agentNameDiv" class="headers" runat="server">
                                                        <asp:Label ID="lblAgentName" runat="server"></asp:Label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">

                                                    <label class="control-label col-lg-3 col-md-3" for="">
                                                        Agent:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <uc1:SwiftTextBox ID="agentName" runat="server" Category="remit-agent" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">

                                                    <label class="control-label col-lg-3 col-md-3" for="">
                                                        User:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList runat="server" ID="ddlUser" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-lg-3 col-md-3">
                                                        <%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="icn" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-lg-3 col-md-3">
                                                        Partner:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList runat="server" ID="partner" CssClass="form-control">
                                                            <asp:ListItem Text="All" Value=""></asp:ListItem>
                                                            <asp:ListItem Text="GLOBALIME BANK LTD.- GLOBAL IME REMIT" Value="1069"></asp:ListItem>
                                                            <asp:ListItem Text="KUMARI BANK LTD." Value="KM"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-offset-3 col-md-8">
                                                        <input type="button" class="btn btn-primary btn-sm" id="btnGo" value="Pay Transaction" onclick="return SearchTxnPriority();" />
                                                    </div>
                                                    <div class="col-md-offset-3 col-md-8">
                                                        <img id="progressBar" src="../../../../Images/progressBar.gif" border="0" alt="Loading..." />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12 form-group" style="display: none;">
                                            <div id="dvContent" runat="server">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>