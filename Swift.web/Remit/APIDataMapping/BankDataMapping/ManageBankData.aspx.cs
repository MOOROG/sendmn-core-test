using Swift.API.MapAPIData;
using Swift.DAL.APIDataMappingDao;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Xml.Serialization;
using static Swift.API.Common.MapAPIData.APIBankModel;

namespace Swift.web.Remit.APIDataMapping.BankDataMapping
{
    public partial class ManageBankData : System.Web.UI.Page
    {
        protected DownloadAPIData _map = new DownloadAPIData();
        protected APIMapping _dao = new APIMapping();
        protected FuzzyMatcher _match = new FuzzyMatcher();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20201800";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowMasterData();
                Authenticate();
                
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnDownloadBank_Click(object sender, EventArgs e)
        {
            string partner = GetPartner();
            if (!string.IsNullOrEmpty(partner))
            {
                BankRequest request = new BankRequest()
                {
                    CountryCode = "NP",//GetCountry()
                    ProviderId = partner
                };
                var response = _map.ThirdPartyApiGetDataOnly<BankRequest, _BankResponse>(request, "api/v1/TP/bankList", "Data", "post");
                if (response.ResponseCode == "0")
                {
                    var sessionId = GetStatic.GetSessionId();
                    var xml = ObjectToXML(response.Data);
                    var res = _dao.SyncBank(GetStatic.GetUser(), xml, GetCountry(), request.ProviderId, "NPR", sessionId);

                    if (res.ErrorCode == "0")
                    {
                        LoadDataFromTemp(sessionId);
                    }
                    else
                    {
                        GetStatic.AlertMessage(this, res.Msg);
                    }
                }
            }
        }

        private List<string> GetMatchingData(DataRow item, DataTable dt)
        {
            int pcnt = 0;
            string stringToSearch = item["BANK_NAME"].ToString().Replace(".", "");
            string pattern = "";
            bool res = false;

            string md1 = "", md2 = "", md3 = "", ret1 = "", ret2 = "";
            List<string> list = new List<string>();
            //var masterData = item["BANK_NAME"].ToString().Replace(".", "").Split(' ');
            //md1 = SoundexA.Soundex(masterData[0]);
            //int matchCount = 0;

            //if(masterData.Length > 1)
            //    md2 = SoundexA.Soundex(masterData[1]);

            //if (masterData.Length > 2)
            //    md3 = SoundexA.Soundex(masterData[2]);

            foreach (DataRow dr in dt.Rows)
            {
                //var matchData = dr["BANK_NAME"].ToString().Replace(".", "").Split(' ');
                //foreach (var items in matchData)
                //{
                //    string soundex = SoundexA.Soundex(items);
                //    if (soundex == md1 || soundex == md2 || soundex == md3)
                //    {
                //        matchCount++;
                //    }
                //}
                pattern = dr["BANK_NAME"].ToString().Replace(".", "");
                res = FuzzyMatcher.FuzzyMatch(stringToSearch, pattern, out pcnt);
                if (res == true || pcnt >= 70)
                {
                    list.Add(dr["ROW_ID"].ToString());
                    list.Add(dr["BANK_NAME"].ToString());
                    break;
                }
                //matchCount = 0;
            }
            return list;
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

        protected void ShowMasterData(string isAfterMap = "N")
        {
            detailsLabel.Text = "Mapping for: " + GetPartnerName() + " >> " + GetStatic.ReadQueryString("countryName", "") + " >> " + GetStatic.ReadQueryString("paymentTypeName", "");
            payoutPartner.Text = "Bank List For: " + GetPartnerName();
            if (!string.IsNullOrEmpty(GetCountry()) && !string.IsNullOrEmpty(GetPaymentMode()))
            {
                DataTable dt = null;
                if (isAfterMap == "N")
                {
                    dt = GetStatic.ReadSessionAsTable("MasterDataList");
                    if (dt == null)
                    {
                        dt = _dao.GetMasterDataList(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner(), GetNoOfRows());
                    }
                }
                else
                {
                    dt = _dao.GetMasterDataList(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner(), GetNoOfRows());
                }

                if (dt != null || dt.Rows.Count > 0)
                {
                    GetStatic.WriteSessionAsDataTable("MasterDataList", dt);
                    PopulateMasterData(dt);
                }
            }
        }

        private void PopulateMasterData(DataTable dt)
        {
            if (dt.Rows.Count == 0)
            {
                btnDownloadBank.Enabled = true;
                btnLoadFromTemp.Enabled = false;
                btnSaveMapping.Enabled = false;
                btnShowMappedData.Disabled = true;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + item["BANK_NAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["JME_BANK_CODE"].ToString() + "</td>");
                sb.AppendLine("</tr>");
            }
            masterTableBody.InnerHtml = sb.ToString();
        }

        protected string GetCountry()
        {
            return GetStatic.ReadQueryString("country", "");
        }

        protected string GetPartner()
        {
            return GetStatic.ReadQueryString("partner", "");
        }
        protected string GetPartnerName()
        {
            return GetStatic.ReadQueryString("partnerName", "");
        }
        protected string GetCountryName()
        {
            return GetStatic.ReadQueryString("countryName", "");
        }
        protected string GetPaymentTypeName()
        {
            return GetStatic.ReadQueryString("paymentTypeName", "");
        }
        
        protected string GetPaymentMode()
        {
            return GetStatic.ReadQueryString("paymentType", "");
        }

        protected string GetNoOfRows()
        {
            return ddlNoOfBanks.SelectedValue;
        }

        protected void btnLoadFromTemp_Click(object sender, EventArgs e)
        {
            LoadDataFromTemp("");
        }

        protected void LoadDataFromTemp(string sessionId)
        {
            DataTable dt = _dao.GetMasterDownlodList(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner(), sessionId);

            if (dt.Rows.Count > 0 || dt != null)
            {
                StringBuilder sb = new StringBuilder();
                DataTable _masterData = GetStatic.ReadSessionAsTable("MasterDataList");
                foreach (DataRow item in _masterData.Rows)
                {
                    var res = GetMatchingData(item, dt);
                    sb.AppendLine("<tr>");
                    if (res.Count > 0)
                    {
                        sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["MASTER_BANK_ID"].ToString(), "'category' : 'remit-mapBankData'", res[0], res[1] + " | " + res[0]) + "</td>");
                    }
                    else
                    {
                        sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControl(item["MASTER_BANK_ID"].ToString(), "'category' : 'remit-mapBankData'") + "</td>");
                    }
                    sb.AppendLine("<td>" + item["JME_BANK_CODE"].ToString() + "</td>");
                    sb.AppendLine("</tr>");
                }
                tableBody.InnerHtml = sb.ToString();
            }
        }

        protected void btnSaveMapping_Click(object sender, EventArgs e)
        {
            DataTable dt = GetStatic.ReadSessionAsTable("MasterDataList");
            if (dt.Rows.Count == 0 || dt == null)
            {
                return;
            }

            StringBuilder sb = new StringBuilder("<root>");
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<row");
                sb.Append(string.Format(" {0}=\"{1}\"", "MASTER_ID", item["MASTER_BANK_ID"].ToString()));
                sb.Append(string.Format(" {0}=\"{1}\"", "TEMP_ID", Request.Form[item["MASTER_BANK_ID"].ToString() + "_aValue"]));
                sb.Append(" />");
            }
            sb.Append("</root>");

            string xml = sb.ToString();

            _dao.SaveMappingData(GetStatic.GetUser(), xml);
            ShowMasterData("Y");
            LoadDataFromTemp("");
        }

        protected void ddlNoOfBanks_SelectedIndexChanged(object sender, EventArgs e)
        {
            ShowMasterData("Y");
        }
    }
}