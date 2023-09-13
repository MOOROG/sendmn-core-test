<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MonpepSearch.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.MonpepSearch" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title></title>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/js/swift_calendar.js" type="text/javascript"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
  <style>
    .table .table {
      background-color: #F5F5F5 !important;
    }
  </style>
  <script type="text/javascript">

    $(document).ready(function () {
      var tabName = $("[id*=hdnCurrentTab]").val() != "" ? $("[id*=hdnCurrentTab]").val() : "menu";
      $('#MainDiv a[href="#' + tabName + '"]').tab('show');

      $('ul.mineLi li').click(function (e) {
        $("[id*=hdnCurrentTab]").val($("a", this).attr('href').replace("#", ""));
        if ($("[id*=hdnCurrentTab]").val() == 'menu') {
          $('#menu1').removeClass('active');
          $('#menu').addClass('active');
        } else {
          $('#menu').removeClass('active');
          $('#menu1').addClass('active');
        }
      });

    });

    //$("#MainDiv a").click(function () {
    //  $("[id*=hdnCurrentTab]").val($(this).attr("href").replace("#", ""));
    //});

    function getMonpepData() {
      $.ajax({
        type: "POST",
        url: "../../../Autocomplete.asmx/MonpepDataSearch",
        data: '{ userName: "' + $('#<%=nameSearch.ClientID%>').val() + '"}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data, textStatus, XMLHttpRequest) {
          alert(data);
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
  <form id="form1" runat="server">
    <asp:HiddenField ID="hdnCurrentTab" runat="server" Value="menu" />
        <div class="page-wrapper">
          <div class="row">
            <div class="col-sm-12">
              <div class="page-title">
                <h1></h1>
                <ol class="breadcrumb">
                  <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                  <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                </ol>
              </div>
            </div>
          </div>

          <div class="report-tab" id="MainDiv" runat="server">
            <div class="listtabs">
              <ul class="nav nav-tabs mineLi" role="tablist" id="myTab">
                <li><a data-toggle="tab" href="#menu" aria-controls="menu" role="tab">Monpep Search</a></li>
                <li><a data-toggle="tab" href="#menu1" aria-controls="menu1" role="tab">From Mandakhaa</a></li>
              </ul>
            </div>
          </div>

          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default ">
                <div class="panel-heading">
                  <h4 class="panel-title">List</h4>
                </div>
                <div class="panel-body">
                  <label>Хайх нэр</label>
                  <input type="text" id="nameSearch" runat="server" />
                  <asp:Button ID="searchBtn" runat="server" Text="Search" OnClick="searchBtn_Click" />
                </div>
              </div>
            </div>
          </div>

          <div class="tab-content">
            <div role="tabpanel" class="tab-pane active" id="menu">
              <div class="row">
                <div class="col-md-12">
                  <asp:GridView ID="monpepGrid" runat="server" AutoGenerateColumns="false" Width="100%">
                    <Columns>
                      <asp:BoundField DataField="sourceUrl" HeaderText="&nbsp;sourceUrl&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="birthPlace" HeaderText="&nbsp;&nbsp;birthPlace&nbsp;&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="gender" HeaderText="&nbsp;gender&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="name" HeaderText="&nbsp;&nbsp;name&nbsp;&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="position" HeaderText="&nbsp;&nbsp;position&nbsp;&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="birthDate" HeaderText="&nbsp;&nbsp;birthDate&nbsp;&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
            <div role="tabpanel" class="tab-pane" id="menu1">
              <div class="row">
                <div class="col-md-12">
                  <asp:GridView ID="mandakhGrid" runat="server" AutoGenerateColumns="false" Width="100%">
                    <Columns>
                      <asp:BoundField DataField="name" HeaderText="&nbsp;name&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="nameorg" HeaderText="&nbsp;N Original&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="title" HeaderText="&nbsp;Title&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="designation" HeaderText="&nbsp;Designation&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="dob" HeaderText="&nbsp;DOB&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="pob" HeaderText="&nbsp;POB&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="gquality" HeaderText="&nbsp;GoodQuality&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="lquality" HeaderText="&nbsp;LowQuality&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="nationality" HeaderText="&nbsp;Nationality&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="passportNo" HeaderText="&nbsp;PassportNo&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="nationalId" HeaderText="&nbsp;NationalID&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="address" HeaderText="&nbsp;Address&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="listedOn" HeaderText="&nbsp;Listed Date&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                      <asp:BoundField DataField="others" HeaderText="&nbsp;Other Info.&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    </Columns>
                  </asp:GridView>
                </div>
              </div>
            </div>
          </div>
        </div>
  </form>
</body>
</html>
