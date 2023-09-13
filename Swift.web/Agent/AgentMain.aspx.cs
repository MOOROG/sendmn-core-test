using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;

namespace Swift.web.Agent
{
    public partial class AgentMain : System.Web.UI.Page
    {
        private RemittanceLibrary _remit = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "Messages")
            {
                PopulateMessageDetail();
            }
            if (!IsPostBack)
            {
                _remit.CheckSession();
                ManageSendPayMenus();
                // PopulateMessage();
                PopulateTxnCount();
                PopulateMessages();
            }
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

        public class MessageData
        {
            public string CreatedBy { get; set; }
            public string CreatedDate { get; set; }
            public string Message { get; set; }
        }

        private void JsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.End();
        }

        private void ManageSendPayMenus()
        {
            if (GetStatic.ReadSession("agentType", "").ToLower() == "send")
            {
                sendingAgent.Visible = true;
                sendingAgent1.Visible = true;
                payAgent.Visible = false;
                payAgent1.Visible = false;
            }
            else if (GetStatic.ReadSession("agentType", "").ToLower() == "pay")
            {
                sendingAgent.Visible = false;
                sendingAgent1.Visible = false;
                payAgent.Visible = true;
                payAgent1.Visible = true;
            }
        }

        private void PopulateTxnCount()
        {
            string sql = "exec proc_txnCountAgent @agentId = '" + GetStatic.GetBranch() + "'";
            DataRow dr = _remit.ExecuteDataRow(sql);
            if (dr == null)
            {
                return;
            }
            iSend.Text = dr["iSend"].ToString();
            iCancel.Text = dr["iCancel"].ToString();
            iPaid.Text = dr["iPaid"].ToString();
            iUnpaid.Text = dr["iUnpaid"].ToString();
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