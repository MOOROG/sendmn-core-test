using Newtonsoft.Json;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Xml.Serialization;
using static Swift.API.Common.MapAPIData.APIBankModel;

namespace Swift.web.Remit.Transaction.DownloadTxn
{
    public partial class DownloadInficareData : System.Web.UI.Page
    {
        ImportSettlementRateDao _isd = new ImportSettlementRateDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected ExchangeRateAPIService _map = new ExchangeRateAPIService();
        private const string ViewFunctionId = "20150080";

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
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void PopulateData()
        {
            DataSet ds = _isd.ShowInficareTempData(GetStatic.GetUser(), ddlMapped.SelectedValue);

            DataTable dt = ds.Tables[1];
            numberOfTxns.InnerText = "Total number of transactions: " + ds.Tables[0].Rows[0][0].ToString() + " (Referral Mapped: " + ds.Tables[0].Rows[0][1].ToString() + " Unmapped: " + ds.Tables[0].Rows[0][2].ToString() + ")";
            txnNeedToBeApproved.InnerText = "Txns waiting for approval: " + ds.Tables[2].Rows[0][0].ToString();

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
            string fDate = fromDate.Text;
            string tDate = toDate.Text;
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

            Response.ContentType = "application/json";
            Response.Write(JsonConvert.SerializeObject(_dbRes));
            Response.End();
        }

        protected void ddlMapped_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateData();
        }

        protected void btnMapReferral_Click(object sender, EventArgs e)
        {
            if (fileReferral.FileContent.Length > 0)
            {
                if (fileReferral.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\..\\") + "\\doc\\tmp\\" + fileReferral.FileName;
                    string Remitpath = Server.MapPath("..\\..\\..\\") + "\\SampleFile\\FCYVoucherEntry\\" + fileReferral.FileName;
                    fileReferral.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTableForTxnSyncInficare(path, true);

                    //File.Move(path, Remitpath);
                    File.Delete(path);
                    var rs = _isd.UploadManualMap(GetStatic.GetUser(), xml);
                    if (rs.ErrorCode == "1")
                    {
                        GetStatic.AlertMessage(this, rs.Msg);
                    }
                    else
                    {
                        GetStatic.AlertMessage(this, rs.Msg);
                        PopulateData();
                    }
                }
                else
                {
                    GetStatic.AlertMessage(this, "Invalid file format uploaded");
                }
            }
        }

        protected void btnFinalSave_Click(object sender, EventArgs e)
        {
            var rs = _isd.FinalSave(GetStatic.GetUser());
            if (rs.ErrorCode == "1")
            {
                GetStatic.AlertMessage(this, rs.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, rs.Msg);
            }
            PopulateData();
        }

        protected void downloadForSync_Click(object sender, EventArgs e)
        {
            
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            _isd.ClearTempData(GetStatic.GetUser());
            PopulateData();
        }

        protected void btnSyncPaid_Click(object sender, EventArgs e)
        {
            string fDate = fromDate.Text;
            string tDate = toDate.Text;
            var url = "http://agent.jmejapan.com/account/GetTransactionStatus?passKey=jme.com.jp@1934321&DateType=1&dateFrom=" + fDate + "&dateTo=" + tDate;
            var response = _map.DownloadInficareTransactionForSync(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                DbResult _dbRes = _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "SYNC-PAID");
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

        protected void btnSyncCancel_Click(object sender, EventArgs e)
        {
            string fDate = fromDate.Text;
            string tDate = toDate.Text;
            var url = "http://agent.jmejapan.com/account/GetTransactionStatus?passKey=jme.com.jp@1934321&DateType=2&dateFrom=" + fDate + "&dateTo=" + tDate;
            var response = _map.DownloadInficareTransactionForSync(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                DbResult _dbRes = _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "SYNC-CANCEL");
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

        protected void btnExecuteSelected_Click(object sender, EventArgs e)
        {
            var selectedOption = Request.Form["checkBoxSync"];
            DbResult _dbRes = new DbResult();

            if (selectedOption == "1")
                _dbRes = _isd.RunJob(GetStatic.GetUser(), "Approve Transaction");
            else if (selectedOption == "2")
                _dbRes = _isd.RunVaultTransfer(GetStatic.GetUser());
            else
                _dbRes.SetError("1", "Please choose any one operation to execute!", "");

            GetStatic.AlertMessage(this, _dbRes.Msg);
        }

        protected void btnClearTemp_Click(object sender, EventArgs e)
        {
            var _dbRes = _isd.RunJob(GetStatic.GetUser(), "Approve Transaction");
            if (_dbRes.ErrorCode == "0")
            {
                var returnResp = _isd.ClearTempTranData(GetStatic.GetUser());
                GetStatic.AlertMessage(this, returnResp.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, "Txn Approve job is running you can not clear remittrantemp data");
            }
        }
    }
}