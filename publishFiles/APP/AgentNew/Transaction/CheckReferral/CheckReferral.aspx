<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="CheckReferral.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.CheckReferral.CheckReferral" %>

<%@ Import Namespace="Swift.web.Library" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript" language="javascript">
  
        function ValidationCheck() {
            var controlNo = $("#<%=controlNo.ClientID%>").val();
            var tranNo = $("#<%=tranId.ClientID%>").val();
            var reqField = "<%=controlNo.ClientID%>,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }


            var url = '/RemittanceSystem/RemittanceReports/Reports.aspx?&reportName=checkReferal&controlNo=' + controlNo
                + '&tranNo=' + tranNo;
            OpenInNewWindow(url);
        }
     
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="/Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                        <li class="active"><a href="CheckReferral.aspx">Check Referral</a></li>
                    </ol>
                </div>
            </div>
        </div>


        <div class="row">
            <div id="divSearch" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">Check Referral</div>
                    <div class="panel-body">
                        <div class="col-md-8">
                           
                            <div class="form-group">
                                <div class="col-md-2">
                                    <label class="control-label">
                                        <span align="right" class="formLabel"><%=GetStatic.GetTranNoName() %>.:</span>
                                    </label>
                                </div>
                                <div class="col-md-5">
                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group" style="display:none">
                                <div class="col-md-2">
                                    <label class="control-label">
                                        Tran No:
                                    </label>
                                </div>
                                <div class="col-md-5">
                                    <asp:TextBox ID="tranId" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-offset-2 col-md-2">
                                    <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary" OnClientClick="return ValidationCheck();"  />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <asp:HiddenField ID="hdnControlNo" runat="server" />
                <asp:HiddenField ID="hdnHoldTranId" runat="server" />
            </div>

    
        </div>
    
    </div>
</asp:Content>
