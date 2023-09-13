<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="EmployeeAbsence.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.EmployeeAbsence" %>

<!DOCTYPE html>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/js/swift_autocomplete.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/pickers-init.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript">
    $(document).ready(function () {
    });
    function goBack() {
      history.back();
    }
  </script>
</head>
<body>
  <form id="form1" runat="server" class="col-md" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="up" runat="server">
      <ContentTemplate>
        <div class="page-wrapper">

          <div class="row">
            <div class="col-sm-12">
              <div class="page-title">
                <ol class="breadcrumb">
                  <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                  <li><a onclick="return LoadModule('adminstration')">Administration</a></li>
                  <li class="active"><a href="#">Employee Absence</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="report-tab">
              <div role="tabpanel" class="tab-pane" id="menu1">
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Absence information</h4>
                      </div>
                      <div class="panel-body">
                        <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                          <Triggers>
                            <asp:PostBackTrigger ControlID="btnAnnouncement" />
                          </Triggers>
                          <ContentTemplate>
                            <div class="row">
                              <div class="col-md-12 col-xs-12 form-group">
                                <label class="control-label" for="announcementContent" id="announcementContentLabel">Шалтгаан:<span style="color: red;">*</span></label>
                                <asp:TextBox ID="announcementContent" runat="server" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="annContentValidator" runat="server" ControlToValidate="announcementContent" ErrorMessage="Content is required!" ForeColor="Red"></asp:RequiredFieldValidator>
                              </div>
                              <div class="col-md-6 col-xs-12 form-group">
                                <label class="control-label" for="announcementDateFrom" id="announcementDateFromLabel">Start Date:<span style="color: red;">*</span></label>
                                <asp:TextBox ID="announcementDateFrom" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="annDateFromValidator" runat="server" ControlToValidate="announcementDateFrom" ErrorMessage="Start date is required!" ForeColor="Red"></asp:RequiredFieldValidator>
                              </div>
                              <div class="col-md-6 col-xs-12 form-group">
                                <label class="control-label" for="announcementDateTo" id="announcementDateToLabel">End Date:<span style="color: red;">*</span></label>
                                <asp:TextBox ID="announcementDateTo" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="annDateToValidator" runat="server" ControlToValidate="announcementDateTo" ErrorMessage="End date is required!" ForeColor="Red"></asp:RequiredFieldValidator>
                              </div>
                              <div class="col-md-6 col-xs-12 form-group hidden">
                                <label class="control-label" for="announcementId">Id:</label>
                                <asp:TextBox ID="announcementId" runat="server" CssClass="form-control"></asp:TextBox>
                              </div>
                              <div class="col-md-2 col-xs-12 form-group">
                                <asp:RadioButton ID="rbtnWithoutSal" runat="server" GroupName="approveBtn" Text="Approve" Visible="false" />
                                <asp:RadioButton ID="rbtnWithSalary" runat="server" GroupName="approveBtn" Text="Approve with salary" Visible="false" />
                              </div>
                            </div>
                            <div class="row">
                              <div class="col-lg-6 form-group">
                                <asp:Button ID="btnAnnouncement" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" CausesValidation="False" OnClick="btnAnnouncement_Click" />
                                <input type="button" value="Back" class="btn btn-primary m-t-25" onclick="goBack()" />
                              </div>
                            </div>
                          </ContentTemplate>
                        </asp:UpdatePanel>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
          </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>
  </form>
</body>
</html>
