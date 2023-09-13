<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.InternationalTranReport.List" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js"></script>
    <link href="../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../ui/js/pickers-init.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/swift_autocomplete.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="scpm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Remit Transaction Search</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Remit Transaction Search - Sending Agent</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">Sending Agent :</label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="sAgent" runat="server" Category="sendingAgent" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">From Date :</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="sfromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">To Date :</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="stoDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Date Type :</label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="sdateType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="s" Selected="true">CONFIRM DATE</asp:ListItem>
                                        <asp:ListItem Value="p">PAID DATE</asp:ListItem>
                                        <asp:ListItem Value="c">CANCEL DATE</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Payment Status :</label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="spaymentStatus" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="" Selected="true">All</asp:ListItem>
                                        <asp:ListItem Value="paid">PAID</asp:ListItem>
                                        <asp:ListItem Value="Un-Paid">UN-PAID</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6 col-md-offset-3">
                                    <input type="button" value="Old Report" onclick=" showOldReport();" class="btn btn-primary m-t-25" />
                                    <input type="button" value="New Report" onclick="" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Remit Transaction Search - Receiving Agent</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">Receiving Agent :</label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="rAgent" CssClass="form-control" runat="server" Category="sendingAgent" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">From Date :</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="rfromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">To Date :</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="rtoDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Date Type :</label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="rdateType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="s" Selected="true">CONFIRM DATE</asp:ListItem>
                                        <asp:ListItem Value="p">PAID DATE</asp:ListItem>
                                        <asp:ListItem Value="c">CANCEL DATE</asp:ListItem>
                                        <asp:ListItem Value="dr">ERRONEOUSLY PAID</asp:ListItem>
                                        <asp:ListItem Value="cr">PAY ORDER</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Payment Status :</label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="rpaymentStatus" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="" Selected="true">All</asp:ListItem>
                                        <asp:ListItem Value="paid">PAID</asp:ListItem>
                                        <asp:ListItem Value="Un-Paid">UN-PAID</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-10 col-md-offset-3">
                                    <input type="button" value="Show" onclick="" class="btn btn-primary m-t-25" />
                                    <input type="button" value="Show Centralize Report" onclick="" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">MONTHLY REPORT</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-2 control-label">Sending Agent :</label>
                                <div class="col-md-6">
                                    <uc1:SwiftTextBox ID="msagent" CssClass="form-control" runat="server" Category="sendingAgent" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">Receiving Agent :</label>
                                <div class="col-md-6">
                                    <uc1:SwiftTextBox ID="mragent" CssClass="form-control" runat="server" Category="sendingAgent" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">From Date :</label>
                                <div class="col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="mfromdate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">To Date :</label>
                                <div class="col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="mtodate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">Date Type :</label>
                                <div class="col-md-6">
                                    <asp:DropDownList ID="mdateType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="s" Selected="true">CONFIRM DATE</asp:ListItem>
                                        <asp:ListItem Value="p">PAID DATE</asp:ListItem>
                                        <asp:ListItem Value="c">CANCEL DATE</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">Payment Status :</label>
                                <div class="col-md-6">
                                    <asp:DropDownList ID="mpaymentStatus" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="" Selected="true">All</asp:ListItem>
                                        <asp:ListItem Value="paid">PAID</asp:ListItem>
                                        <asp:ListItem Value="Un-Paid">UN-PAID</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label">Report Type :</label>
                                <div class="col-md-6">
                                    <asp:DropDownList ID="mreportType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="s" Selected="true">Sending Agentwise</asp:ListItem>
                                        <asp:ListItem Value="p">Receiving Agentwise</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6 col-md-offset-2">
                                    <input type="button" value="Show" onclick="" class="btn btn-primary m-t-25" />
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
<script>
    function  showOldReport()
    {
        var agentId=GetItem("sAgent")[0];
        if(agentId=="")
        {
            alert("Please pick agent ..");
            return false;
        }
        var fromDate=$("#<% =sfromDate.ClientID %>").val();
        var toDate=$("#<% =stoDate.ClientID %>").val();
        var dateType = $("#<%=sdateType.ClientID %>").val();
        var paymentStatus = $("#<%=spaymentStatus.ClientID %>").val();
        url="../Reports.aspx?reportName=IntOldReport&agentId="+ agentId +"&fromDate="+fromDate+"&toDate="+toDate+"&dateType="+dateType+"&paymentStatus="+paymentStatus+"";
        OpenInNewWindow(url);
        return false;

    }
</script>