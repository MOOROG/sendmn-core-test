<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="TranReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.TranReport" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Transaction</li>
                            <li class="active">Report History</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search By Date</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">From Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-4"> 
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
                                    ControlToValidate="fromDate" CssClass="errormsg" Display="Dynamic"
                                    ErrorMessage="*" SetFocusOnError="True" ValidationGroup="tran">
                                   </asp:RequiredFieldValidator>
                                    </div>
                                    <div class="col-md-4">
                                    <asp:RangeValidator ID="RangeValidator1" runat="server"
                                        ControlToValidate="fromDate"
                                        MaximumValue="12/31/2100"
                                        MinimumValue="01/01/1900"
                                        Type="Date"
                                        ErrorMessage="* Invalid date"
                                        ValidationGroup="tran"
                                        CssClass="errormsg"
                                        SetFocusOnError="true"
                                        Display="Dynamic"></asp:RangeValidator>
                                      </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">To Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row">
                                   <div class="col-md-4">
                                     <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                                    ControlToValidate="toDate" CssClass="errormsg" Display="Dynamic"
                                    ErrorMessage="*" SetFocusOnError="True" ValidationGroup="tran">
                                   </asp:RequiredFieldValidator>
                                  </div>
                                    <div class="col-md-4">
                                        <asp:CompareValidator ID="CompareValidator1" Operator="GreaterThanEqual" Type="Date"
                                            ControlToValidate="toDate" ControlToCompare="fromDate"
                                            CssClass="errormsg" ValidationGroup="tran"
                                            ErrorMessage="* Can not be less than From Date" runat="server" />
                                    </div>
                                    <div class="col-md-4">
                                        <asp:RangeValidator ID="RangeValidator2" runat="server"
                                            ControlToValidate="toDate"
                                            MaximumValue="12/31/2100"
                                            MinimumValue="01/01/1900"
                                            Type="Date"
                                            ErrorMessage="*Invalid date"
                                            ValidationGroup="tran"
                                            CssClass="errormsg"
                                            SetFocusOnError="true"
                                            Display="Dynamic"> 
                                        </asp:RangeValidator>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="control-label col-md-3">Report Type :</label>
                                <div class="col-md-8"><asp:DropDownList ID="reportType" runat="server"  CssClass="form-control">
                                    <asp:ListItem Value="O">Others</asp:ListItem>
                                    <asp:ListItem Value="C">Complain</asp:ListItem>
                                    <asp:ListItem Value="X">Close</asp:ListItem>
                                </asp:DropDownList></div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3"></label>
                                <div class="col-md-8"> 
                                <asp:RadioButton ID="RadioButton1" runat="server" />
                                <asp:RadioButton ID="RadioButton2" runat="server" /></div>
                            </div>
                             <div class="form-group">
                                <label class="control-label col-md-3"></label>
                                <div class="col-md-8"><asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25"  Text="Show" ValidationGroup="tran" OnClientClick="return showReport();" /></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


       <%-- <table border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td width="100%">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom">
                                <div>Transaction » Report History </div>
                            </td>
                        </tr>
                        <tr>
                            <td height="10" class="welcome"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table border="0" cellspacing="0" cellpadding="0" class="formTable">
                        <tr>
                            <th class="frmTitle" colspan="2">Search By Date</th>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" valign="top" class="frmLable">From Date:
                            </td>
                            <td nowrap="nowrap">
                                <asp:TextBox ID="fromDate" runat="server" CssClass="formText" Width="200px" MaxLength="10"></asp:TextBox>
                                <cc1:CalendarExtender ID="CalendarExtender1" TargetControlID="fromDate" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
                                    ControlToValidate="fromDate" CssClass="errormsg" Display="Dynamic"
                                    ErrorMessage="*" SetFocusOnError="True" ValidationGroup="tran">
                                </asp:RequiredFieldValidator>

                                <br />
                                <asp:RangeValidator ID="RangeValidator1" runat="server"
                                    ControlToValidate="fromDate"
                                    MaximumValue="12/31/2100"
                                    MinimumValue="01/01/1900"
                                    Type="Date"
                                    ErrorMessage="* Invalid date"
                                    ValidationGroup="tran"
                                    CssClass="errormsg"
                                    SetFocusOnError="true"
                                    Display="Dynamic"> </asp:RangeValidator>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" valign="top" class="frmLable">To Date:
                            </td>
                            <td nowrap="nowrap">
                                <asp:TextBox ID="toDate" runat="server" CssClass="formText" Width="200px" MaxLength="10"></asp:TextBox>
                                <cc1:CalendarExtender ID="CalendarExtender2" TargetControlID="toDate" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                                    ControlToValidate="toDate" CssClass="errormsg" Display="Dynamic"
                                    ErrorMessage="*" SetFocusOnError="True" ValidationGroup="tran">
                                </asp:RequiredFieldValidator>
                                <br />
                                <asp:CompareValidator ID="CompareValidator1" Operator="GreaterThanEqual" Type="Date"
                                    ControlToValidate="toDate" ControlToCompare="fromDate"
                                    CssClass="errormsg" ValidationGroup="tran"
                                    ErrorMessage="* Can not be less than From Date" runat="server" />
                                <br />
                                <asp:RangeValidator ID="RangeValidator2" runat="server"
                                    ControlToValidate="toDate"
                                    MaximumValue="12/31/2100"
                                    MinimumValue="01/01/1900"
                                    Type="Date"
                                    ErrorMessage="*Invalid date"
                                    ValidationGroup="tran"
                                    CssClass="errormsg"
                                    SetFocusOnError="true"
                                    Display="Dynamic"> </asp:RangeValidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="frmLable">Report Type</td>
                            <td>
                                <asp:DropDownList ID="reportType" runat="server" Width="130px">
                                    <asp:ListItem Value="O">Others</asp:ListItem>
                                    <asp:ListItem Value="C">Complain</asp:ListItem>
                                    <asp:ListItem Value="X">Close</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap">
                                <div align="right" class="formLabel"></div>
                            </td>
                            <td>--%>
                             <%--   <asp:RadioButton ID="RadioButton1" runat="server" />

                                <asp:RadioButton ID="RadioButton2" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap">&nbsp;</td>
                            <td>--%>
                    <%--            <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25"
                                    Text="Show" ValidationGroup="tran" OnClientClick="return showReport();" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {

        if (!Page_ClientValidate('tran'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var reportType = GetValue("<% =reportType.ClientID%>");

        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=tran" +
                       "&fromDate=" + fromDate +
                       "&toDate=" + toDate +
                       "&reportType=" + reportType;


        OpenInNewWindow(url);

        return false;

    }
</script>
