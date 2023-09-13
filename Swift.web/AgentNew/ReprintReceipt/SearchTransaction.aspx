<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="SearchTransaction.aspx.cs" Inherits="Swift.web.AgentNew.ReprintReceipt.SearchTransaction" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnSearch').click(function () {
                var reqField = "controlNo,";
                if (ValidRequiredField(reqField) == false) {
                    return false;
                };
                var controlNo = $('#controlNo').val();
                var url = "SendTntlReceipt.aspx?controlNo=" + controlNo;
                window.location.href = url;
                return false;
            });
        });
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
                        <li><a href="#">Other Services</a></li>
                        <li class="active"><a href="SearchTransaction.aspx">Reprint Receipt</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div id="divSearch" class="col-md-7" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">Search Transaction</div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-2 form-group">
                                <label><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> No.<span style="color: red;">*</span></label>
                            </div>
                            <div class="col-md-4 form-group">
                                <input type="text" class="form-control" id="controlNo" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 form-group col-md-offset-2">
                                <input type="button" id="btnSearch" value="View Receipt" class="btn btn-primary m-t-25" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>