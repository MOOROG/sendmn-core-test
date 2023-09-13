using Swift.DAL.JMEFundTransfer;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.BillVoucher.JMEFundTransfer
{
    public partial class Setting : System.Web.UI.Page
    {
        RemittanceLibrary rl = new RemittanceLibrary();
        JmeFundTransferDao tdo = new JmeFundTransferDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateDdl();
        }
        private void PopulateDdl()
        {
            rl.SetDDL(ref currency, "Exec proc_dropDownLists @flag = 'JpyOnly'", "currencyCode", "currencyCode", "", "");
        }

        protected void save_Click(object sender, EventArgs e)
        {
            string desc = description.Text.ToString() ;
            string curr = currency.SelectedValue.ToString();
            string dAc = debitAc.Text.ToString();
            string cAc = creditAc.Text.ToString();
            DbResult res = tdo.SaveSetting(GetStatic.GetUser(), desc, curr, dAc, cAc);
            GetStatic.AlertMessage(this.Page, res.Msg);
            EmptyFields();
        }
        private void EmptyFields()
        {
            description.Text = "";
            debitAc.Text = "";
            creditAc.Text = "";
        }
    }
}