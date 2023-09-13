using Newtonsoft.Json;
using Swift.DAL.APIDataMappingDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.APIDataMapping.BankDataMapping
{
    public partial class ShowMappedData : System.Web.UI.Page
    {
        protected APIMapping _dao = new APIMapping();
        private const string ViewFunctionId = "20201800";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //PopulateList();
                Authenticate();
            }
            GetStatic.PrintMessage(Page);
            PopulateList();
            string MethodName = Request.Form["MethodName"];
            switch (MethodName)
            {
                case "EditMappedData":
                    SaveEditedData();
                    break;
            }

        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        public void PopulateList()
        {
            detailsLabel.Text = "Mapping for: " + GetPartnerName() + " >> " + GetStatic.ReadQueryString("countryName", "") + " >> " + GetStatic.ReadQueryString("paymentTypeName", "");

            DataTable dt = _dao.ShowMappedList(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner());
            if (null == dt || dt.Rows.Count == 0)
            {
                return;
            }

            string stringToSearch = "";
            string pattern = "";
            int pcnt = 0;
            bool res = false;
            string style = "";

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                stringToSearch = item["MASTER_BANK_NAME"].ToString().Replace(".", "");
                pattern = item["BANK_NAME"].ToString().Replace(".", "");
                res = FuzzyMatcher.FuzzyMatch(stringToSearch, pattern, out pcnt);

                string color = "";
                switch (pcnt > 0 && pcnt < 30 ? "1" :
                        pcnt >= 30 && pcnt < 60 ? "2" :
                        pcnt >= 60 && pcnt < 90 ? "3" :
                        pcnt >= 90 ? "4" : "d")
                {
                    case "1":
                        color = "#ff935c";//orange
                        break;

                    case "2":
                        color = "#f9e090";//yellow
                        break;

                    case "3":
                        color = "#1b7fbd";//blue 
                        break;

                    case "4":
                        color = "#47e4bb";//green
                        break;

                    default:
                        color = "#dc5353";//red
                        break;
                }

                style = (!string.IsNullOrEmpty(color)) ? "style=\"background-color: " + color + "; color: white;\"" : "";
                sb.AppendLine("<tr " + style + ">");
                sb.AppendLine("<td>" + item["MASTER_BANK_NAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["JME_BANK_CODE"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.MakeAutoCompleteControlNew(item["JME_BANK_CODE"].ToString(), "'category' : 'remit-mapBankData'", item["BANK_CODE1"].ToString(), item["BANK_NAME"].ToString()) + "</td>");
                //sb.AppendLine("<td>" + item["BANK_NAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["BANK_CODE1"].ToString() + "</td>");
                sb.AppendLine("<td><button class=\"btn btn-dark\" id='edit_" + item["JME_BANK_CODE"].ToString() + "' onclick=Editclicked('" + item["JME_BANK_CODE"].ToString() + "') >Edit</button>&nbsp;&nbsp;<button disabled onclick=\"SavedClicked('" + item["MASTER_BANK_ID"].ToString() + "','" + item["JME_BANK_CODE"].ToString() + "')\" class=\"btn btn-default\" id='save_" + item["JME_BANK_CODE"].ToString() + "'>Save</button></td>");
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
            return GetStatic.ReadQueryString("noOfBanksDDL", "");
        }

        protected void btnSaveMainTable_Click(object sender, EventArgs e)
        {
            DbResult _dbRes = _dao.SaveMainTable(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner());

            if (_dbRes.ErrorCode == "0")
            {
                PopulateList();
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
        }

        protected void SaveEditedData()
        {

            string rowId = Request.Form["hdnEditedRowNumber"];
            string countryName = Request.Form["countryName"];
            string paymentTypeId = Request.Form["paymentTypeId"];
            string apiPartner = Request.Form["apiPartner"];
            string changedBankId = Request.Form["changedBankId"]; 
            DbResult res = _dao.SaveEditedData(GetStatic.GetUser(), rowId, countryName, paymentTypeId, apiPartner, changedBankId);
            if (res.ErrorCode == "0")
            {
                PopulateList();
                GetStatic.AlertMessage(this, res.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, res.Msg);
            }
            Response.ContentType = "application/json";
            Response.Write(JsonConvert.SerializeObject(res));
            Response.End();


        }

    }
}