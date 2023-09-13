using Swift.API.TPAPIs.GMESocialWallAPI;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.API.Common;
using Swift.API;

namespace Swift.web.Remit.SocialWall.Feeds
{
    public partial class ReportedFeedDetail : System.Web.UI.Page
    {
        DbResult dbResult = new DbResult();
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                var methodName = Request.QueryString["methodName"];
                var feedId = Request.QueryString["feedId"];
                if (methodName == "ReportedFeed")
                {
                    GetReportedFeed(feedId);
                }
            }
        }
        private void GetReportedFeed(string feedId)
        {
            ISocialWallAPIService _socialWall = new SocialWallAPIService();
            List<ReportedFeedResponse> feeds = new List<ReportedFeedResponse>();
            var data = new FeedQueryParameters()
            {
                feedId = feedId
               ,userId = GetStatic.ReadWebConfig("socialWallAdmin")
            };
            feeds = _socialWall.GetFeedReportDetails(data, out dbResult);
            if (dbResult.ErrorCode=="0")
            {
                var dt = GetStatic.ToDataTable(feeds);
                if (dt == null)
                {
                    GetStatic.AlertMessage(this.Page,"No Reported Feeds Found");
                    return;
                }
                var sb = new StringBuilder();
                foreach (DataRow dr in dt.Rows)
                {
                    sb.Append("<tr>");
                    sb.Append("<td>" + dr["reporterName"] + "</td>");
                    var imgUrl = dr["reporterDpUrl"];
                    sb.Append("<td>" + "<div class='show-image'><a href='javascript:void(0)' onclick=\"OpenInNewWindow('" + imgUrl + "');\"><img src='" + imgUrl + "' style='width:20px;height:20px;'/></a></div>" + "</td>");
                    sb.Append("<td>" + dr["reportMessage"] + "</td>");
                    sb.Append("<td>" + dr["reportDate"] + "</td>");
                    sb.Append("</tr>");
                }
                rpt.InnerHtml = sb.ToString();
            }
            else
            {
                GetStatic.SweetAlertErrorMessage(Page, "Error", dbResult.Msg);
            }
        }
    }
}