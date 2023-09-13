<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="ModifyTran.aspx.cs" Inherits="Swift.web.AgentNew.Modify.ModifyTran" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Src="~/Remit/UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <script type="text/javascript" language="javascript">
    $(document).ready(function () {
      ShowCalFromToUpToToday("#<% =startDate.ClientID%>");
      ShowCalFromToUpToToday("#<% =toDate.ClientID%>");
    });
  </script>
  <script type="text/javascript">
    function EditData(label, fieldName, oldValue, tranId) {
      var url = "ModifyField.aspx?label=" + label +
        "&fieldName=" + fieldName +
        "&oldValue=" + oldValue +
        "&tranId=" + tranId;

      var id = PopUpWindow(url, "");
      if (id == "undefined" || id == null || id == "") {
      }
      else {
        GetElement("<%=btnReloadDetail.ClientID %>").click();
      }
      return false;
    }

    function EditPayoutLocation(label, fieldName, oldValue, tranId) {
      var url = "Modify.aspx?label=" + label +
        "&fieldName=" + fieldName +
        "&oldValue=" + oldValue +
        "&tranId=" + tranId;

      var id = PopUpWindow(url, "");
      if (id == "undefined" || id == null || id == "") {
      }
      else {
        GetElement("<%=btnReloadDetail.ClientID %>").click();
      }
      return false;
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
            <li><a href="/Agent/AgentMain.aspx" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
            <li class="active"><a href="ModifyTran.aspx">Search Transaction</a></li>
          </ol>
        </div>
      </div>
    </div>


    <div class="row">
      <div id="divSearch" runat="server">
        <div class="panel panel-default">
          <div class="panel-heading">Search Transaction For Modification & View</div>
          <div class="panel-body">
            <div class="col-md-8">              
              <div class="form-group">
                <label class="col-lg-2 col-md-2 control-label" for="">
                  From Date: 
                </label>
                <div class="col-lg-4 col-md-4">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="startDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
                <label class="col-lg-2 col-md-2 control-label" for="">
                  To Date: 
                </label>
                <div class="col-lg-4 col-md-4">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-md-2">
                  <label class="control-label">
                    <span align="right" class="formLabel"><%=GetStatic.GetTranNoName() %>.:</span>
                  </label>
                </div>
                <div class="col-md-4">
                  <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-md-2">
                  <label class="control-label">
                    <span align="right" class="formLabel">Status</span>
                  </label>
                </div>
                <div class="col-md-4">
                  <asp:DropDownList ID="statusDdl" runat="server" CssClass="form-control">
                    <asp:ListItem Text="All" Value="All"></asp:ListItem>
                    <asp:ListItem Text="Paid" Value="Paid"></asp:ListItem>
                    <asp:ListItem Text="Unpaid" Value="Unpaid"></asp:ListItem>
                    <asp:ListItem Text="Uncommit" Value="Uncommit"></asp:ListItem>
                  </asp:DropDownList>
                </div>
              </div>
              <div class="form-group">
                <div class="col-md-offset-2 col-md-2">
                  <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearchDetail_Click" />
                </div>
              </div>
            </div>
          </div>
        </div>
        <asp:HiddenField ID="hdnControlNo" runat="server" />
        <asp:HiddenField ID="hdnHoldTranId" runat="server" />
<%--        <asp:Button ID="btnClick" OnClientClick="ShowQuestionaire()" runat="server" OnClick="btnClick_Click" Style="display: none;" />--%>
        <asp:HiddenField ID="hdnStatus" runat="server" />
      </div>

      <div class="">
        <div id="divLoadGrid" runat="server" visible="false"></div>
      </div>
    </div>
    <div runat="server" id="questionaireDiv1" class="row" style="text-align: right;" visible="false">
      <div class="col-sm-12">
        <a href="test" style="color: red; font-size: 1.2em; font-weight: bold;" data-toggle="modal" data-target="#questionaireModal">Questionnaire Answer</a>
      </div>
    </div>
  </div>
  <asp:Button ID="btnReloadDetail" runat="server" OnClick="btnReloadDetail_Click" Style="display: none;" />
  <div id="divTranDetails" runat="server" visible="false">
    <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
    <%--question section begin--%>
    <div id="questionaireDiv" runat="server" class="row">
      <div class="col-md-12">
        <div class="panel panel-default ">
          <div class="panel-heading">
            <h4 class="panel-title">Transaction Details
            </h4>
            <div class="panel-actions">
              <a href="/test" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
            </div>
          </div>
          <div class="panel-body">
            <div id="rpt_grid" runat="server"></div>
          </div>
        </div>
      </div>
    </div>
    <%--question section end--%>

    <input type="button" id="btnBack" class="btn btn-primary" style="margin-left: 20px;" value="Back" onclick="window.location.replace('ModifyTran.aspx');" />
  </div>

  <!-- Button trigger modal -->

  <!-- Modal -->
  <div class="modal fade" id="questionaireModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h1 style="text-align: center" class="modal-title" id="exampleModalLabel">Questionnaire Answer</h1>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div id="rpt_grid1" runat="server"></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
  </div>
</asp:Content>
