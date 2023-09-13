<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.AgentRating.Manage"
    MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript">

        function LoadCalendars() {
          <%--  ShowCalDefault("#<% =fromDate.ClientID%>");
            ShowCalDefault("#<% =toDate.ClientID%>");--%>
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();

        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }
        function RedirectToIframe(url) {
            window.open(url, "_self");
        }

        function CheckSpecialCharacter(nField, fieldName) {
            var userInput = nField.value;
            if (userInput == "" || userInput == undefined) {
                return;
            }

            if (/^[a-zA-Z0-9- .,/\\()]*$/.test(userInput) == false) {
                alert('Special Character(e.g. !@#$%^&*) are not allowed in field : ' + fieldName);
                setTimeout(function () { nField.focus(); }, 1);
            }
        }

        function confirmMsg() {
            var isRatingCompleted = $("#ddlRatingCompleted").val();
            if (isRatingCompleted == "Y") {
                var ratingBy = $("#ddlRatingBy").val();
                if (ratingBy == "") {
                    alert('Rating by is required field. Please select from the dropdown list.');
                    return false;
                }

            }
            return confirm("Have you done your rating correctly? Please confirm.");
        }

        function OnRatingBySelected(value) {
            $("#ddlRatingBy").val(value);
        }

        function openPrint(url) {
            OpenInNewWindow(url);
        }

        $(document).ready(function () {
            var disabledControls = $("select:disabled, textarea:disabled");
            disabledControls.removeAttr('disabled');
            disabledControls.addClass("is-disabled");
            disabledControls.focus(function () {
                this.blur();
            });
        });
        function IsCompletedOnChage(isCompleted) {
            if (isCompleted == 'Y') {
                document.getElementById("trRatingBy").style.display = '';
            }
            else {
                document.getElementById("trRatingBy").style.display = 'none';
            }
        }
    </script>
    <style type="text/css">
        .is-disabled {
            background-color: #EBEBEB;
            color: black !important;
        }

        .tdContent {
            text-align: left;
            white-space: -moz-pre-wrap;
            white-space: -hp-pre-wrap;
            white-space: -o-pre-wrap;
            white-space: -pre-wrap;
            white-space: pre-wrap;
            white-space: pre-line;
            /*word-wrap: break-word;
            word-break: break-all;*/
        }

        .tdSubCatIndex {
            text-align: center;
            width: 10px !important;
            font-weight: bold;
        }

        .tdddl {
            width: 100px !important;
        }

        .ddl {
            width: 95%;
        }

        .RemarksTextBox {
            word-wrap: break-word;
            width: 90%;
        }

        .TBL td {
            white-space: normal !important;
        }

        .low {
            color: Green;
        }

        .high {
            color: Red;
        }

        .medium {
            color: #5d8aa8;
        }
        /*
        input[disabled="disabled"], select[disabled="disabled"], textarea[disabled="disabled"]
        {
	        background:#EAEAEA;
	        color: #000000 !important;
        }*/
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Agent Rating</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('sub_account')">Manage </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="agentList.aspx">Agent List</a></li>
                        <li><a href="List.aspx">Branch List </a></li>
                        <li class="active"><a href="Manage.aspx">Manage</a></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="Manage">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Add Agent
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="row" id="trNew" runat="server">
                                            <div class="col-md-12 form-group">
                                                <label class="control-label">Add New Agent Rating</label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label">
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Agent:<span class="errormsg">*</span>
                                                    <span runat="server" id="r1" visible="false" class="errMsg"
                                                        style="color: Red;">Required!</span>
                                                </label>
                                                <uc1:SwiftTextBox ID="agent" runat="server" Category="remit-agentRatingList" Width="200px"></uc1:SwiftTextBox>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Agent Type:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rqAgentType" runat="server" ControlToValidate="agentType"
                                                        ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:DropDownList ID="agentType" runat="server" class="dateField form-control">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    From Date:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rqfromDate" runat="server" ControlToValidate="fromDate"
                                                        ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:TextBox autocomplete="off" ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" class="dateField form-control" size="12"></asp:TextBox>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    To Date:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rqtoDate" runat="server" ControlToValidate="toDate"
                                                        ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:TextBox autocomplete="off" ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" class="dateField form-control" size="12"></asp:TextBox>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <asp:Button ID="btnSaveAgent" runat="server" Text="Save" CssClass="btn btn-primary" ValidationGroup="agent"
                                                    Width="100px" OnClick="btnSaveAgent_Click" />
                                            </div>
                                        </div>
                                        <div class="row" id="trratingDetails" runat="server">
                                            <div class="col-md-6 form-group">
                                                <label class="control-label">Agent Rating</label>
                                            </div>
                                            <div class="col-md-6 form-group" style="text-align: right !important;">
                                                <img src="../../Images/print16.png" id="printBtn" runat="server" alt="Print" style="cursor: pointer;" />
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Agent:
                                                </label>
                                                <asp:Label ID="AgentName" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Branch:
                                                </label>
                                                <asp:Label ID="BranchName" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Review Period:
                                                </label>
                                                <asp:Label ID="ReviewPeriod" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Rated By:
                                                </label>
                                                <asp:Label ID="ratedby" runat="server" Text=""></asp:Label>&nbsp;<asp:Label ID="ratedOn" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Reviewed By:
                                                </label>
                                                <asp:Label ID="Reviewer" runat="server" Text=""></asp:Label>&nbsp;<asp:Label ID="Reviewedon" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">
                                                    Branch:
                                                </label>
                                                <asp:Label ID="approvedBy" runat="server" Text=""></asp:Label>&nbsp;<asp:Label ID="approvedOn" runat="server" Text=""></asp:Label>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <div id="divSummary" runat="server" style="width: 300px; float: right;">
                                                </div>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <div style="color: Green;">
                                                    &nbsp;<b>0.01 - 1.00 LOW</b>
                                                </div>
                                                <div style="color: #5d8aa8;">
                                                    &nbsp;<b>1.001 - 3.00 MEDIUM</b>
                                                </div>
                                                <div style="color: Red;">
                                                    &nbsp;<b>3.001 - 5.00 HIGH</b>
                                                </div>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <label class="control-label" for="">Agent Rating</label>
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td>
                                                            <asp:HiddenField ID="hdnRowsCount" runat="server" />
                                                            <asp:HiddenField ID="hdnscoringCriteria" runat="server" />
                                                            <asp:Table ID="myData" runat="server" Style="width: 100%;">
                                                            </asp:Table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div class="col-md-12 form-group" id="trWarning" runat="server">
                                                <label class="control-label" for="">
                                                    &nbsp;Select YES only if you have completed your rating, Once you select YES and
                                                Save, then you will no more able to edit rating.</label>
                                            </div>
                                            <div class="col-md-12 form-group" id="trRatingCompleted" runat="server">
                                                <label class="control-label" for="">Is Rating Completed ? &nbsp;</label>
                                                <asp:DropDownList ID="ddlRatingCompleted" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlRatingCompleted_SelectedIndexChanged">
                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                    <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-12 form-group" id="trRatingBy" runat="server">
                                                <label class="control-label" for="">Rating By &nbsp;</label>
                                                <asp:DropDownList ID="ddlRatingBy" CssClass="form-control" runat="server" onchange="OnRatingBySelected(this.value);">
                                                </asp:DropDownList>
                                            </div>
                                            <%--  <tr id="trRatingComment" runat="server">
                                                    <td style="padding-left: 25px;">
                                                        <b>Agent's Comment</b>
                                                    </td>
                                                    <td style="padding-left: 73px;">
                                                        <asp:TextBox ID="ratingComment" runat="server" TextMode="MultiLine" Width="515px" ForeColor="Black"
                                                            CssClass="required"></asp:TextBox>
                                                    </td>
                                                </tr>--%>
                                            <%--<tr id="trRatersDetails" runat="server">
                                                    <td colspan="2" style="padding-left: 25px;">
                                                        <div id="ratingDetails" runat="server">
                                                        </div>
                                                    </td>
                                                </tr>--%>
                                            <div class="col-md-12 form-group" id="trReviewercomment" runat="server">
                                                <label class="control-label" for="">Reviewer's Comment</label>
                                                <asp:TextBox ID="reviewersComment" runat="server" TextMode="MultiLine" Width="515px"
                                                    CssClass="required form-control"></asp:TextBox>
                                            </div>
                                            <%--<tr id="trReviewerdetails" runat="server">
                                                <td colspan="2" style="padding-left:25px;">
                                                    <div id="reviewDetails" runat="server">
                                                    </div>
                                                </td>
                                            </tr>--%>
                                            <div class="col-md-12 form-group" id="trApproverComment" runat="server">
                                                <label class="control-label" for="">Approver's Comment</label>
                                                <asp:TextBox ID="approversComment" runat="server" TextMode="MultiLine" Width="515px"
                                                    CssClass="required form-control"></asp:TextBox>
                                            </div>
                                            <%-- <tr id="trApproverdetails" runat="server">
                                                <td colspan="2" style="padding-left:25px;">
                                                    <div id="approveDetails" runat="server">
                                                    </div>
                                                </td>
                                            </tr>--%>
                                            <div class="col-md-12 form-group" id="Div1" runat="server">
                                                <asp:Button ID="btnAgentRating" runat="server" Text="Save Rating" CssClass="btn btn-primary"
                                                    OnClientClick="return confirmMsg();" OnClick="btnAgentRating_Click" />
                                                <asp:Button ID="btnReview" runat="server" Text="Save Review" CssClass="button" OnClick="btnReview_Click" />
                                                <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="button" OnClick="btnApprove_Click" />
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <asp:Timer ID="Timer1" runat="server" Interval="100000" OnTick="Timer1_Tick">
                </asp:Timer>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>