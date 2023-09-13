<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowTmpList.aspx.cs" Inherits="Swift.web.Remit.APIDataMapping.BankDataMapping.ShowTmpList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script type="text/javascript">
        $(document).ready(function () {
            $(".check").click(function () {
                $("input[name*='bankListName']").prop("checked", true);
                $('.check').hide();
                $('.uncheck').show();
            });
            $(".uncheck").click(function () {
                $("input[name*='bankListName']").prop("checked", false);
                $('.check').show();
                $('.uncheck').hide();
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Missing Bank List in <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Master Bank List
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
                            <div class="col-xs-12 col-sm-12 col-md-12">
                                <div class="form-group">
                                    <table class="table table-responsive table-condensed table-bordered">
                                        <thead>
                                            <tr>
                                                <th><i class="fa fa-check check" style="display:none;"></i><i class="fa fa-times uncheck"></i></th>
                                                <th>Partner Bank Name</th>
                                                <th>Partner Bank Code</th>
                                            </tr>
                                        </thead>
                                        <tbody id="masterTableBody" runat="server">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-12 col-md-12">
                                <div class="form-group">
                                    <asp:Button ID="btnSaveToMasterTable" runat="server" CssClass="btn btn-primary" Text="Create Missing Bank In Master Table(JME Bank List)" OnClientClick="return ConfirmSave();" OnClick="btnSaveToMasterTable_Click" />
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
