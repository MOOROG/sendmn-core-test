<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddHighRiskCountry.aspx.cs"
    Inherits="Swift.web.Remit.RiskBaseAnalysis.RBACriteria.AddHighRiskCountry" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript">

        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }


        function RedirectToIframe(url) {
            window.open(url, "_self");
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
                            <li><a href="#" onclick="return LoadModule('remit')">Risk Based Assessment</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('remit_compliance')">Add High Risk Country</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="Remittance.aspx">Remittance</a></li>
                    <li><a href="MoneyExchange.aspx">Money Exchange</a></li>
                    <li class="active"><a href="Remittance.aspx">Add High Risk Country</a></li>
                </ul>
            </div>
            <div class="tab-content" id="trNew" runat="server">
                <div role="tabpanel" class="tab-pane active">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Add High Risk Country
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            Country:<span class="errormsg">*</span>
                                            <span runat="server" id="r1" visible="false" class="errMsg" style="color: Red; width:30%;">Required!</span>
                                        </label>
                                        <uc1:SwiftTextBox ID="country" runat="server" Category="remit-countryOp"/>
                                            
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            Block Country:
                                        </label>
                                        <asp:CheckBox ID="chkBlockCountry" runat="server" />
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnAddCountry" runat="server" Text="Add Country" CssClass="btn btn-primary" OnClick="btnAddCountry_Click" />
                                        <asp:Button ID="btnUpdateCountry" runat="server" Text="Update Country" Visible="false"
                                            CssClass="btn btn-primary" Width="100px" OnClick="btnUpdateCountry_Click" />
                                    </div>
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        <div class="tab-content">
                <div role="tabpanel" class="tab-pane active">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">High Risk Country List
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv">
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
