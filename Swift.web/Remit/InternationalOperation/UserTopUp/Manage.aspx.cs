using Swift.DAL.BL.Remit.CreditRiskManagement.UserTopUpLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.InternationalOperation.UserTopUp
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "30011300";
        private const string AddEditFunctionId = "30011310";
        private readonly TopUpLimitDao obj = new TopUpLimitDao();
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
            Misc.MakeNumericTextbox(ref limitPerDay);
            Misc.MakeNumericTextbox(ref perTopUpLimit);
        }

        #region Method

        protected string GetUserName()
        {
            return "User's Full Name : " + sdd.GetUserName(GetUserId().ToString());
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
            sdd.SetDDL(ref currency, "EXEC proc_currencyMaster @flag = 'bcl1'", "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdInt(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            limitPerDay.Text = GetStatic.FormatData(dr["limitPerDay"].ToString(), "M");
            perTopUpLimit.Text = GetStatic.FormatData(dr["perTopUpLimit"].ToString(), "M");
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateInt(GetStatic.GetUser(), GetId().ToString(), GetUserId().ToString(),
                                           currency.Text, limitPerDay.Text, perTopUpLimit.Text);
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

        #endregion

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion
    }
}