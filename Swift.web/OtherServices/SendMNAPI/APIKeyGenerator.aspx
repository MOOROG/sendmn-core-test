<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="APIKeyGenerator.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.APITokenGenerator" EnableViewState="true" %>

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
  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script type="text/javascript" src="/ui/js/jquery-ui.min.js"></script>
  <script type="text/javascript" src="/js/swift_autocomplete.js"></script>
  <script type="text/javascript" src="/js/swift_calendar.js"></script>
  <script type="text/javascript" src="/ui/js/pickers-init.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript">
    $(document).ready(function () {
      ShowCalDefault("#contractExpiryDate");
      ShowCalDefault("#renewalFollowupDate");
    });

    $(document).ready(function () {
      $('.collMode-chk').click(function () {
        $('.collMode-chk').not(this).propAttr('checked', false);
      });
    });

    function cnrtyDdl(ddl) {
      var selectedValue = $('#<%=countryDdl.ClientID%>').val();
      $.ajax({
        type: "POST",
        url: "../../../Autocomplete.asmx/GetNotice",
        data: '{ cntryId: "' + $('#<%=countryDdl.ClientID%>').val() + '"}',
          contentType: "application/json; charset=utf-8",
          dataType: "json",
          success: function (data, textStatus, XMLHttpRequest) {
            $('#<%=noticeArea.ClientID%>').val(data.d);
            $('#<%=countryDdl.ClientID%>').val(selectedValue);
            alert($('#<%=countryDdl.ClientID%>').val());
          },
          error: function (xhr, ajaxOptions, thrownError) {
            console.log("Status: " + xhr.status + " Error: " + thrownError);
            alert("Due to unexpected errors we were unable to load data");
          }
        });
    }

    function agentDdl(ddl) {
      var selectedValue = $('#<%=agentName.ClientID%>').val();
      var selText = $('#agentName option:selected').text();
      $('#<%=agentCode.ClientID%>').val(selectedValue);
      $.ajax({
        type: "POST",
        url: "../../../Autocomplete.asmx/keyGenerator",
        data: '{ name: "' + selText + '", code: "' + selectedValue + '"}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data, textStatus, XMLHttpRequest) {
          $('#<%=apiKey.ClientID%>').val(data.d);
        },
        error: function (xhr, ajaxOptions, thrownError) {
          console.log("Status: " + xhr.status + " Error: " + thrownError);
          alert("Due to unexpected errors we were unable to load data");
        }
      });
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
                  <li class="active"><a href="#">API Key Generator</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="report-tab">
            <div class="listtabs">
              <ul class="nav nav-tabs" role="tablist" id="myTab">
                <li id="gens" runat="server" class="active"><a data-toggle="tab" href="#menu">Generators</a></li>
                <li id="othr" runat="server"><a data-toggle="tab" href="#menu1">Others</a></li>
              </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">

              <div role="tabpanel" class="tab-pane active" id="menu">
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">API Key Generator</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentName">
                              Agent Name:<span style="color: red;">*</span>
                            </label>
                            <asp:DropDownList ID="agentName" runat="server" CssClass="form-control" onchange="agentDdl(this);">
                              <asp:ListItem Enabled="true" Text="Select Agent" Value="-1" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                          </div>
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentCode">
                              Agent Code:<span style="color: red;">*</span>
                            </label>
                            <asp:TextBox ID="agentCode" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                          </div>
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="apiKey">
                              API Key:
                            </label>
                            <asp:TextBox ID="apiKey" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Whitelist agent IP</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentNameIP">
                              Agent Name:<span style="color: red;">*</span>
                            </label>
                            <asp:DropDownList ID="agentNameIP" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="onAgentSelectIP">
                              <asp:ListItem Enabled="true" Text="Select Agent" Value="-1" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                          </div>
                          <div class="col-md-6 form-group">
                            <label class="control-label" for="whitelistedIPs">
                              Whitelisted IP(s):
                            </label>
                            <asp:TextBox ID="whitelistedIPs" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-lg-12 form-group">
                            <asp:Button ID="saveWhitelistedIPs" runat="server" Text="Save" CssClass="btn btn-primary m-t-25"
                              OnClick="btnSaveWhitelistedIPs_Click" CausesValidation="False" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Signature Generator</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-md-6 form-group">
                            <label class="control-label" for="requestValues">
                              Values:<span style="color: red;">*</span>
                            </label>
                            <asp:TextBox ID="requestValues" runat="server" CssClass="form-control" TextMode="MultiLine" Height="200"></asp:TextBox>
                          </div>
                          <div class="col-md-6 form-group">
                            <label class="control-label" for="signature">
                              Signature:
                            </label>
                            <asp:TextBox ID="signature" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-lg-12 form-group">
                            <asp:Button ID="btnSignature" runat="server" Text="Generate Signature" CssClass="btn btn-primary m-t-25"
                              OnClick="btnSignature_Click" CausesValidation="False" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Bank switch</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentName">Khaan bank:</label>
                            <asp:CheckBox ID="khanBankChkbx" runat="server" CssClass="form-control">
                            </asp:CheckBox>
                          </div>
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentName">Golomt bank:</label>
                            <asp:CheckBox ID="glmtBankChkbx" runat="server" CssClass="form-control">
                            </asp:CheckBox>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-lg-12 form-group">
                            <asp:Button ID="bankSwitchBtn" runat="server" Text="Save" CssClass="btn btn-primary m-t-25"
                              OnClick="bankSwitchBtn_Click" CausesValidation="False" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">ХУР verification</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentName">Finger print:</label>
                            <asp:FileUpload ID="fingerPrintImage" runat="server" CssClass="form-control" accept="image/*" name="fingerPrintImage" />
                          </div>
                          <div class="col-lg-3 col-md-6 form-group">
                            <label class="control-label" for="agentName">Information:</label>
                            <asp:TextBox ID="txtInfo" TextMode="MultiLine" runat="server" CssClass="form-control"></asp:TextBox>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-lg-12 form-group">
                            <asp:Button ID="hurCheckBtn" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" OnClick="hurCheckBtn_Click" CausesValidation="False" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div role="tabpanel" class="tab-pane" id="menu1">
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Announcement</h4>
                      </div>
                      <div class="panel-body">
                        <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                          <Triggers>
                            <asp:PostBackTrigger ControlID="btnAnnouncement" />
                          </Triggers>
                          <ContentTemplate>
                            <div class="row">
                              <div class="col-md-6 col-xs-12 form-group">
                                <label class="control-label" for="announcementTitle" id="announcementTitleLabel">Title:<span style="color: red;">*</span></label>
                                <asp:TextBox ID="announcementTitle" runat="server" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="annTitleValidator" runat="server" ControlToValidate="announcementTitle" ErrorMessage="Title is required!" ForeColor="Red"></asp:RequiredFieldValidator>
                              </div>
                              <div class="col-md-6 col-xs-12 form-group">
                                <label class="control-label" for="announcementContent" id="announcementContentLabel">Content:<span style="color: red;">*</span></label>
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
                            </div>
                            <div class="row">
                              <div class="col-lg-12 form-group">
                                <asp:Button ID="btnAnnouncement" runat="server" Text="Save & Send Announcement" CssClass="btn btn-primary m-t-25"
                                  OnClick="btnAnnouncement_Click" CausesValidation="False" />
                              </div>
                            </div>
                          </ContentTemplate>
                        </asp:UpdatePanel>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">Banner</h4>
                      </div>
                      <div class="panel-body">
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <Triggers>
                              <asp:PostBackTrigger ControlID="btnBanner" />
						    </Triggers>	    
                            <ContentTemplate>
                            <div class="row">
                              <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                <label class="control-label" for="bannerLabel" id="bannerLabelLabel">Label (заавал биш):</label>
                                <asp:TextBox ID="bannerLabel" runat="server" CssClass="form-control"></asp:TextBox>
                              </div>
                              <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                <label class="control-label" for="bannerLink" id="bannerLinkLabel">Link (заавал биш):</label>
                                <asp:TextBox ID="bannerLink" runat="server" CssClass="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="row" id="adsId">
                              <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                <label class="control-label" for="adsPhoto">Photo:</label>
                                <asp:FileUpload ID="adsPhoto" runat="server" CssClass="form-control" accept="image/*" name="adsPhto" />
                              </div>
                            </div>
                            <div class="row">
                              <div class="col-lg-12 form-group">
                                <asp:Button ID="btnBanner" runat="server" Text="Add Banner" CssClass="btn btn-primary m-t-25"
                                  OnClick="btnBanner_Click" CausesValidation="False" />
                              </div>
                            </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <div class="row">
                        <div class="col-md-8 col-sm-12">
                          <table class="table table-hover">
                              <thead><tr><th style="width: 1%">Image</th><th style="width: 1%">Label</th><th style="width: 1%">Link</th><th style="width: 1%">Delete</th></tr></thead>
                              <tbody>
                              <% foreach (var banner in banners) { %>
                                 <tr><td><img src="<%= banner[3] %>" class="img-responsive" width="300" /></td><td><%= banner[1] %></td><td><a href="<%= banner[2] %>"><%= banner[2] %></a></td><td><a href="?deleteBannerId=<%= banner[0] %>" class="btn btn-danger"><i class="fa fa-times"> </i>Устгaх</a></td></tr>
                              <% } %>
                              </tbody>
                            </table>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                      <div class="panel-heading">
                        <h4 class="panel-title">NoticeTxt</h4>
                      </div>
                      <div class="panel-body">
                        <div class="row">
                          <div class="col-md-3 col-xs-12 form-group">
                            <label class="control-label" for="country">
                              Country:<span style="color: red;">*</span>
                            </label>
                            <asp:DropDownList ID="countryDdl" runat="server" CssClass="form-control" onchange="cnrtyDdl(this);">
                              <asp:ListItem Enabled="true" Text="Select Country" Value="-1" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                          </div>
                          <div class="col-md-9 col-xs-12 form-group">
                            <label class="control-label" for="announcementContent">Content:<span style="color: red;">*</span></label>
                            <asp:TextBox ID="noticeArea" runat="server" CssClass="form-control" TextMode="MultiLine" Height="150px" style="resize: none;"></asp:TextBox>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-lg-12 form-group">
                            <asp:Button ID="btnSaveNotice" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" OnClick="btnSaveNotice_Click" CausesValidation="False" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">PUBLIC SEND NOTIFICATION MOBILE</h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                    <label class="control-label" id="TitleLabel">Notification title:</label>
                                    <asp:TextBox ID="NotifTitle" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                    <label class="control-label" for="bannerLink" id="DescriptionLabel">Notification Text:</label>
                                    <asp:TextBox ID="NotifDesc" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                        </div>
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
