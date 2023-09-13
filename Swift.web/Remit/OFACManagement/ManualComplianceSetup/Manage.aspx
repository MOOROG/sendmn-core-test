<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.ManualComplianceSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/js/swift_calendar.js"></script>
    <%--<script src="/ui/js/pickers-init.js"></script>--%>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>

    <script language="javascript" type="text/javascript">
        $(document).ready(function () {
            CalSenderDOB("#<% =dob.ClientID%>");
            ShowCalDefault("#<% =dobBs.ClientID%>");
            $.ajaxSetup({ cache: false });
        });
        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });
    <%--    function LoadCalender() {
            CalSenderDOB("#<% =dob.ClientID%>");
        }--%>

        function GetADVsBSDate(type, control) {
            var date = "";
            if (type == "ad" && control == "dob")
                date = GetValue("<%=dob.ClientID%>");
            else if (type == "bs" && control == "dobBs")
                date = GetValue("<%=dobBs.ClientID%>");

            var dataToSend = { MethodName: "getdate", date: date, type: type };
            var options =
                {
                    url: '<%=ResolveUrl("Manage.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        var data = jQuery.parseJSON(response);
                        if (data[0].Result == "") {
                            alert("Invalid Date.");
                            return;
                        }

                        if (type == "ad" && control == "dob") {
                            SetValueById("<%=dobBs.ClientID %>", data[0].Result, "");
                        }
                        else if (type == "bs" && control == "dobBs")
                            SetValueById("<%=dob.ClientID %>", data[0].Result, "");

                        ValidateDate();

                    },
                    error: function (request, error) {
                        alert(request);
                    }
                };
            $.ajax(options);
        }

        function ValidateDate() {
            try {
                var dateDOBValue = GetValue("<%=dob.ClientID%>");
                var dateDOBValueBs = GetValue("<%=dobBs.ClientID%>");

                var current = new Date();
                var currentYear = current.getFullYear();

                if (dateDOBValueBs != '') {
                    //MM/DD/YYYY
                    var dateDOBValueBsArr = dateDOBValueBs.split('/');
                    if (dateDOBValueBsArr.length == 1)
                        dateDOBValueBsArr = dateDOBValueBs.split('-');

                    try {
                        var dtBS = new Date(dateDOBValueBs);
                    }
                    catch (e) {

                        alert('Invalid date format for DOB BS. Date should be in yyyy-MM-dd format.');
                        SetValueById("<%=dobBs.ClientID%>", "", "");
                        SetValueById("<%=dob.ClientID %>", "", "");
                        return false;
                    }

                    if (dateDOBValueBsArr.length == 3) {
                        var bsDD = dateDOBValueBsArr[1];
                        var bsMM = dateDOBValueBsArr[0];
                        var bsYear = dateDOBValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for DOB BS. Date should be in yyyy-MM-dd format.');
                            SetValueById("<%=dobBs.ClientID%>", "", "");
                            SetValueById("<%=dob.ClientID %>", "", "");
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for DOB BS. Date should be in yyyy-MM-dd format.');
                        SetValueById("<%=dobBs.ClientID%>", "", "");
                        SetValueById("<%=dob.ClientID %>", "", "");
                        return false;
                    }
                }
            }
            catch (e) {
                // alert(e);
            }

            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">OFAC Management</a></li>
                            <li class="active"><a href="Manage.aspx">Import Manual Compliance  Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx" target="_self">List </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Manual Compliance Setup Manage</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">

                                    <table class="table table-responsive">
                                        <asp:UpdatePanel runat="server" ID="up">
                                            <ContentTemplate>
                                                <tr>
                                                    <td>ENTNUM (Unique Key)<br />
                                                        <asp:TextBox runat="server" ID="entNum" CssClass="form-control"></asp:TextBox>
                                                    </td>
                                                    <td>Type <span class="errormsg"></span>
                                                        <br />
                                                        <asp:DropDownList ID="vesselType" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="">Select</asp:ListItem>
                                                            <asp:ListItem Value="Individual">Individual</asp:ListItem>
                                                            <asp:ListItem Value="Company">Company</asp:ListItem>
                                                            <asp:ListItem Value="Organization">Organization</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>Name<span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="name" Display="Dynamic"
                                                            ErrorMessage="Required!" ValidationGroup="compliance" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                                                        <asp:TextBox runat="server" ID="name" CssClass="form-control" onkeypress="return onlyAlphabets(event,this);" />
                                                    </td>
                                                </tr>
                                                <tr style="display: none;">
                                                    <td colspan="3">Membership Id<br />
                                                        <asp:TextBox runat="server" ID="cardNo" Width="150px" />
                                                        &nbsp;&nbsp;&nbsp;
                                                                    <asp:Button ID="btnFind" Text="Find" runat="server" CssClass="InputButtons" OnClick="btnFind_Click" />
                                                        <asp:Button ID="btnClear" Text="Clear" runat="server" CssClass="InputButtons" OnClick="btnClear_Click" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Country <span class="errormsg">*
                                                              <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="country" Display="Dynamic"
                                                                  ErrorMessage="Required!" ValidationGroup="compliance" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                                                        <asp:DropDownList runat="server" ID="country" CssClass="form-control" OnSelectedIndexChanged="country_SelectedIndexChanged" AutoPostBack="true">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td style="display: none">State<br />
                                                        <asp:DropDownList runat="server" ID="Zone" CssClass="form-control" OnSelectedIndexChanged="Zone_SelectedIndexChanged"
                                                            AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td style="display: none">District<br />
                                                        <asp:DropDownList runat="server" ID="District" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>Address<br />
                                                        <asp:TextBox runat="server" ID="address" CssClass="form-control" />
                                                    </td>
                                                    <td>Id Type<br />
                                                        <asp:DropDownList runat="server" ID="IdType" CssClass="form-control" OnSelectedIndexChanged="IdType_SelectedIndexChanged"
                                                            AutoPostBack="true">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>

                                                    <td>Id Number<br />
                                                        <asp:TextBox runat="server" ID="IdNumber" CssClass="form-control" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"
                                                            onchange="IdNoValidation(this)" />
                                                    </td>
                                                    <td style="display:none;">Id Place of Issue<br />
                                                        <asp:DropDownList runat="server" ID="idPlaceIssue" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>Date of Birth<br />
                                                        <div class="input-group m-b">
                                                            <span class="input-group-addon">
                                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                                            </span>
                                                            <asp:TextBox ID="dob" onchange="return DateValidation('dob','dob')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                        <tr>

                                            <td id="tdSenDobTxtBs" runat="server" nowrap="nowrap">DOB (B.S)<br />
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                                    </span>
                                                    <asp:TextBox ID="dobBs" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                </div>
                                                <br />
                                                <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                            </td>
                                            <td>Contact Number<br />
                                                <asp:TextBox runat="server" ID="contact" CssClass="form-control" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" />
                                            </td>
                                            <td>Father's Name<br />
                                                <asp:TextBox runat="server" ID="relativesName" CssClass="form-control" onkeypress="return onlyAlphabets(event,this);" />
                                            </td>
                                        </tr>
                                        <tr>

                                            <td>Data source<br />
                                                <asp:TextBox runat="server" ID="DataSource" CssClass="form-control" onkeypress="return onlyAlphabets(event,this);" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Remarks<br />
                                                <asp:TextBox runat="server" ID="remarks" TextMode="MultiLine" Rows="4" Columns="20" CssClass="form-control" />
                                                <cc1:TextBoxWatermarkExtender ID="TBWE2" runat="server" TargetControlID="remarks" WatermarkText="Place of Birth ,Nationality ,Job ,Reference etc.." />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="isActive" runat="server" Text="Is Active?" Checked="true" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Button ID="save" Text="Save" runat="server" OnClick="save_Click" ValidationGroup="compliance" CssClass="btn btn-primary m-t-25" /><span
                                                    style="width: 100px;">&nbsp;</span>
                                                <asp:Button ID="Back" Text="Back" CssClass="btn btn-primary m-t-25" runat="server" OnClick="Back_Click" />
                                            </td>
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="save">
                                            </cc1:ConfirmButtonExtender>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                    </table>

                                    <asp:HiddenField ID="hddidPlaceIssue" runat="server" />
                                    <asp:HiddenField ID="hddIdType" runat="server" />
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