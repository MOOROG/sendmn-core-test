<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.CommonCode.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <base id="Base1" runat="server" target="_self" />
  <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../../../js/functions.js" type="text/javascript"> </script>
  <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>

<body>

  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
              <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
              <li class="active"><a href="List.aspx">Common Code</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="listtabs">
        <ul class="nav nav-tabs" role="tablist">
          <li role="presentation" class="active"><a href="#" class="selected" aria-controls="home" role="tab" data-toggle="tab">Common Code Type List </a></li>
        </ul>
      </div>
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default ">
                <div class="panel-body">
                  <div class="panel-heading">
                    <h4 class="panel-title">Common Code Type List
                    </h4>
                    <div class="panel-actions">
                      <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                    </div>
                  </div>

                  <div class="table-responsive">
                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
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
