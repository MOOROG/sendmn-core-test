using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Swift.API;
using Swift.API.TPAPIs.GMESocialWallAPI;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.SocialWall.Feeds
{
    public partial class ViewFeedDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
                var feedId = GetStatic.ReadQueryString("feedId", "");
                var methodName = GetStatic.ReadQueryString("methodName", "");
                var message = Request.Form["message"];
                if (methodName == "GetReport")
                {
                    GetSpecificFeed(feedId);
                }
        }
        private void GetSpecificFeed(string feedId)
        {
            var dbResult = new DbResult();
            string middleName = "";
            ISocialWallAPIService _socialWall = new SocialWallAPIService();
            var data = new FeedQueryParameters()
            {
                feedId = feedId,
                userId=GetStatic.ReadWebConfig("socialWallAdmin")
            };
            var feeds = _socialWall.GetSpecificFeed(data, out dbResult);
            if(dbResult.ErrorCode=="0")
            {
                var dt = GetStatic.ObjectToData(feeds);
                var sb = new StringBuilder("");
                foreach (DataRow dr in dt.Rows)
                {
                    Id.Text = dr["id"].ToString();
                    userId.Text = dr["userId"].ToString();
                    if (string.IsNullOrEmpty(dr["middleName"].ToString()))
                    {
                        middleName = " ";
                    }
                    else
                    {
                        middleName = " " + dr["middleName"].ToString() + " ";
                    }
                    fullName.Text = dr["firstName"].ToString() + middleName + dr["lastName"].ToString();
                    nickName.Text = dr["nickName"].ToString();
                    updatedDate.Text = dr["updatedDate"].ToString();
                    createdDate.Text = dr["createdDate"].ToString();
                    accessType.Text = dr["accessType"].ToString();
                    blocked.Text = dr["blocked"].ToString();
                    blockedMessage.Text = dr["blockedMessage"].ToString();
                    reported.Text = dr["reported"].ToString();
                    reportedMessage.Text = dr["reportedMessage"].ToString();
                    totalLike.Text = dr["totalLike"].ToString();
                    totalComment.Text = dr["totalComment"].ToString();
                    liked.Text = dr["liked"].ToString();
                    feedText.Text = dr["feedText"].ToString();
                    feedImage.Text = dr["feedImage"].ToString();
                    var imgUrl = feedImage.Text;
                    var imgHtml = "<div class='show-image'><a href='javascript:void(0)' onclick=\"OpenInNewWindow('" + imgUrl + "');\"><img src='" + imgUrl + "' style='width:20px;height:20px;'/></a></div>";
                    feedImg.InnerHtml = imgHtml.ToString();
                }
            }
            else
            {
                GetStatic.SweetAlertErrorMessage(Page, "Error", dbResult.Msg);
            }
            
        }
        
    }
}