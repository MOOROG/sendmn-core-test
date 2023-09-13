using Swift.API.ThirdPartyApiServices;
using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Xml.Serialization;

namespace Swift.web.AgentNew.Administration.TransactionSync
{
    public partial class TxnDownload : System.Web.UI.Page
    {
        ImportSettlementRateDao _isd = new ImportSettlementRateDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected ExchangeRateAPIService _map = new ExchangeRateAPIService();
        private const string ViewFunctionId = "20202900";
        protected void Page_Load(object sender, EventArgs e)
        {
            string MethodName = Request.Form["MethodName"];
            switch (MethodName)
            {
                case "MapData":
                    UpdateReferral();
                    break;
            }
            _sl.HasRight(ViewFunctionId);
            if (!IsPostBack)
            {
                PopulateData();
            }
        }

        private void PopulateData()
        {
            DataSet ds = _isd.ShowInficareTempData(GetStatic.GetUser(), ddlMapped.SelectedValue);

            DataTable dt = ds.Tables[1];
            numberOfTxns.InnerText = "Total number of transactions: " + ds.Tables[0].Rows[0][0].ToString() + " (Referral Mapped: " + ds.Tables[0].Rows[0][1].ToString() + " Unmapped: " + ds.Tables[0].Rows[0][2].ToString() + ")";

            if (null == dt || dt.Rows.Count == 0)
            {
                tranTable.InnerHtml = "<tr><td colspan=\"12\" align=\"center\">No data to display!</td></tr>";
                return;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + item["TRANID"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["CONTROLNO"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["sempid"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["SENDERNAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["RECEIVERNAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["collMode"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["RECEIVERCOUNTRY"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["COLLECTAMOUNT"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["SENTAMOUNT"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["PAYOUTAMOUNT"].ToString()) + "</td>");
                if (!string.IsNullOrEmpty(item["PROMOTIONCODE"].ToString()))
                {
                    sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["TRANID"].ToString(), "'category' : 'remit-referralChange'", item["PROMOTIONCODE"].ToString(), item["REFERRAL"].ToString() + " | " + item["PROMOTIONCODE"].ToString()) + "</td>");
                }
                else
                {
                    sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["TRANID"].ToString(), "'category' : 'remit-referralChange'") + "</td>");
                }
                sb.AppendLine("<td><input type=\"button\" onclick=\"SavedClicked('" + item["TRANID"].ToString() + "')\" class=\"btn btn-default\" id='save_" + item["TRANID"].ToString() + "' value=\"Save\"></td>");
                sb.AppendLine("</tr>");
            }

            tranTable.InnerHtml = sb.ToString();
        }

        protected void downloadbtn_Click(object sender, EventArgs e)
        {
            string fDate = DateTime.Now.ToString("yyyy-MM-dd");
            string tDate = DateTime.Now.ToString("yyyy-MM-dd");

            var url = "http://agent.jmejapan.com/account/GetTransactionList?passKey=jme.com.jp@1934321&dateFrom=" + fDate + "&dateTo=" + tDate;
            var response = _map.DownloadInficareTransaction(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                DbResult _dbRes = _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "TRANSACTION-DOWNLOAD");
                if (_dbRes.ErrorCode == "0")
                {
                    GetStatic.AlertMessage(this, _dbRes.Msg);
                    PopulateData();
                }
                else
                {
                    GetStatic.AlertMessage(this, _dbRes.Msg);
                }
                //PopulateData();
            }
            else
            {
                GetStatic.AlertMessage(this, response[0].errorMsg);
            }
        }

        public string ObjectToXML(object input)
        {
            try
            {
                var stringwriter = new StringWriter();
                var serializer = new XmlSerializer(input.GetType());
                serializer.Serialize(stringwriter, input);
                return stringwriter.ToString();
            }
            catch (Exception ex)
            {
                if (ex.InnerException != null)
                    ex = ex.InnerException;

                return "Could not convert: " + ex.Message;
            }
        }

        protected void UpdateReferral()
        {
            DbResult _dbRes = new DbResult();
            var tranId = Request.Form["TranId"];
            var referralCode = Request.Form["ReferralCode"];
            if (string.IsNullOrEmpty(tranId) || string.IsNullOrEmpty(referralCode))
            {
                _dbRes.SetError("1", "Required fields are mandatory!", null);
            }
            else
            {
                _dbRes = _isd.MapReferral(GetStatic.GetUser(), tranId, referralCode);
            }

            GetStatic.JsonResponse(_dbRes, this);
        }

        protected void ddlMapped_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateData();
        }
    }
}