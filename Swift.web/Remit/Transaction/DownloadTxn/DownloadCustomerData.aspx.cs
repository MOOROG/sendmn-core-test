using Swift.API.ThirdPartyApiServices;
using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Xml.Serialization;

namespace Swift.web.Remit.Transaction.DownloadTxn
{
    public partial class DownloadCustomerData : System.Web.UI.Page
    {
        ImportSettlementRateDao _isd = new ImportSettlementRateDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected ExchangeRateAPIService _map = new ExchangeRateAPIService();
        private const string ViewFunctionId = "20302900";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.HasRight(ViewFunctionId);
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateData();
            }
        }

        private void PopulateData()
        {
            DataSet ds = _isd.ShowCustomerReceiverData(GetStatic.GetUser());

            DataTable dt = ds.Tables[0];
            txnNeedToBeApproved.InnerText = "Customers pending for wallet and membership ID create: " + ds.Tables[1].Rows[0][0].ToString();

            if (null == dt || dt.Rows.Count == 0)
            {
                tranTable.InnerHtml = "<tr><td colspan=\"6\" align=\"center\">No data to display!</td></tr>";
                return;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + item["DOWNLOAD_TYPE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["DOWNLOAD_COUNT"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["DUPLICATE_COUNT"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["MSG"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["CREATED_DATE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["CREATED_BY"].ToString() + "</td>");
                sb.AppendLine("</tr>");
            }

            tranTable.InnerHtml = sb.ToString();
        }

        protected void downloadbtn_Click(object sender, EventArgs e)
        {
            string fDate = fromDate.Text;
            string tDate = toDate.Text;
            var url = "http://agent.jmejapan.com/account/GetSenderList?passKey=jme.com.jp@1934321&dateFrom=" + fDate + "&dateTo=" + tDate;
            var response = _map.DownloadInficareCustomer(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                DbResult _dbRes = _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "CUSTOMER-DOWNLOAD", fDate + " - " + tDate);
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

        protected void btnExecuteSelected_Click(object sender, EventArgs e)
        {

        }

        protected void downloadBtnReceiver_Click(object sender, EventArgs e)
        {
            string fDate = fromDate.Text;
            string tDate = toDate.Text;
            var url = "http://agent.jmejapan.com/account/GetReceiverList?passKey=jme.com.jp@1934321&dateFrom=" + fDate + "&dateTo=" + tDate;
            var response = _map.DownloadInficareReceiver(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                DbResult _dbRes = _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "RECEIVER-DOWNLOAD", fDate + " - " + tDate);
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

        protected void btnExecuteSelected_Click1(object sender, EventArgs e)
        {
            DbResult _dbRes = new DbResult();

            _dbRes = _isd.RunJob(GetStatic.GetUser(), "Create Customer Wallet And Membership ID");

            GetStatic.AlertMessage(this, _dbRes.Msg);
        }
    }
}