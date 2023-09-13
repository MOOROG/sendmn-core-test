<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.CommonCode.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"> </script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
              <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
              <li class="active"><a href="List.aspx">Common Code</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="listtabs">
        <ul class="nav nav-tabs" role="tablist">
          <li role="presentation"><a href="List.aspx" class="selected" aria-controls="home" role="tab" data-toggle="tab">Common Code Type List </a></li>
          <li role="presentation" class="active"><a href="#" class="selected" aria-controls="home" role="tab" data-toggle="tab">Manage Common Code Value </a></li>
        </ul>
      </div>
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-6">
              <div class="panel panel-default ">
                <div class="panel-heading">
                  <h4 class="panel-title">Common Code Details
                  </h4>
                  <div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                  </div>
                </div>
                <div class="panel-body">
                  <div class="form-group">
                    <label class="control-label" for="">
                      <span class="ErrMsg">*</span> Fileds are mendotory and use the own idea to input this for</label>
                  </div>
                  <div class="form-group">
                    <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-3 col-md-4 control-label" for="">
                      Code:<span class="errormsg">*</span>
                    </label>
                    <div class="col-lg-9 col-md-8">
                      <asp:TextBox ID="occupCode" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-3 col-md-4 control-label" for="">
                      Нэр (монгол): <span class="errormsg">*</span>
                    </label>
                    <div class="col-lg-9 col-md-8">
                      <asp:TextBox ID="nameMongolian" CssClass="form-control" runat="server"></asp:TextBox>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-3 col-md-4 control-label" for="">
                      Нэр (англи): <span class="errormsg">*</span>
                    </label>
                    <div class="col-lg-9 col-md-8">
                      <asp:TextBox ID="nameEnglish" CssClass="form-control" runat="server"></asp:TextBox>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-3 col-md-4 control-label" for="">
                      Оноо: <span class="errormsg">*</span>
                    </label>
                    <div class="col-lg-9 col-md-8">
                      <asp:TextBox ID="evalPoint" CssClass="form-control" runat="server"></asp:TextBox>
                    </div>
                  </div>
                  <div class="form-group">
                    <div class="col-md-8 col-md-offset-3">
                      <asp:Button ID="btnSubmit" runat="server" Text="Submit" class="btn btn-primary m-t-25" OnClick="btnSubmit_Click" />
                      &nbsp;
                            <%--<asp:Button ID="btnDelete" runat="server" Text="Delete" class="btn btn-primary m-t-25" OnClick="btnDelete_Click" />--%>
                      <input type="button" id="btnBack" value=" Back " class="btn btn-primary m-t-25" onclick="Javascript: history.back(); " />
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
