using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.ServiceCharge;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.ServiceCharge.Special
{
    public partial class CopySetup : Page
    {
        private const string ViewFunctionId = "30001000";
        private const string AddEditFunctionId = "30001010";
        private const string DeleteFunctionId = "30001020";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly SscDetailDao obj = new SscDetailDao();
        private StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            GetStatic.SetActiveMenu(ViewFunctionId);
            MakeNumericTextBox();
            if (!IsPostBack)
            {
                PopulateDdl(null);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    LoadMaxAmount();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnOnBlur_Click(object sender, EventArgs e)
        {
            if (pcnt.Text == "0")
                maxAmt.Enabled = false;
            else
                maxAmt.Enabled = true;
            minAmt.Focus();
        }

        #region Method

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref fromAmt);
            Misc.MakeNumericTextbox(ref toAmt);
            Misc.MakeNumericTextbox(ref pcnt);
            Misc.MakeNumericTextbox(ref minAmt);
            Misc.MakeNumericTextbox(ref maxAmt);
            pcnt.Attributes.Add("onblur", "CheckAmt();");
        }

        private void LoadMaxAmount()
        {
            double maxAmount = _sl.GetMaxAmount("sscMasterId", GetDscMasterId(), "sscDetailTemp");
            double startAmt = maxAmount + 0.01;
            fromAmt.Text = startAmt.ToString();
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("SscDetailId");
        }

        protected string GetDscMasterId()
        {
            return GetStatic.ReadNumericDataFromQueryString("SscMasterId").ToString();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sl.HasRight(AddEditFunctionId);
        }


        private void PopulateDdl(DataRow dr)
        {
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectCopyById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            fromAmt.Text = GetStatic.FormatData(dr["fromAmt"].ToString(), "M");
            toAmt.Text = GetStatic.FormatData(dr["toAmt"].ToString(), "M");
            pcnt.Text = GetStatic.FormatData(dr["pcnt"].ToString(), "M");
            minAmt.Text = GetStatic.FormatData(dr["minAmt"].ToString(), "M");
            maxAmt.Text = GetStatic.FormatData(dr["maxAmt"].ToString(), "M");
        }

        private void Update()
        {
            DbResult dbResult = obj.CopyUpdate(GetStatic.GetUser()
                                           , GetId().ToString()
                                           , GetDscMasterId()
                                           , fromAmt.Text
                                           , toAmt.Text
                                           , pcnt.Text
                                           , minAmt.Text
                                           , maxAmt.Enabled == false ? minAmt.Text : maxAmt.Text
                                           , GetStatic.GetSessionId());
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.CopyDelete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            ScriptManager.RegisterStartupScript(this, GetType(), "Callback", "CallBack(' " + mes + "')", true);
        }

        #endregion

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }
    }
}