<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.Reports.TxnDetail.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../../../js/functions.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript">
        function GetAgentId() {
            return GetValue("<%=pAgent.ClientID %>");
        }

        function LoadCalendars() {
            ShowCalDefault("#<% =frmDate.ClientID%>");
            ShowCalDefault("#<% =toDate.ClientID%>");
        }
        LoadCalendars();
    </script>
    <script type="text/javascript">
        function OpenReport(rptType) {
            var country = "";
            country = GetValue("<% =pCountry.ClientID %>");
              if (country != "") {
                  country = GetElement("<% = pCountry.ClientID%>").options[GetElement("<% = pCountry.ClientID%>").selectedIndex].text;
            }
            var agent = GetValue("<% =pAgent.ClientID %>");
              var sBranch = GetValue("<% =Sbranch.ClientID %>");
         <%-- var depositType = GetValue("<% =depositType.ClientID %>");--%>
              var depositType = "";

              var orderBy = GetValue("<% =orderBy.ClientID %>");
            var status = GetValue("<% =status.ClientID %>");
              var paymentType = GetValue("<% =paymentType.ClientID %>");
              var dateField = GetValue("<% =dateField.ClientID %>");
              var from = GetDateValue("<% =frmDate.ClientID %>");
              var to = GetDateValue("<% =toDate.ClientID %>");
              var transType = GetValue("<% =tranType.ClientID %>");
              var searchBy = GetValue("<% =searchBy.ClientID %>");
              var searchByValue = GetValue("<% =searchByValue.ClientID %>");
              var displayTranNo = "";
              if (document.getElementById("displayTranNo").checked == true) {
                  displayTranNo = "Y";
              }
              else {
                  displayTranNo = "N";
              }

              var url = "../../Reports.aspx?reportName=40111600&pCountry=" + country +
              "&pAgent=" + agent +
              "&sBranch=" + sBranch +
              "&depositType=" + depositType +
              "&searchBy=" + searchBy +
              "&searchByValue=" + searchByValue +
              "&orderBy=" + orderBy +
              "&status=" + status +
              "&paymentType=" + paymentType +
              "&dateField=" + dateField +
              "&from=" + from +
              "&to=" + to +
              "&transType=" + transType +
              "&rptType=" + rptType +
              "&displayTranNo=" + displayTranNo;

              OpenInNewWindow(url);
          }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">Transaction Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- First Panel -->
                <div class="col-md-8">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive">
                                <tr style="display: none;">
                                    <td nowrap="nowrap">Beneficiary:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" CssClass="form-control" ID="pCountry" Width="300px"
                                            AutoPostBack="false">
                                        </asp:DropDownList>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr style="display: none;">
                                    <td nowrap="nowrap">Agent Name:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="pAgent" Width="300px" AutoPostBack="true" CssClass="form-control">
                                            <asp:ListItem Value="">All</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Branch Name:
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="Sbranch" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">Search By:
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList runat="server" ID="searchBy" CssClass="form-control">
                                            <asp:ListItem Value="" Selected="True">All</asp:ListItem>
                                            <asp:ListItem Value="sName">By Sender Name</asp:ListItem>
                                            <asp:ListItem Value="rName">By Receiver Name</asp:ListItem>
                                            <asp:ListItem Value="icn">By BRN</asp:ListItem>
                                            <asp:ListItem Value="cAmt">Collection Amount</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="searchByValue" placeholder="Search by Value" CssClass="form-control">
                                        </asp:TextBox>
                                    </td>
                                </tr>
                                <tr style="display: none;">
                                    <td>Order By:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="orderBy" Width="300px" CssClass="form-control">
                                            <asp:ListItem Value="sName">By Sender Name</asp:ListItem>
                                            <asp:ListItem Value="sCompany">By Sender Company</asp:ListItem>
                                            <asp:ListItem Value="rName">By Receiver Name</asp:ListItem>
                                            <asp:ListItem Value="rAmnt">By Receive Amt</asp:ListItem>
                                            <asp:ListItem Value="empId">By Emp Id</asp:ListItem>
                                            <asp:ListItem Value="dot" Selected="True">By Date Of Transaction(DOT)</asp:ListItem>
                                            <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Status:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="status" CssClass="form-control" Width="300px" AutoPostBack="True" OnSelectedIndexChanged="status_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Tran Type:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="tranType" Width="300px" CssClass="form-control">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">Payment Type:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="paymentType" Width="300px" CssClass="form-control">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr style="display: none;">
                                    <td nowrap="nowrap">Date Type:
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="dateField" Width="300px" CssClass="form-control">
                                            <asp:ListItem Value="trnDate">By TRN Date</asp:ListItem>
                                            <asp:ListItem Value="confirmDate" Selected="true">By Confirm Date</asp:ListItem>
                                            <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap"></td>
                                    <td>From Date 
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="frmDate" runat="server" ReadOnly="true" Width="260px" CssClass="form-control"></asp:TextBox>
                                            </div>
                                    </td>
                                    <td>To Date 
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="toDate" runat="server" ReadOnly="true" Width="260px" CssClass="form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr style="display: none;">
                                    <td></td>
                                    <td>
                                        <asp:CheckBox runat="server" ID="displayTranNo" Text="Display Tran No" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;
                                    </td>
                                    <td>
                                        <input type="button" class="btn btn-primary m-t-25" value="View Send Details" onclick="OpenReport('s');" />
                                        <input type="button" class="btn btn-primary m-t-25" value="View Pay Details" onclick="OpenReport('p');" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
