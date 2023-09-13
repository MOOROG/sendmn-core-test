<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="print.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.BranchRatingNEW.print" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
   <title></title>
     <base id="Base1" target="_self" runat="server" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript">

        function RedirectToIframe(url) {
            window.open(url, "_self");
        }

           
    </script>
    <style type="text/css">
        .tdContent
        {
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
        .tdSubCatIndex
        {
            text-align: center;
            width: 10px !important;
            font-weight: bold;
        }
        .tdddl
        {
            width: 100px !important;
        }
        .ddl
        {
             width: 95%;
        }
        .RemarksTextBox
        {
            word-wrap:break-word;
            width: 90%;
        }
        .TBL td
        {
            white-space: normal !important;
        }
        .low
        {
            color: Green;            
        }
        .high
        {
            color: Red;            
        }
        .medium
        {            
            color: #5d8aa8;
        }
    </style>
</head>
<body onload="window.print()">
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">       
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr id="trratingDetails" runat="server" >
            <td>
            
            <table width="80%" border="0" cellspacing="0" cellpadding="0" class="formTable" style="margin-left: 30px;">
                   
                    <tr>
                        <th colspan="2" class="frmTitle">
                            Branch Rating
                        </th>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                        </td>
                    </tr>
                    <tr>
                    <td colspan="2">
                        <div style="width: 300px; float: left;">
                            <table style="width: 100%;">
                                <tr>
                                    <td>
                                       <b>Branch:</b>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Branch" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                       <b>Review Period:</b>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="ReviewPeriod" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                       <b>Rated By:</b></td>
                                    <td>
                                        <asp:Label ID="ratedby" runat="server" Text=""></asp:Label></td>
                                        <td>
                                        &nbsp;<asp:Label ID="ratedOn" runat="server" Text=""></asp:Label></td>
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
                                       <b>Approved By: </b></td>
                                    <td>
                                        <asp:Label ID="approvedBy" runat="server" Text=""></asp:Label></td>
                                        <td>&nbsp;<asp:Label ID="approvedOn" runat="server" Text=""></asp:Label> </td>
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
                                     &nbsp;<b>0-2 LOW</b></div>
                                </td>
                                <td>
                                    <div style="color:#5d8aa8;">
                                        &nbsp;<b>2.01-3 MEDIUM</b></div>
                                </td>
                                <td>
                                    <div style="color: Red;">
                                        &nbsp;<b>3.01-5 HIGH</b></div>
                                </td>
                   
                            </tr>
                            
                        </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <fieldset>
                                <legend>Agent Rating</legend>
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
                
                <table width="60%" style="margin-left: 30px;font-size:10pt;">
                <tr id="trRatingComment" runat="server">
                    <td style="padding-left: 25px;width:250px;">
                       <b>Rating Comment</b>
                    </td>
                    <td style="padding-left: 73px;">
                     
                            <div id="ratingComment" runat="server" width="515px;"></div>
                    </td>
                </tr>
                

                    <tr id="trReviewercomment" runat="server" style="margin-top: 30px;">
                        <td style="padding-left:25px;">
                         <b>Reviewer's Comment</b>
                        </td>
                        <td style="padding-left:73px;">                            
                            <div id="reviewersComment" runat="server" width="515px;"></div>

                        </td>
                    </tr>
                     <tr id="trApproverComment" runat="server" style="margin-top: 30px;">
                        <td style="padding-left:25px;">
                           <b>Approver's Comment</b>
                        </td>
                        <td style="padding-left:73px;">
                            
                                <div id="approversComment" runat="server" width="515px;"></div>
                        </td>
                    </tr>
                </table>

               

                </table>

                             
            
            </td>
        </tr>
    
    </table>
    
    </form>
</body>
</html>
