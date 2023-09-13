using Swift.DAL.APIDataMappingDao;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.APIDataMapping.BankDataMapping
{
    public partial class ShowTmpList : System.Web.UI.Page
    {
        protected APIMapping _dao = new APIMapping();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20201800";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateList();
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        public void PopulateList()
        {
            detailsLabel.Text = "Mapping for: " + GetPartnerName() + " >> " + GetStatic.ReadQueryString("countryName", "") + " >> " + GetStatic.ReadQueryString("paymentTypeName", "");

            DataTable dt = _dao.ShowMissingList(GetStatic.GetUser(), GetCountry(), GetPaymentMode(), GetPartner());
            if (null == dt || dt.Rows.Count == 0)
            {
                return;
            }
            
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td><input type='checkbox' name='bankListName' value='" + item["ROW_ID"].ToString() + "' checked='true'/></td>");
                sb.AppendLine("<td>" + item["BANK_NAME"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["BANK_CODE1"].ToString() + "</td>");
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
        

        protected void btnSaveToMasterTable_Click(object sender, EventArgs e)
        {
            var Ids = Request.Form["bankListName"];
            if (!string.IsNullOrEmpty(Ids))
            {
                var _res = _dao.SaveMissingBanks(GetStatic.GetUser(), Ids, GetPartner());

                GetStatic.AlertMessage(this, _res.Msg);
                PopulateList();
            }
            else
            {
                GetStatic.AlertMessage(this, "Please choose at least on record!");
            }
        }
    }
}