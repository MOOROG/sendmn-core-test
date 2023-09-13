<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="VerifyTxn.aspx.cs" Inherits="Swift.web.AgentNew.AgentSend.VerifyTxn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">

        function Approve(id) {
            var amt = parseFloat($("#amt_" + id).val());
            if (amt <= 0) {
                window.parent.SetMessageBox("Invalid Amount", "1");
                return;
            }
            SetValueById("<% = hddTranNo.ClientID %>", id, false);
            GetElement("<% =btnApprove.ClientID %>").click();
        }

        function Reject(id) {
            var amt = parseFloat($("#amt_" + id).val());
            if (amt <= 0) {
                window.parent.SetMessageBox("Invalid Amount", "1");
                return;
            }
            SetValueById("<% = hddTranNo.ClientID %>", id, false);
            GetElement("<% =btnReject.ClientID %>").click();
        }

        function ViewDetails(id) {
            var url = "Manage.aspx?id=" + id;
            PopUpWindow(url);
        }
        //function CallBack() {
        //   location.reload();
        //}
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-md-12">
                <div id="approveList" runat="server">
                    <div id="rptGrid" runat="server" enableviewstate="false"></div>
                    <br />
                    <asp:Button ID="btnApproveAll" runat="server" CssClass='btn btn-primary m-t-25 hidden' Text="Approve Selected" Enabled="false" />
                </div>
            </div>
        </div>
    </div>
    <%--<asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="btn btn-primary" Style="display: none" OnClick="btnSearch_Click" />--%>
    <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary" Style="display: none" OnClick="btnApprove_Click" />
    <asp:Button ID="btnReject" runat="server" CssClass='btn btn-primary m-t-25' OnClick="btnReject_Click" Style="display: none" />
    <asp:HiddenField ID="hddTranNo" runat="server" />
    <asp:HiddenField ID="hdntabType" runat="server" />
</asp:Content>