<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowMappedData.aspx.cs" Inherits="Swift.web.Remit.APIDataMapping.BankDataMapping.ShowMappedData" %>

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
        function ShowOtherBanks() {
            var country = '<%=GetCountry()%>';
            var partner = '<%=GetPartner()%>';
            var paymentType = '<%=GetPaymentMode()%>';
            var partnerName = '<%=GetPartnerName()%>';
            var countryName = '<%=GetCountryName()%>';
            var paymentTypeName = '<%=GetPaymentTypeName()%>';

            var qs = "paymentTypeName=" + paymentTypeName + "&countryName=" + countryName + "&partnerName=" + partnerName + "&country=" + country + "&partner=" + partner + "&paymentType=" + paymentType;

            OpenInNewWindow("/Remit/APIDataMapping/BankDataMapping/ShowTmpList.aspx?" + qs);
        }
        function Editclicked(id) {
            var realId = '#' + id + "_aText";
            var editId = '#' + "edit_" + id;
            var saveId = '#' + "save_" + id;
            $(realId).prop('disabled', false);
            $(saveId).prop('disabled', false);
            $(editId).prop('disabled', true);
            event.preventDefault();
            //$("realId").prop('disabled', false);
        }
        function SavedClicked(rowId, bankId) {
            $("#hdnEditedRowNumber").val(rowId);
            var realId = '#' + bankId + "_aText";
            var changedBankId = $(realId).val();
            $('#changedBank').val($.trim(changedBankId.split('|')[1]));
            var dataToSend = {
                MethodName: "EditMappedData"
                , hdnEditedRowNumber: $("#hdnEditedRowNumber").val()
                , countryName:'<%=GetCountryName()%>'
                , paymentTypeId:'<%=GetPaymentMode()%>'
                , apiPartner:'<%=GetPartner()%>'
                , changedBankId: $('#changedBank').val()
            };
            $.ajax({
                type: "POST",
                url: "ShowMappedData.aspx",
                data: dataToSend,
                success: function (response) {
                        alert(response.Msg);
                },
                fail: function (response) {
                    alert(response.Msg);
                }
            });
        }

        function SetMessageBox(msg, id) {
            alert(msg);
        }
    </script>
    <style>
        .matchedListTable .table > tbody > tr > td {
            color: #000;
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div>
                <asp:HiddenField runat="server" ID="hdnEditedRowNumber" />
                <asp:HiddenField runat="server" ID="changedBank" />
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Mapped Bank List (<%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Bank List And Partner Bank List)
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
                                <div class="form-group matchedListTable">
                                    <table class="table table-responsive table-condensed table-bordered">
                                        <thead>
                                            <tr>
                                                <th>Master Bank Name</th>
                                                <th><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Bank Code</th>
                                                <th>Partner Bank Name</th>
                                                <th>Partner Bank Code</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="masterTableBody" runat="server">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-12 col-md-12">
                                <div class="form-group">
                                    <asp:Button ID="btnSaveMainTable" runat="server" CssClass="btn btn-primary" Text="Save Into Main Table" OnClientClick="return ConfirmSave();" OnClick="btnSaveMainTable_Click" />
                                    <asp:Button ID="btnShowOtherBanks" runat="server" CssClass="btn btn-primary" Text="Show Banks(Not present in Master)" OnClientClick="ShowOtherBanks();" />
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
