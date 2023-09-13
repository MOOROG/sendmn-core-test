using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.CreditRiskManagement.TopUpApprove
{
    public partial class ViewDetail : System.Web.UI.Page
    {
        private readonly BalanceTopUpDao _obj = new BalanceTopUpDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                PopulateDataById();
            }
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("btId");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectTopupRequestInfo(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            lblAgentName.Text = dr["agentName"].ToString();
            lblSecurityType.Text = dr["securityType"].ToString();
            lblSecurityValue.Text = GetStatic.FormatData(dr["securityValue"].ToString(), "M");
            lblBaseLimit.Text = GetStatic.FormatData(dr["baseLimit"].ToString(), "M");
            lblMaxLimit.Text = GetStatic.FormatData(dr["maxLimit"].ToString(), "M");
            lblTodaysTopup.Text = GetStatic.FormatData(dr["TodaysTopup"].ToString(), "M");
            lblAvailableBal.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
            txtReqLimit.Text = GetStatic.FormatData(dr["ReqLimit"].ToString(), "M");
            lblCurrBal.Text = GetStatic.FormatData(dr["currBal"].ToString(), "M");
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.Approve(GetStatic.GetUser(), GetId().ToString(), remarks.Text, txtReqLimit.Text);
            ManageMessage(dbResult);
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.Reject(GetStatic.GetUser(), GetId().ToString(), remarks.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page);
                return;
            }
            else
            {
                string mes = GetStatic.ParseResultJsPrint(dbResult);
                mes = mes.Replace("<center>", "");
                mes = mes.Replace("</center>", "");

                string scriptName = "CallBack";
                string functionName = "CallBack('" + mes + "');";
                GetStatic.CallBackJs1(Page, scriptName, functionName);
                Session.Remove("message");
            }
        }
    }
}