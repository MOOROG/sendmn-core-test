<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.Report.Reports" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_grid.js" type="text/javascript"></script>
    </head>
<body>
    <form id="form1" runat="server">
    <div>
        <table cellspacing="0" cellpadding="0" width="950px" border="2">
            <tr>
                <td align="left" valign="top">
                    <img src="../../../../Images/IMELogo.jpg" style="height: 70px; width: 118px;" />
                </td>
                <td nowrap="nowrap" style="font-size: 20px" colspan="8">
                    <b>IME Remit System Enrollment,Maintenance &amp; Cancellation Form</b>
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    <table>
                        <tr>
                            <td style="height: 15px; width: 950px !important;">
                                <div id="rptReport" runat="server" style="width: 950px !important;">
                                </div>
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td nowrap="nowrap" style="height: 100px; width: 350px; text-align: center" valign="bottom">
                                <br />
                                <hr />
                                <b>Name & Signature of Authorized Representative</b>
                            </td>
                            <td nowrap="nowrap" style="height: 100px; width: 100px" valign="bottom">
                            </td>
                            <td nowrap="nowrap" style="height: 100px; width: 250px; text-align: center" valign="bottom">
                                <br />
                                <br />
                                <hr />
                                <b style="text-align: justify">Company Seal</b>
                            </td>
                            <td nowrap="nowrap" style="height: 100px; width: 100px" valign="bottom">
                            </td>
                            <td nowrap="nowrap" style="height: 100px; width: 150px; text-align: center" valign="bottom">
                                <br />
                                <asp:Label runat="server" ID="lblCreatedBy"></asp:Label><br />
                                <hr />
                                <b style="text-align: justify">Prepared By</b>
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td nowrap="nowrap" style="width: 190px; height: 20px; border-color: black; border-width: medium"
                                valign="middle">
                                <b>Requested By:</b><asp:Label runat="server" ID="lblRequestedBy"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" style="width: 190px; height: 20px; border-color: black; border-width: medium"
                                valign="middle">
                                <b>Email:</b><asp:Label runat="server" ID="lblReqEmail"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" style="width: 190px; height: 20px; border-color: black; border-width: medium"
                                valign="middle">
                                <b>Requested Date:</b><asp:Label runat="server" ID="lblReqDate"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="9" rowspan="1" width="715">
                                <b>
                                    <p align="justify" style="width: 950px">
                                        This is to certify that we have received the User IDs and initial Passwords to be
                                        used in the IME Remit System; and that the designated Users have already changed
                                        the initial passwords and already gain access in the system. It is understood that
                                        your branch ___________ shall be liable for errors, frauds or malicious acts committed
                                        by designated Users arising from the use of the User IDs and Passwords.
                                    </p>
                                </b>
                            </td>
                        </tr>
                    </table>
    </form>
</body>
</html>
