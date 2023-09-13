using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using Swift.DAL.BL.System.UserManagement;

namespace Swift.web.SwiftSystem.UserManagement.UserApprovalLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10101160";
        private const string AddEditFunctionId = "10101110";

        protected const string GridName = "grd_userLimit";
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly UserLimitDao userLimit = new UserLimitDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //pnl1.Visible = GetMode().ToString() == "0";
                Authenticate();
                GetStatic.SetActiveMenu(ViewFunctionId);
                MakeNumericTextBox();
                PopulateAgentName();
                if (GetUserLimitId() > 0)
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
            Misc.MakeNumericTextbox(ref sendLimit);
            Misc.MakeNumericTextbox(ref payLimit);
        }

        #region QueryString
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        protected long GetUserLimitId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userLimitId");
        }

        protected string GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode").ToString();
        }
        #endregion

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateAgentName()
        {
            DataRow dr = userLimit.SelectById(GetUserId().ToString());
            if (dr == null)
                return;

            lblAgentName.Text = dr["agentName"].ToString();
            lblUserName.Text = dr["userName"].ToString();
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_agentCurrency @flag = 'ucl', @user = " + sdd.FilterString(lblUserName.Text), "currencyId",
                       "currencyCode", GetStatic.GetRowData(dr, "currencyId"), "Select");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if(dbResult.ErrorCode != "0")
            {
                if(GetMode() == "1")
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx?userId=" + GetUserId() + "&userName=" + GetUserName() + "&agentId=" + GetAgentId() + "&mode=" + GetMode());
            }
        }

        private void Update()
        {
            DataRow dr = userLimit.CheckCurrency(GetAgentId().ToString(), currency.Text);
            string currencyType = dr["spFlag"].ToString();
            if (currencyType == "P" && payLimit.Text=="")
            {
                lblMsg.Text = "Enter Pay Limit!";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            if (currencyType == "S" && sendLimit.Text == "")
            {
                lblMsg.Text="Enter Send Limit!";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            if(currencyType == "B")
            {
                if (payLimit.Text == "" || sendLimit.Text == "")
                {
                    lblMsg.Text = "Enter Send & Pay Limits!";
                    lblMsg.ForeColor = System.Drawing.Color.Red;
                    return;
                }
            }

            var dbResult = userLimit.Update(GetUserLimitId()
                                                ,GetStatic.GetUser()
                                                ,GetUserId().ToString()
                                                ,currency.Text
                                                ,sendLimit.Text
                                                ,payLimit.Text
                                                ,isEnable.Text
                                                );
            payLimit.Text = "";
            sendLimit.Text = "";
            currency.Text = "";
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = userLimit.Delete(GetStatic.GetUser(), GetUserLimitId().ToString());
            ManageMessage(dbResult);
        }

        private void PopulateDataById()
        {
            DataRow dr = userLimit.SelectUserLimitById(GetUserLimitId().ToString());
            if (dr == null)
                return;

            sendLimit.Text = dr["sendLimit"].ToString();
            payLimit.Text = dr["payLimit"].ToString();
            isEnable.Text = dr["isEnable"].ToString();
            PopulateDdl(dr);
            ManageSendPayLimitDisplay();
            /*
            if (sendLimit.Text == "0.00")
            {
                sendShow.Visible = false;
            }
            else if (payLimit.Text == "0.00")
            {
                payShow.Visible = false;
            }
            else
            {
                payShow.Visible = true;
                sendShow.Visible = true;
            }
             * */
        }

        protected void currency_SelectedIndexChanged(object sender, EventArgs e)
        {

            if (currency.Text == "")
            {

            }
            else
            {
                ManageSendPayLimitDisplay();
            }
        }

        private void ManageSendPayLimitDisplay()
        {
            DataRow dr = userLimit.CheckCurrency(GetAgentId().ToString(), currency.Text);
            string currencyType = dr["spFlag"].ToString();
            if (currencyType == "P")
            {
                payShow.Visible = true;
                sendShow.Visible = false;
            }
            else if (currencyType == "S")
            {
                payShow.Visible = false;
                sendShow.Visible = true;
            }
            else if (currencyType == "B")
            {
                payShow.Visible = true;
                sendShow.Visible = true;
            }
        }
    }
}