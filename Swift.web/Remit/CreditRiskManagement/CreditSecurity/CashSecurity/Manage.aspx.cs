using Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.CreditSecurity.CashSecurity
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181400";
        private const string AddEditFunctionId = "20181410";
        private readonly CashSecurityDao obj = new CashSecurityDao();
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
            Misc.MakeNumericTextbox(ref cashDeposit);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #region Method

        protected string GetAgentName()
        {
            return "Agent Name : " + sdd.GetAgentName(GetAgentId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("csId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_currencyMaster @flag = 'bcd'", "currencyId", "currencyCode",
                GetStatic.GetRowData(dr, "currency") == "" ? "1" : GetStatic.GetRowData(dr, "currency"), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            bankName.Text = dr["bankName"].ToString();
            depositAcNo.Text = dr["depositAcNo"].ToString();
            cashDeposit.Text = dr["cashDeposit"].ToString();
            depositedDate.Text = dr["depositedDate1"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(),
                                           depositAcNo.Text, cashDeposit.Text, currency.Text, depositedDate.Text, bankName.Text);
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
                Response.Redirect("List.aspx?agentId=" + GetAgentId());
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