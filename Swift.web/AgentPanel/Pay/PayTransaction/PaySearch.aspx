<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/AgentNew/AgentMain.Master" CodeBehind="PaySearch.aspx.cs" Inherits="Swift.web.AgentPanel.Pay.PayTransaction.PaySearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
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

        function SearchTxnPriority() {
            var partener = $("#partner").val();
            var controlNo = $("#<%=icn.ClientID%>").val();
            if (controlNo == "") {
                alert("Please enter control number.");
                return false;
            }

            var dataToSend = { controlNo: controlNo, partener: partener, MethodName: "search" };

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
                        url = "Pay.aspx?id=" + data[0].Id + "&partenerId=" + data[0].Extra2;
                        if (data[0].Id != "") {
                            window.location.href = url;
                        }
                    }
                    else if (data[0].ErrorCode == "101") {
                        url = "PayCompliance.aspx?id=" + data[0].Id + "&partenerId=" + data[0].Extra2;
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
            $("#progressBar").show();
            $("#btnGo").hide();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#progressBar").hide();
            $("#btnGo").show();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li class="active"><a href="#" onclick="return LoadModuleAgentMenu('pay_money')">Pay Money</a></li>
                        <li class="active"><a href="PaySearch.aspx">Pay Transaction</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div id="agentNameDiv" class="headers" runat="server">
            <asp:Label ID="lblAgentName" runat="server"></asp:Label>
        </div>
        <div class="panel panel-default" id="tblSearch" runat="server">
            <div class="panel-heading"><i class="fa fa-search"></i>Pay Transaction Search</div>
            <div class="panel-body">
                <div class="row">
                    <div class="form-group">
                        <label class="control-label col-md-2"><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>:<span class="errormsg">*</span></label>
                        <div class="col-md-6">
                            <asp:TextBox CssClass="form-control" ID="icn" runat="server" Text=""></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-md-2">Provider:<span class="errormsg">*</span></label>
                        <div class="col-md-6">
                            <asp:DropDownList runat="server" ID="partner" CssClass="form-control">
                                <asp:ListItem Text="All" Value=""></asp:ListItem>
                                <asp:ListItem Text="GLOBALIME BANK LTD.- GLOBAL IME REMIT" Value="1069"></asp:ListItem>
                                <asp:ListItem Text="KUMARI BANK LTD." Value="KM"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-3 col-md-offset-2">
                            <input type="button" id="btnGo" value="Pay Transaction" onclick="return SearchTxnPriority();" class="btn btn-primary btn-sm" />
                            <img id="progressBar" src="/Images/progressBar.gif" border="0" alt="Loading..." />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="container" style="display: none">
            <div class="row">
                <div id="dvContent" runat="server"></div>
            </div>
        </div>
    </div>
</asp:Content>