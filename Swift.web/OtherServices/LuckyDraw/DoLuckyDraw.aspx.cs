using Swift.DAL.OtherServices;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Web.Script.Serialization;

namespace Swift.web.OtherServices.LuckyDraw
{
    public partial class DoLuckyDraw : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20174100";
        private LuckyDrawDao db = new LuckyDrawDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            string reqMethod = Request.Form["MethodName"];

            if (!IsPostBack)
            {
                hdnType.Value = GetStatic.ReadQueryString("type", "").ToLower();
                GetImage();
                if (reqMethod == "StartLuckydraw")
                {
                    Thread.Sleep(3000);
                    GetNumber();
                }
                Authenticate();
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void GetImage()
        {
            //var dr = db.GetLuckyDrawType(hdnType.Value);
            //if (null == dr)
            //{
            //    main.Visible = false;
            //    GetStatic.AlertMessage(Page, "Lucky Draw is Not Setup.Please First Set Up the Lucky Draw!!");
            //    divDetails.Visible = false;
            //    return;
            //}
            var root = GetStatic.GetUrlRoot();
            mainImage.ImageUrl = GetStatic.GetUrlRoot() + "/Images/luckydraw/daily-start.jpg";
            //if (dr["luckyDrawType"].ToString() == "Sender_Daily")
            //{
            //    mainImage.ImageUrl = GetStatic.GetUrlRoot() + "/Images/luckydraw/daily-start.jpg";
            //}
            //else
            //{
            //    divDetails.Visible = false;
            //}
        }

        private void Start()
        {
            GetNumber();
        }

        private void GetNumber()
        {
            var flag = GetStatic.ReadFormData("flag", "");
            var dr = db.GetLuckyNumber(flag, GetStatic.GetUser());
            if (null == dr)
            {
                Response.Write("");
                Response.End();
                return;
            }

            var json = DataTableToJson(dr);

            //var dic = new Dictionary<string, string>();
            //foreach (DataColumn col in dr.Columns)
            //{
            //    dic.Add(col.ColumnName, dr[col].ToString());
            //}

            //var sb = new StringBuilder();
            //new JavaScriptSerializer().Serialize(dic, sb);

            Response.ContentType = "text/plain";
            //var json = sb.ToString();
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }
    }
}