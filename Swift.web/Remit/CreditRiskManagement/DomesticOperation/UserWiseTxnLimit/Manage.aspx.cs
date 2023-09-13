using Swift.DAL.BL.Remit.DomesticOperation.UserWiseTxnLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.DomesticOperation.UserWiseTxnLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private readonly UserWiseTxnLimitDao obj = new UserWiseTxnLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                userName.Text = sdd.GetLoginUserName(GetUserId().ToString());
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref sendPerDay);
            Misc.MakeNumericTextbox(ref sendPerTxn);
            Misc.MakeNumericTextbox(ref payPerDay);
            Misc.MakeNumericTextbox(ref payPerTxn);
            Misc.MakeNumericTextbox(ref cancelPerDay);
            Misc.MakeNumericTextbox(ref cancelPerTxn);
        }

        #region Method

        protected string GetUserName()
        {
            return "User's Full Name : " + sdd.GetUserName(GetUserId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("limitId");
        }

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            sendPerDay.Text = GetStatic.FormatData(dr["sendPerDay"].ToString(), "M");
            sendPerTxn.Text = GetStatic.FormatData(dr["sendPerTxn"].ToString(), "M");
            sendTodays.Text = GetStatic.FormatData(dr["sendTodays"].ToString(), "M");

            payPerDay.Text = GetStatic.FormatData(dr["payPerDay"].ToString(), "M");
            payPerTxn.Text = GetStatic.FormatData(dr["payPerTxn"].ToString(), "M");
            payTodays.Text = GetStatic.FormatData(dr["payTodays"].ToString(), "M");

            cancelPerDay.Text = GetStatic.FormatData(dr["cancelPerDay"].ToString(), "M");
            cancelPerTxn.Text = GetStatic.FormatData(dr["cancelPerTxn"].ToString(), "M");
            cancelTodays.Text = GetStatic.FormatData(dr["cancelTodays"].ToString(), "M");
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetUserId().ToString(),
                                           sendPerDay.Text, sendPerTxn.Text, payPerDay.Text, payPerTxn.Text, cancelPerDay.Text, cancelPerTxn.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            //GetStatic.SetMessage(dbResult);
            //if (dbResult.ErrorCode == "0")
            //{
            //    Response.Redirect("List.aspx");
            //}
            //else
            //{
            //    GetStatic.SetMessageBox(Page);
            //}
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