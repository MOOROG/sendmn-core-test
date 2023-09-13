<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewFeedDetail.aspx.cs" Inherits="Swift.web.Remit.SocialWall.Feeds.ViewFeedDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/css/sweetalert.css" rel="stylesheet" />
    <style type="text/css">
        .block {
            margin: 5px 0; /* or whatever */
        }

        .header {
            color: #ed1c24 !important;
            border-color: #ed1c24 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="table table-responsive">
            <table class="table" width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" valign="top" class="header">Feed Details » List
                    </td>
                </tr>
                <tr>
                    <td height="10" class="shadowBG"></td>
                </tr>
                <tr>
                    <td valign="top">
                        <div>
                            <fieldset>
                                <legend>-Feed Detail-</legend>
                                <div class="table table-responsive">
                                    <table class="table">
                                        <tr>
                                            <td>
                                                <div>
                                                    FeedId:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="Id"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    UserId:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="userId"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div>
                                                    FullName:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="fullName"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    NickName:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="nickName"></asp:Label>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <div>
                                                    UpdatedDate:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="updatedDate"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    CreatedDate:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="createdDate"></asp:Label>
                                            </td>
                                        </tr>


                                        <tr>
                                            <td>
                                                <div>
                                                    AccessType:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="accessType"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    Blocked:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="blocked"></asp:Label>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <div>
                                                    BlockedMessage:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="blockedMessage"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    Reported:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="reported"></asp:Label>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <div>
                                                    ReportedMessage:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="reportedMessage"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    TotalLike:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="totalLike"></asp:Label>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <div>
                                                    TotalComment:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="totalComment"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    Liked:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="liked"></asp:Label>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <div>
                                                    FeedText:
                                                </div>
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="feedText"></asp:Label>
                                            </td>
                                            <td>
                                                <div>
                                                    FeedImage:
                                                </div>
                                            </td>
                                            <td>
                                                <div id="feedImg" runat="server">
                                                </div>
                                                <asp:Label runat="server" style="display:none;" ID="feedImage"></asp:Label>
                                            </td>
                                        </tr>

                                    </table>
                                </div>
                            </fieldset>
                        </div>

                        <!-- Trigger the modal with a button -->
                        <div class="form-group">
                            <button type="button" id="btnBlock" class="btn btn-primary m-t-25 block" data-toggle="modal" data-target="#myModal">
                                Block-Unblock Feed
                            </button>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <br />
        <br />
        <!-- Button trigger modal -->
        <div>
        </div>
        <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="gridSystemModalLabel">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">
                            &times;
                        </button>
                        <h4 class="modal-title">Block/Unblock Feed</h4>
                    </div>
                    <div class="modal-body">
                        <div id="blockUnblockFeed">
                            <h4>Reason for block/Unblock Feed</h4>
                            <div class="form-group">
                                <textarea class="form-control" rows="4" cols="50" required="required" id="txtRemarks"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <input type="submit" class="btn btn-primary" value="Submit" onclick="BlockUnblockFeed()" />
                        <button type="button" class="btn btn-primary"
                            data-dismiss="modal">
                            Cancel</button>
                    </div>
                </div>
            </div>
        </div>
        <script src="../../../../ui/js/jquery.min.js"></script>
        <script src="../../../../js/functions.js"></script>
        <script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
        <script src="../../../../js/jQuery/jquery.validate.min.js"></script>
        <script src="../../../../ui/js/sweet-alert/sweetalert.min.js"></script>

        <script type="text/javascript">
            function BlockUnblockFeed() {
                document.body.scrollTop = 0;
                document.documentElement.scrollTop = 0;
                if (confirm("Are you sure you want to block/unblock?")) {
                }
                var dataToSend = {
                    feedId: document.getElementById('Id').innerText,
                    MethodName: 'BlockUnblockFeed',
                    Message: $("#txtRemarks").val(),
                };
                var xhr = $.ajax({
                    type: "POST",
                    url: '<%=ResolveUrl("BlockUnblockFeed.aspx")%>',
                    dataType: "JSON",
                    data: dataToSend,
                    success: function (data, textStatus, xhr) {
                        $('input[type="submit"]').prop('disabled', false);

                        if (data.ErrorCode == "0") {
                            swal({
                                title: "Success",
                                text: data.Msg,
                                type: "success",
                                showCancelButton: false,
                                html: true
                            },
                       function (isConfirm) {
                           if (isConfirm) {
                               window.location.href = '/Remit/Administration/SocialWall/Feeds/ViewFeedDetail';
                           }
                       });

                        }
                        else {
                            swal("Error!", data.Msg, "error");
                        }
                    },
                    error: function () {
                        $('input[type="submit"]').prop('disabled', false);
                        swal("Error!", "Oops!!! something went wrong, please try again.", "error");
                    }
                })
            };
        </script>
    </form>


</body>
</html>
