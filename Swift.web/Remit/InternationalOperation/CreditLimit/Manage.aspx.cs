using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.InternationalOperation.CreditLimit
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "30011000";
        private const string AddEditFunctionId = "30011010";
        private readonly CreditLimitIntDao obj = new CreditLimitIntDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            msg.Visible = false;
            Authenticate();
            if (!IsPostBack)
            {
                expiryDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                expiryDate.Attributes.Add("readonly", "readonly");
                //PopulateAgentAcDetail();
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

        //private void PopulateAgentAcDetail()
        //{
        //    var dr = obj.SelectAgentAcDetail(GetStatic.GetUser(), GetAgentId().ToString());
        //    if (dr == null)
        //        return;
        //    currentBal.Text = GetStatic.FormatData(dr["currentBalance"].ToString(), "M");
        //    currentBalCurr.Text = dr["acBalCurr"].ToString();
        //    currentAvailable.Text = GetStatic.FormatData(dr["currentAvailable"].ToString(), "M");
        //    currentAvailableCurr.Text = dr["acBalCurr"].ToString();
        //    sentCount.Text = dr["todaysSentCount"].ToString();
        //    sentAmount.Text = GetStatic.FormatData(dr["todaysSentAmount"].ToString(), "M");
        //    sentAmountCurr.Text = dr["sentAmountCurr"].ToString();
        //    paidCount.Text = dr["todaysPaidCount"].ToString();
        //    paidAmount.Text = GetStatic.FormatData(dr["todaysPaidAmount"].ToString(), "M");
        //    paidAmountCurr.Text = dr["paidAmountCurr"].ToString();
        //    cancelledCount.Text = dr["todaysCancelledCount"].ToString();
        //    cancelledAmount.Text = GetStatic.FormatData(dr["todaysCancelledAmount"].ToString(), "M");
        //    cancelledAmountCurr.Text = dr["cancelledAmountCurr"].ToString();
        //}
        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref limitAmt);
            Misc.MakeNumericTextbox(ref maxLimitAmt);
            Misc.MakeNumericTextbox(ref perTopUpLimit);
            Misc.MakeAmountTextBox(ref limitAmt);
            Misc.MakeAmountTextBox(ref maxLimitAmt);
            Misc.MakeAmountTextBox(ref perTopUpLimit);
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
        protected long GetAgentCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_dropDownLists2 @flag = 'sCountryWiseCurr',@param=" + GetAgentId() + "", "currencyCode", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            limitAmt.Text = GetStatic.FormatDataForForm(dr["limitAmt"].ToString(), "M");
            maxLimitAmt.Text = GetStatic.FormatDataForForm(dr["maxLimitAmt"].ToString(), "M");
            perTopUpLimit.Text = GetStatic.FormatDataForForm(dr["perTopUpAmt"].ToString(), "M");
            expiryDate.Text = dr["expiryDate1"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(),
                                           currency.Text, limitAmt.Text, perTopUpLimit.Text, maxLimitAmt.Text,
                                           expiryDate.Text);
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
            msg.Visible = true;
            msg.Text = mes;

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        #endregion

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion
    }
}