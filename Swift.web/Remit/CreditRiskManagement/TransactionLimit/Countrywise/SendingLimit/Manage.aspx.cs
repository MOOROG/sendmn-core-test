using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.SendingLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "30011400";
        private const string AddEditFunctionId = "30011410";
        private readonly SendTranLimitDao obj = new SendTranLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                MakeNumericTextBox();
                if (GetId() > 0)
                {
                    btnApplyForAllCountry.Visible = false;
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
            Misc.MakeNumericTextbox(ref minLimitAmt);
            Misc.MakeAmountTextBox(ref minLimitAmt);

            Misc.MakeAmountTextBox(ref maxLimitAmt);
            Misc.MakeAmountTextBox(ref maxLimitAmt);
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

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("countryName", "");
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("stlId");
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
            sdd.SetDDL(ref receivingCountry, "EXEC proc_countryMaster @flag = 'rcl'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "receivingCountry"), "Select");

            //sdd.SetStaticDdl3(ref collMode, "2200", GetStatic.GetRowData(dr, "tranType"), "Any");
            LoadCollMode(GetCountryId(), GetStatic.GetRowData(dr, "collMode"));
            LoadReceivingMode(receivingCountry.Text, GetStatic.GetRowData(dr, "tranType"));
            //sdd.SetDDL3(ref receivingMode, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle", GetStatic.GetRowData(dr, "paymentType"), "Any");
            sdd.SetDDL(ref currency, "EXEC proc_countryCurrency @flag = 'l2', @countryId=" + sdd.FilterString(GetCountryId()), "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
            sdd.SetStaticDdl(ref customerType, "4700", GetStatic.GetRowData(dr, "customerType"), "Any");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            minLimitAmt.Text = GetStatic.FormatData(dr["minLimitAmt"].ToString(), "M");
            maxLimitAmt.Text = GetStatic.FormatData(dr["maxlimitAmt"].ToString(), "M");
            PopulateDdl(dr);
        }

        private void LoadCollMode(string countryId, string defaultValue)
        {
            sdd.SetDDL(ref collMode, "EXEC proc_dropDownLists @flag = 'collModeByCountry', @param = " + sdd.FilterString(countryId), "valueId", "detailTitle", defaultValue, "Any");
        }

        private void LoadReceivingMode(string countryId, string defaultValue)
        {
            sdd.SetDDL(ref receivingMode, "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + sdd.FilterString(countryId), "serviceTypeId", "typeTitle", defaultValue, "Any");
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser()
                                            , GetId().ToString()
                                            , ""
                                            , GetCountryId().ToString()
                                            , ""
                                            , receivingCountry.Text
                                            ,""
                                            , minLimitAmt.Text
                                            , maxLimitAmt.Text
                                            , currency.Text
                                            , collMode.Text
                                            , receivingMode.Text
                                            , customerType.Text);
            ManageMessage(dbResult);
        }

        private void ApplyForAllCountry()
        {
            var dbResult = obj.ApplyForAllCountry(GetStatic.GetUser()
                                            , ""
                                            , GetCountryId().ToString()
                                            , ""
                                            , receivingCountry.Text
                                            , minLimitAmt.Text
                                            , maxLimitAmt.Text
                                            , currency.Text
                                            , collMode.Text
                                            , receivingMode.Text
                                            , customerType.Text);
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

        protected void receivingCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadReceivingMode(receivingCountry.Text, "");
            receivingCountry.Focus();
        }

        protected void btnApplyForAllCountry_Click(object sender, EventArgs e)
        {
            ApplyForAllCountry();
        }
    }
}