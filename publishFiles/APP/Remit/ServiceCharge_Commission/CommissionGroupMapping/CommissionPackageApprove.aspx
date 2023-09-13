<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommissionPackageApprove.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionGroupMapping.CommissionPackageApprove" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
            <base id="Base1" target = "_self" runat = "server" />
            <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
            <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
            <script src="../../../js/functions.js" type="text/javascript"> </script>
        <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    </head>
    <script type="text/javascript">
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[2];
            window.close();
        }
        function ShowHide(obj, imgId) {
            var img = GetElement(imgId);
            var me = GetElement(obj);
            if (me.style.display == "block") {
                me.style.display = "none";
                img.src = "../../../images/plus.png";
                img.title = "Show";
            }
            else {
                me.style.display = "block";
                img.src = "../../../images/minus.gif";
                img.title = "Hide";
            }
            //            $("#" + obj).slideToggle("fast");
        }
    </script>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <table id="Table1" style="width: 100%">                      
            <tr>
                <td height="26" class="bredCrom" colspan="2"> <div> Commission Group Mapping  » Commission Rule Detail</div> </td>
            </tr>
            <tr>
                <td height="20" colspan="2"> <span id="spnCname"  class="welcome" runat="server"><%=GetPackageName()%></span></td>
            </tr>
            <tr>
                <td>
                    <table class="formTable">
                        <tr>
                            <td class="frmLable">Changed By:</td>
                            <td><asp:Label ID="changedBy" runat="server"></asp:Label></td>   
                        </tr>
                        <tr>
                            <td class="frmLable">Changed Date:</td>
                            <td><asp:Label ID="changedDate" runat="server"></asp:Label></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <img id="imgOld" src="../../../Images/minus.gif" border="0" onclick="ShowHide('rpt_oldrule', 'imgOld');" class="showHand"/>
                    <span style="font-size: 12px; font-weight: bold;">View Changes</span>
                    <div id = "rpt_oldrule" runat = "server"  style="overflow: scroll; width: 100%; display: block; margin-left: 10px; background: #f2f2f2; border: 1px solid gray;"></div> 
                </td>
            </tr> 
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnApprove" runat="server" Text="Approve" OnClick="btnApprove_Click" />
                    <asp:Button ID="btnReject" runat="server" Text="Reject" OnClick="btnReject_Click"/>
                </td>
            </tr>                             
        </table>
    </form>
</body>
</html>

