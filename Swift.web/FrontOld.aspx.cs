using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;

namespace Swift.web
{
    public partial class Font : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            var MethodName = Request.Form["MethodName"];
            switch (MethodName)
            {
                case "Messages":
                    PopulateMessageDetail();
                    break;

                default:
                    break;
            }

            sl.CheckSession();
            if (!IsPostBack)
            {
                Load_TransactionCount();
                PopulateMessages();
            }
        }


        private bool DataExists(DataTable dataTable, int rowIndex, int colCount)
        {
            bool retVal = false;
            rowIndex = (rowIndex.Equals(0)) ? 1 : rowIndex;
            for (int i = rowIndex; i < dataTable.Rows.Count; i++)
            {
                if (dataTable.Rows[i][colCount].ToString() != "0")
                {
                    retVal = true;
                }
            }
            return retVal;
        }


        private void PopulateMessageDetail()
        {
            string msgId = Request.Form["MessageId"];
            var obj = new MessageSettingDao();
            DataRow dr = obj.GetNewsFeederMessage(msgId);
            if (dr == null)
            {
                return;
            }
            MessageData _data = new MessageData();

            _data.CreatedBy = dr["createdBy"].ToString();
            _data.CreatedDate = dr["createdDate"].ToString();
            _data.Message = dr["newsFeederMsg"].ToString();

            var json = new JavaScriptSerializer().Serialize(_data);
            JsonSerialize(json);
        }

        private void JsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.End();
        }

        public class MessageData
        {
            public string CreatedBy { get; set; }
            public string CreatedDate { get; set; }
            public string Message { get; set; }
        }

        protected String GetDate()
        {
            return DateTime.Now.ToString("yyyy-MM-dd");
        }

        protected void Load_TransactionCount()
        {
            var obj = new MessageSettingDao();
            var ds = obj.Get_TransactionCount(GetStatic.GetUser());
            divPopulateTxnCount.Visible = false;
            TxnWiseStatus.Visible = false;

            if (null == ds)
            {
                return;
            }
            if (ds.Tables.Count == 0)
            {
                return;
            }

            var dr = ds.Tables[0].Rows[0];
            iCancel.Text = dr["iCancel"].ToString();
            iSend.Text = dr["iSend"].ToString();
            iPaid.Text = dr["intPaidCount"].ToString();
            iCode.Text = dr["iCode"].ToString();
            balanceId.Text = dr["balance"].ToString();

            divPopulateTxnCount.Visible = true;
            TxnWiseStatus.Visible = true;

            var dt = ds.Tables[1];
            int sn = 0;
            var sb = "";
            sb += "<table class='table table-responsive table-bordered'>";
            sb += "<tr>";
            sb += "<th>S.N</th>";
            sb += "<th>NO OF TXN</th>";
            sb += "<th>STATUS</th>";
            sb += "</tr>";
            foreach (DataRow item in dt.Rows)
            {
                sn++;
                sb += "<tr>";
                sb += "<td>" + sn + "</td>";
                sb += "<td><a onclick=\"ShowReport('" + item["tranStatus"] + "')\">" + item["TxnNo"] + "</a></td>";
                sb += "<td>" + item["tranStatus"] + "</td>";
                sb += "</tr>";
            }
            sb += "</table>";
            if (dt.Rows.Count > 0)
            {
                TxnWiseStatus.InnerHtml = sb;
            }

            if (ds.Tables[2].Rows.Count > 0)
            {
                var dtt = ds.Tables[2].Rows[0];
                diff.Text = "Хэцүү: " + dtt["iDifficult"].ToString() + "&nbsp;&nbsp;";
                diff.ForeColor = Color.Red;
                norm.Text = "Хэвийн: " + dtt["iNormal"].ToString() + "&nbsp;&nbsp;";
                norm.ForeColor = Color.Yellow;
                easy.Text = "Хялбар: " + dtt["iEasy"].ToString() + "&nbsp;&nbsp;";
                easy.ForeColor = Color.Aquamarine;
                List<int> listInt = new List<int>();
                listInt.Add(Convert.ToInt32(dtt["iDifficult"]));
                listInt.Add(Convert.ToInt32(dtt["iNormal"]));
                listInt.Add(Convert.ToInt32(dtt["iEasy"]));
                //double aveRate = listInt.Max();
                //if (dtt["iAverage"] != System.DBNull.Value) {
                //  appreview.Text = "Дундаж : " + dtt["iAverage"].ToString();
                //  if (Convert.ToDouble(dtt["iAverage"]) > 0 && Convert.ToDouble(dtt["iAverage"]) < 1.5) {
                //    emoji.InnerHtml = "<i class=\"fa fa-frown-o\"></i>";
                //  } else if (Convert.ToDouble(dtt["iAverage"]) >= 1.5 && Convert.ToDouble(dtt["iAverage"]) < 2.5) {
                //    emoji.InnerHtml = "<i class=\"fa fa-meh-o\"></i>";
                //  } else if (Convert.ToDouble(dtt["iAverage"]) >= 2.5) {
                //    emoji.InnerHtml = "<i class=\"fa fa-smile-o\"></i>";
                //  }
                //}
            }
        }

        protected void PopulateMessages()
        {
            var obj = new MessageSettingDao();
            var dt = obj.GetNewsFeeder(GetStatic.GetUser(), GetStatic.GetUserType(), GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch());
            if (dt.Rows.Count == 0 || dt == null)
            {
                return;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                string msgId = item["msgId"].ToString();
                sb.AppendLine("<li class=\"list-group-item\">");
                sb.AppendLine("<a href=\"javascript:void(0);\" onclick=\"ShowMessage('" + msgId + "')\" data-toggle=\"modal\">" + GetMessageToShow(item["newsFeederMsg"].ToString()) + "</a>");
                sb.AppendLine("<small><i class=\"fa fa-clock-o\"></i>&nbsp;" + item["msgDate"].ToString() + "</small>");
                sb.AppendLine("</li>");
            }
            messages.InnerHtml = sb.ToString();
        }

        private string GetMessageToShow(string message)
        {
            string pureString = Regex.Replace(message, "<.*?>", String.Empty);
            return pureString.Substring(0, Math.Min(pureString.Length, 40));
        }
    }
}
