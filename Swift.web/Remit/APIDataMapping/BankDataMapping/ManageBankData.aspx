<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageBankData.aspx.cs" Inherits="Swift.web.Remit.APIDataMapping.BankDataMapping.ManageBankData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <style>
        .banklist .table > tbody > tr > td > input {
            height: 27.5px;
        }

        .table > tbody > tr > td {
            height: 32px !important;
        }

        .banklist .table > tbody > tr > td {
            padding: 2px;
        }
    </style>
    <script type="text/javascript">
        function ShowMappedData() {
            var country = '<%=GetCountry()%>';
            var partner = '<%=GetPartner()%>';
            var paymentType = '<%=GetPaymentMode()%>';
            var partnerName = '<%=GetPartnerName()%>';
            var countryName = '<%=GetCountryName()%>';
            var paymentTypeName = '<%=GetPaymentTypeName()%>';

            var qs = "paymentTypeName=" + paymentTypeName + "&countryName=" + countryName + "&partnerName=" + partnerName + "&country=" + country + "&partner=" + partner + "&paymentType=" + paymentType;

            OpenInNewWindow("/Remit/APIDataMapping/BankDataMapping/ShowMappedData.aspx?" + qs);
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">API Data Mapping </a></li>
                            <li class="active"><a href="ManageBankData.aspx">Map Bank Data </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Map Bank Data
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label>
                                        <asp:Label ID="detailsLabel" runat="server"></asp:Label></label>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label>
                                        Show No Of Banks At A Time:</label>
                                    <asp:DropDownList ID="ddlNoOfBanks" runat="server" OnSelectedIndexChanged="ddlNoOfBanks_SelectedIndexChanged" AutoPostBack="true">
                                        <asp:ListItem Text="10" Value="10"></asp:ListItem>
                                        <asp:ListItem Text="20" Value="20"></asp:ListItem>
                                        <asp:ListItem Text="30" Value="30"></asp:ListItem>
                                        <asp:ListItem Text="40" Value="40"></asp:ListItem>
                                        <asp:ListItem Text="50" Value="50"></asp:ListItem>
                                        <asp:ListItem Text="100" Value="100"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-xs-6 col-sm-6 col-md-6">
                                <div class="form-group">
                                    <table class="table table-responsive table-condensed table-bordered">
                                        <thead>
                                            <tr>
                                                <th colspan="2">Master Bank List</th>
                                            </tr>
                                            <tr>
                                                <th>Bank Name</th>
                                                <th>JME Bank Code</th>
                                            </tr>
                                        </thead>
                                        <tbody id="masterTableBody" runat="server">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-xs-6 col-sm-6 col-md-6">
                                <div class="form-group banklist">
                                    <table class="table table-responsive table-condensed table-bordered">
                                        <thead>
                                            <tr>
                                                <th colspan="2">
                                                    <asp:Label ID="payoutPartner" runat="server"></asp:Label>
                                                </th>
                                            </tr>
                                            <tr>
                                                <th>Bank Name | Partner Bank Code</th>
                                                <th>JME Bank Code</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tableBody" runat="server">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-xs-6 col-sm-6 col-md-6">
                                <div class="form-group">
                                    <asp:Button ID="btnDownloadBank" runat="server" Text="Download" OnClick="btnDownloadBank_Click" CssClass="btn btn-primary" />
                                    <asp:Button ID="btnLoadFromTemp" runat="server" Text="Load From Temp" OnClick="btnLoadFromTemp_Click" CssClass="btn btn-primary" />
                                    <asp:Button ID="btnSaveMapping" runat="server" Text="Map Data" OnClick="btnSaveMapping_Click" CssClass="btn btn-primary" />
                                    <input type="button" id="btnShowMappedData" onclick="ShowMappedData()" runat="server" value="Show Mapped List" class="btn btn-primary" />
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
