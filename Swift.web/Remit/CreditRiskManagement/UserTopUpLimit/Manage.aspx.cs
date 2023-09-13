using Swift.DAL.BL.Remit.CreditRiskManagement.UserTopUpLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.UserTopUpLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181300";
        private const string AddEditFunctionId = "20181310";
        private readonly TopUpLimitDao obj = new TopUpLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                lblUserName.Text = GetUserName();
                if (GetId() > 0)
                    PopulateDataById();
                else
                    PopulateDdl(null);
            }
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref limitPerDay);
            Misc.MakeNumericTextbox(ref perTopUpLimit);
            Misc.MakeNumericTextbox(ref maxCreditLimitForAgent);
        }

        #region Method

        protected string GetUserName()
        {
            return sdd.GetUserName(GetUserId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("tulId");
        }

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_currencyMaster @flag = 'bcl'", "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            limitPerDay.Text = GetStatic.FormatData(dr["limitPerDay"].ToString(), "M");
            perTopUpLimit.Text = GetStatic.FormatData(dr["perTopUpLimit"].ToString(), "M");
            if (dr["maxCreditLimitForAgent"].ToString() == "")
                maxCreditLimitForAgent.Text = GetStatic.FormatData("0", "M");
            else
                maxCreditLimitForAgent.Text = GetStatic.FormatData(dr["maxCreditLimitForAgent"].ToString(), "M");
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetUserId().ToString(),
                                           currency.Text, limitPerDay.Text, perTopUpLimit.Text, maxCreditLimitForAgent.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion Method

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion Element Method
    }
}