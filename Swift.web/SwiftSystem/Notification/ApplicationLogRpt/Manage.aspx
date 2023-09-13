<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.ApplicationLogRpt.Manage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
        });
    </script>
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
                            <li><a href="#" onclick="return LoadModule('system_security')">System Security</a></li>
                            <li class="active"><a href="Manage.aspx">Tran View  Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- panel1 -->
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search By Trans/Ref. No</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">Tran ID: </label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="tranId" runat="server" CssClass="form-control" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Control No. : </label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3"></label>
                                <div class="col-md-8">
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25"
                                        Text="Search" OnClientClick="return showReport();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- panel2 -->
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search By Date/Category </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">From Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">To Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">Search By :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3"></label>
                                <div class="col-md-3">
                                    <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary m-t-25" ValidationGroup="rpt"
                                        Text="Search" OnClientClick="return showReportDateWise();" />
                                </div>
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
                        <td height="26" class="bredCrom"> <div > Reports » Application Log Rpt </div> </td>
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
                        <th class="frmTitle" colspan="2">Search By Trans/Ref. No</th>
                    </tr>
                    <tr>
                        <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> Tran ID: </div> </td>
                        <td nowrap="nowrap">
                                <asp:TextBox ID= "tranId" runat = "server" CssClass = "input" Width="120px"></asp:TextBox>
                     </td>
                    </tr>
                    <tr>
                        <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> Control No.:</div>
                        </td>
                        <td nowrap="nowrap">  
                            <asp:TextBox ID= "controlNo" runat = "server" CssClass = "input" Width="120px"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            <asp:Button ID="BtnSave" runat="server" CssClass="button" 
                                        Text="Search"
                                OnClientClick="return showReport();" /> 
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0" class="formTable">
                    <tr>
                        <th class="frmTitle" colspan="4">Search By Date/Category </th>
                    </tr>
                    <tr>--%>
        <%--          <td nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> From Date: </div> </td>
                        <td nowrap="nowrap">
                            <asp:TextBox ID= "fromDate" runat = "server" class="fromDatePicker" size="12" Width="120px"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                        </td>
                        <td nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> To Date:</div>
                        </td>
                        <td nowrap="nowrap">  
                            <asp:TextBox ID= "toDate" runat = "server" class="toDatePicker" size="12" Width="120px"></asp:TextBox>
                            <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> Search By:</div>
                        </td>
                        <td nowrap="nowrap" colspan="3">  
                            <asp:DropDownList ID= "searchBy" runat = "server" CssClass = "input" Width="350px">                             
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            <asp:Button ID="Button1" runat="server" CssClass="button"   ValidationGroup="rpt"
                             Text="Search"  OnClientClick="return showReportDateWise();" /> 
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

        var tranId = GetValue("<% =tranId.ClientID%>");
        var controlNo = GetValue("<% =controlNo.ClientID%>");

        if ((tranId == null || tranId == "") && (controlNo == null || controlNo == "")) {
            alert("Tran Id Or Control No Is Required");
            return false;
        }

        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=logByTran" +
            "&tranId=" + tranId +
            "&controlNo=" + controlNo;

        OpenInNewWindow(url);

        return false;

    }

    function showReportDateWise() {
        //if (!Page_ClientValidate('rpt'))
        //    return false;
        var fromDate = $('#fromDate').val();
        var toDate = $('#toDate').val();
        var searchBy = GetValue("<% =searchBy.ClientID%>");

        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=logByDate" +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&searchBy=" + searchBy;

        OpenInNewWindow(url);

        return false;

    }
</script>
