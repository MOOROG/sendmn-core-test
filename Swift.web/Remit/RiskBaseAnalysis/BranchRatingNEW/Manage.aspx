﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.BranchRatingNEW.Manage" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript">

        function LoadCalendars() {
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

        function confirmMsg() {
            return confirm("Have you done your rating correctly? Please confirm.");
        }
        function openPrint(url) {
            OpenInNewWindow(url);
        }

    </script>
    <style type="text/css">
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
                            <li><a href="#" onclick="return LoadModule('remit')">Branch Rating</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('remit_compliance')">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx">List</a></li>
                    <li class="active"><a href="#">Manage </a></li>
                </ul>
            </div>
            <div class="tab-content" id="trNew" runat="server">
                <div role="tabpanel" class="tab-pane active">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Add New Branch Rating
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="control-label" for="">Add Branch</label>
                                    </div>
                                    <div class="form-group">
                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            Branch:<span class="errormsg">*</span>
                                            <span runat="server" id="r1" visible="false" class="errMsg" style="color: Red;">Required!</span>
                                        </label>
                                        <uc1:SwiftTextBox ID="agent" runat="server" Category="remit-branch" Param1="1017" Width="30%"></uc1:SwiftTextBox>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            From Date:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="rqfromDate" runat="server" ControlToValidate="fromDate"
                                                ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox autocomplete="off" ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" class="dateField form-control" Width="30%"
                                            size="12"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            To Date:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="rqtoDate" runat="server" ControlToValidate="toDate"
                                                ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox autocomplete="off" ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" class="dateField form-control" Width="30%"
                                            size="12"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSaveBranch" runat="server" Text="Save" CssClass="button" ValidationGroup="agent" Width="100px"
                                            OnClick="btnSaveBranch_Click" />
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel-body" id="trratingDetails" runat="server">
                <div role="tabpanel" class="tab-pane active">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Add New Branch Rating
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table width="80%" border="0" cellspacing="0" cellpadding="0" class="formTable"
                                            style="margin-left: 30px;">
                                            <tr>
                                                <td colspan="2" style="text-align: right !important;">
                                                    <img src="../../../Images/print16.png" id="printBtn" runat="server" alt="Print" style="cursor: pointer;" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th colspan="2" class="frmTitle">Branch Rating
                                                </th>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div style="width: 400px; float: left;">
                                                        <table style="width: 100%;">
                                                            <tr>
                                                                <td>
                                                                    <b>Branch:</b>
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="Branch" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <b>Review Period:</b>
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="ReviewPeriod" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <b>Rated By:</b> </td>
                                                                <td>
                                                                    <asp:Label ID="ratedby" runat="server" Text=""></asp:Label></td>
                                                                <td>&nbsp;<asp:Label ID="ratedOn" runat="server" Text=""></asp:Label></td>
                                                            </tr>

                                                            <tr>
                                                                <td>
                                                                    <b>Reviewed By:</b>
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="Reviewer" runat="server" Text=""></asp:Label>
                                                                </td>
                                                                <td>&nbsp;<asp:Label ID="Reviewedon" runat="server" Text=""></asp:Label></td>
                                                            </tr>

                                                            <tr>
                                                                <td>
                                                                    <b>Approved By:</b></td>
                                                                <td>
                                                                    <asp:Label ID="approvedBy" runat="server" Text=""></asp:Label></td>
                                                                <td>&nbsp;<asp:Label ID="approvedOn" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>

                                                    <table style="float: right;">
                                                        <tr>
                                                            <td colspan="3">
                                                                <div id="divSummary" runat="server" style="width: 300px; float: right;">
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div style="color: Green;">
                                                                    &nbsp;<b>0-2 LOW</b>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div style="color: #5d8aa8;">
                                                                    &nbsp;<b>2.01-3 MEDIUM</b>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div style="color: Red;">
                                                                    &nbsp;<b>3.01-5 HIGH</b>
                                                                </div>
                                                            </td>

                                                        </tr>

                                                    </table>

                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <fieldset>
                                                        <legend>Branch Rating</legend>
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
                                                    </fieldset>
                                                </td>
                                            </tr>
                                            <tr id="trWarning" runat="server">
                                                <td colspan="2" style="padding-left: 25px; height: 30px;" class="warning">&nbsp;Select YES only if you have completed your rating, Once you select YES and
                        Save, then you will no longer be able to edit rating.
                                                </td>
                                            </tr>
                                            <tr id="trRatingCompleted" runat="server">
                                                <td style="padding-left: 25px; width: 20%">Is Rating Completed ? &nbsp;
                                                </td>
                                                <td style="padding-left: 73px;">
                                                    <asp:DropDownList ID="ddlRatingCompleted" runat="server" AutoPostBack="false" CssClass="form-control" Width="30%"
                                                        OnSelectedIndexChanged="ddlRatingCompleted_SelectedIndexChanged">
                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>

                                            <tr id="trRatingComment" runat="server">
                                                <td style="padding-left: 25px;">Branch Rating Comment
                                                </td>
                                                <td style="padding-left: 73px;">
                                                    <asp:TextBox ID="ratingComment" runat="server" TextMode="MultiLine" Width="515px"
                                                        CssClass="required form-control"></asp:TextBox>
                                                </td>
                                            </tr>


                                            <tr id="trReviewercomment" runat="server">
                                                <td style="padding-left: 25px;">Reviewer's Comment
                                                </td>
                                                <td style="padding-left: 73px;">
                                                    <asp:TextBox ID="reviewersComment" runat="server" TextMode="MultiLine" Width="515px"
                                                        CssClass="required"></asp:TextBox>
                                                </td>
                                            </tr>


                                            <tr id="trApproverComment" runat="server">
                                                <td style="padding-left: 25px;">Approver's Comment
                                                </td>
                                                <td style="padding-left: 73px;">
                                                    <asp:TextBox ID="approversComment" runat="server" TextMode="MultiLine" Width="515px"
                                                        CssClass="required"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="padding-left: 25px;">
                                                    <asp:Button ID="btnBranchRating" runat="server" Text="Save Rating"
                                                        CssClass="button" OnClientClick="return confirmMsg();" OnClick="btnBranchRating_Click" />
                                                    <asp:Button ID="btnReview" runat="server" Text="Save Review" CssClass="button" OnClick="btnReview_Click" />
                                                    <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="button" OnClick="btnApprove_Click" />
                                                </td>
                                            </tr>
                                        </table>
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
