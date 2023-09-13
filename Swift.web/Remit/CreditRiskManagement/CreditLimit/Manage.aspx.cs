using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.CreditLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181200";
        private const string AddEditFunctionId = "20181210";
        private readonly CreditLimitDao obj = new CreditLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
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
            Misc.MakeNumericTextbox(ref limitAmt);
            Misc.MakeNumericTextbox(ref maxLimitAmt);
            Misc.MakeNumericTextbox(ref perTopUpLimit);
            Misc.MakeAmountTextBox(ref limitAmt);
            Misc.MakeAmountTextBox(ref maxLimitAmt);
            Misc.MakeAmountTextBox(ref perTopUpLimit);
            Misc.MakeAmountTextBox(ref todaysAddedMaxLimit);
            Misc.MakeAmountTextBox(ref perToupRequest);
            Misc.MakeAmountTextBox(ref maxTopupRequest);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #region Method

        protected string GetAgentName()
        {
            return "Agent Name : " + sl.GetAgentName(GetAgentId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("crLimitId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
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

            limitAmt.Text = GetStatic.FormatDataForForm(dr["limitAmt"].ToString(), "M");
            maxLimitAmt.Text = GetStatic.FormatDataForForm(dr["maxLimitAmt"].ToString(), "M");
            todaysAddedMaxLimit.Text = GetStatic.FormatDataForForm(dr["todaysAddedMaxLimit"].ToString(), "M");
            perTopUpLimit.Text = GetStatic.FormatDataForForm(dr["perTopUpAmt"].ToString(), "M");
            expiryDate.Text = dr["expiryDate1"].ToString();
            divAuditLog.InnerHtml = sl.GetAuditLog(dr, 2);
            perToupRequest.Text = GetStatic.FormatDataForForm(dr["perToupRequest"].ToString(), "M");
            maxTopupRequest.Text = GetStatic.FormatDataForForm(dr["maxTopupRequest"].ToString(), "M");
            PopulateDdl(dr);
        }

        private void Update()
        {
            if (limitAmt.Text == "0.00" || maxLimitAmt.Text == "0.00" || perTopUpLimit.Text == "0.00" || perToupRequest.Text == "0.00" || maxTopupRequest.Text == "0.00")
            {
                GetStatic.AlertMessage(Page, "Error: 0 value can not be inserted.");
                return;
            }
            if (double.Parse(perTopUpLimit.Text) > double.Parse(maxLimitAmt.Text))
            {
                GetStatic.AlertMessage(Page, "Error: Max Limit must be greater than Per Topup Limit.");
                return;
            }
            if (double.Parse(perToupRequest.Text) > double.Parse(maxTopupRequest.Text))
            {
                GetStatic.AlertMessage(Page, "Error: Max Topup Request must be greater than Per Topup Request.");
                return;
            }

            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(),
                                           currency.Text, limitAmt.Text, perTopUpLimit.Text, maxLimitAmt.Text,
                                           expiryDate.Text, todaysAddedMaxLimit.Text, perToupRequest.Text, maxTopupRequest.Text);
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
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