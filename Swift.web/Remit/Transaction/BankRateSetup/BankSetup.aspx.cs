using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.BankRateSetup
{
    public partial class BankSetup : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20173000";
        private const string EditFunctionId = "20173010";
        ExRateDao _exrateDao = new ExRateDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {            
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeNumericTextbox(ref sc);
                Misc.MakeNumericTextbox(ref custRate);
                PopulateData();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
            changePass.Enabled = _sdd.CheckAuthentication(EditFunctionId);
        }

        private void PopulateData()
        {
            DataRow dr = _exrateDao.GetBankExrateData();

            if (dr == null)
            {
                return;
            }

            custRate.Text = dr["customerRate"].ToString();
            sc.Text = GetStatic.ShowDecimal(dr["serviceCharge"].ToString());
        }

        protected void changePass_Click(object sender, EventArgs e)
        {
            DbResult _res = _exrateDao.UpdateRate(custRate.Text, sc.Text, GetStatic.GetUser());
            if (_res.ErrorCode == "0")
            {
                PopulateData();    
            }
            GetStatic.AlertMessage(this, _res.Msg);
        }
    }
}