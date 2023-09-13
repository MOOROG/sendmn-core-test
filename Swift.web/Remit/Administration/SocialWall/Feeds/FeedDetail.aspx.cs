using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
//using Swift.DAL.SocialWall.Feeds;
using Swift.web.Library;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using System.Web.Script.Serialization;
using System.Text;
using System.Data;
using Swift.API.TPAPIs.GMESocialWallAPI;
using Swift.API.Common;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.API;
using Swift.DAL.OnlineAgent;

namespace Swift.web.Remit.SocialWall.Feeds
{
    public partial class FeedDetail : System.Web.UI.Page
    {
        OnlineCustomerDao cust = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                PopulateCountryList();
            }
            var feedId = GetStatic.ReadQueryString("feedId","");
            var methodName = Request.Form["methodName"];
            if (methodName=="SearchFeeds")
            {
                SearchFeed();
            }
        }
        private void SearchFeed()
        {
            var dbResult = new DbResult();
            var data = new FeedRequest()
            {
                //userId = Request.Form["userId"],
                userId = GetStatic.ReadWebConfig("socialWallAdmin"),
                country = Request.Form["country"],
                onlyReported = Request.Form["onlyReported"],
                before = Request.Form["before"],
                after = Request.Form["after"],
                limit = Request.Form["limit"]

            };
            ISocialWallAPIService _socialWall = new SocialWallAPIService();
            var feedResponse = new FeedResponse();
            feedResponse = _socialWall.GetFeeds(data,out dbResult);
            if(dbResult.ErrorCode=="0")
            {
                JsonSerialize(feedResponse);   
            }
            else
            {
                GetStatic.SweetAlertErrorMessage(Page, "Error", dbResult.Msg);
            }
        }

        private void PopulateCountryList()
        {
            DataTable dt = cust.GetAllReceiverCountryList(GetStatic.GetUser());

            if (dt.Rows.Count == 0 || dt == null)
            {
                return;
            }
            ddlOperativeCountry.DataSource = dt;
            ddlOperativeCountry.DataTextField = "countryName";
            ddlOperativeCountry.DataValueField = "countryName";
            ddlOperativeCountry.DataBind();
            ddlOperativeCountry.Items.Insert(0, new ListItem("-Select Country-", "-Select Country-"));
            ddlOperativeCountry.SelectedIndex = 0;
        }
        private void JsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }
    }
}