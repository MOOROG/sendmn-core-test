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
using Swift.API;

namespace Swift.web.Remit.SocialWall.Feeds
{
    public partial class BlockUnblockFeed : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var methodName = Request.Form["methodName"];
            if(!IsPostBack)
            {
                if (methodName == "BlockUnblockFeed")
                {
                    var feedId = Request.Form["feedId"];
                    var msg = Request.Form["Message"];
                    BlockFeed(feedId, msg);
                }
            }
        }
        private void BlockFeed(string feedId,string msg)
        {
            var dbResult = new DbResult();
            ISocialWallAPIService _socialWall = new SocialWallAPIService();
            var data = new BlockUnblockFeedParameters()
            {
                feedId = feedId
               ,userId = GetStatic.ReadWebConfig("socialWallAdmin")
               ,blockedMessage=msg

            };
            var feeds = _socialWall.BlockUnblockFeed(data, out dbResult);
            if(dbResult.ErrorCode=="0")
            {
                dbResult.SetError(dbResult.ErrorCode, dbResult.Msg, null);
                
            }
            else
            {
                dbResult.SetError(dbResult.ErrorCode, dbResult.Msg, null);
            }
            JsonSerialize(dbResult);
            
        }
        private void JsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.End();
        }
    }
}