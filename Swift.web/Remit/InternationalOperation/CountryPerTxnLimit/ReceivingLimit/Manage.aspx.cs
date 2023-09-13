using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.ReceivingLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181000";
        private const string AddEditFunctionId = "20181010";
        private readonly ReceiveTranLimitDao obj = new ReceiveTranLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref maxLimitAmt);
            Misc.MakeNumericTextbox(ref agMaxLimitAmt);
            Misc.MakeAmountTextBox(ref maxLimitAmt);
            Misc.MakeAmountTextBox(ref agMaxLimitAmt);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #region Method

        protected string GetCountryName()
        {
            return "Country : " + GetCountry();
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rtlId");
        }

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("countryName", "");
        }

        protected string GetCountryId()
        {
            return GetStatic.ReadQueryString("countryId", "");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref sendingCountry, "EXEC proc_countryMaster @flag = 'scl'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "sendingCountry"), "Any");
            LoadReceivingMode(GetCountryId(), GetStatic.GetRowData(dr, "tranType"));
            //sdd.SetDDL3(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
            //           GetStatic.GetRowData(dr, "tranType"), "Any");
            sdd.SetDDL(ref currency, "EXEC proc_countryCurrency @flag = 'l2', @countryId=" + sdd.FilterString(GetCountryId()), "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
            sdd.SetStaticDdl(ref customerType, "4700", GetStatic.GetRowData(dr, "customerType"), "Any");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            maxLimitAmt.Text = dr["maxLimitAmt"].ToString();
            agMaxLimitAmt.Text = dr["agMaxLimitAmt"].ToString();

            branchSelection.SelectedValue = dr["branchSelection"].ToString();
            benificiaryIdreq.SelectedValue = dr["benificiaryIdReq"].ToString();
            relationshipReq.SelectedValue = dr["relationshipReq"].ToString();
            benificiaryContactReq.SelectedValue = dr["benificiaryContactReq"].ToString();

            PopulateDdl(dr);
        }

        private void Update()
        {
            if(Convert.ToDecimal(maxLimitAmt.Text) < 0)
            {
                GetStatic.PrintErrorMessage(Page, "Max limit amount cannot be less than zero");
                return;
            }

            DbResult dbResult = obj.UpdateCountryWise(GetStatic.GetUser()
                                            , GetId().ToString()
                                            , ""
                                            , GetCountryId().ToString()
                                            , ""
                                            , sendingCountry.Text
                                            , maxLimitAmt.Text
                                            , agMaxLimitAmt.Text
                                            , currency.Text
                                            , receivingMode.Text
                                            , customerType.Text
                                            , branchSelection.Text
                                            , benificiaryIdreq.Text
                                            , relationshipReq.Text
                                            , benificiaryContactReq.Text);
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?countryId=" + GetCountryId());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion

        private void LoadReceivingMode(string countryId, string defaultValue)
        {
            sdd.SetDDL(ref receivingMode, "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + sdd.FilterString(countryId), "serviceTypeId", "typeTitle", defaultValue, "Any");
        }
    }
}