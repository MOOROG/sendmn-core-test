<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeAbsenceCalendar.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.EmployeeAbsenceCalendar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title></title>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/js/swift_calendar.js" type="text/javascript"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
  <script src="/Scripts/moment.js"></script>
  <script src="/Scripts/fullcalendar.min.js"></script>
  <script src="/Scripts/fullcalendar.helper.min.js"></script>
  <link href="/Content/fullcalendar.min.css" rel="stylesheet" />
  <script type="text/javascript">
    $(document).ready(function () {
      $('#calendar').fullCalendar({
        header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,agendaWeek,agendaDay'
        },
        defaultDate: moment().format("YYYY-MM-DD"),
        defaultView: 'month',
        editable: true,
        events: function (start, end, timezone, callback) {
          var dsts = $('#<% =calendarTxt.ClientID%>').val();
          $.ajax({
            type: "POST",
            url: "../../../Autocomplete.asmx/GetAbsenceList",
            data: '{ month: "' + dsts+'"}',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data, textStatus, XMLHttpRequest) {
              var myData = JSON.parse(data.d);
              var events = [];
              $.each(myData, function (i, data) {
                events.push({
                    title: 'Ажилтны нэр : ' + data.uid,
                    description: data.title,
                    start: moment(data.start).format('YYYY-MM-DD'),
                    end: moment(data.end).format('YYYY-MM-DD'),
                    backgroundColor: data.absColor//"#9501fc"
                  });
              });

              callback(events);
              //          alert('Updated row' + myData.length);
            },
            error: function (xhr, ajaxOptions, thrownError) {
              console.log("Status: " + xhr.status + " Error: " + thrownError);
              alert("Due to unexpected errors we were unable to load data");
            }
          });
        },
        eventRender: function (event, element) {
          element.attr('href', 'javascript:void(0);');
          element.click(function () {
            alert(event.description);
          });
        }
        , height: 650});
    });

    function refetch() {
      $('#calendar').fullCalendar('refetchEvents');
    }
  </script>

</head>
<body>
  <form id="form1" runat="server">
    <div class="col-md-8">
    <asp:TextBox ID="calendarTxt" runat="server" placeholder="yyyy/MM/dd" TextMode="Date" ReadOnly="false"></asp:TextBox>
    <button id="refetch" onclick="refetch()">Reload</button>
    <div id='calendar'>
    </div>
    </div>
  </form>
</body>
</html>
