using Newtonsoft.Json;
using Swift.DAL.JMEFundTransfer;
using Swift.DAL.SwiftDAL;
using Swift.DAL.Treasury;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.BillVoucher.JMEFundTransfer
{
    public partial class FundTransfer : System.Web.UI.Page
    {
        RemittanceLibrary rl = new RemittanceLibrary();
        SwiftLibrary sl = new SwiftLibrary();
        JmeFundTransferDao fdo = new JmeFundTransferDao();
        private string ViewFunctionId = "20153000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                date.Text = DateTime.Now.ToString("yyyy/MM/dd");
                Misc.MakeNumericTextbox( ref amount);
                PopulateDdl();
                string MethodName = Request.Form["MethodName"];

                switch (MethodName)
                {
                    case "SaveTransfer":
                        SaveTransfer();
                        break;
                }
            }
        }
        private void Authenticate()
        {
            rl.HasRight(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            rl.SetDDL(ref currency, "Exec proc_dropDownLists @flag = 'JpyOnly'", "currencyCode", "currencyCode","","");
            sl.SetDDL(ref description, "Exec PROC_FUNDTRANSFER @flag = 'descriptionDdl'", "valueField", "textField", "", "");
        }
        private void SaveTransfer()
        {
            var date = Request.Form["Date"];
            var descritpion = Request.Form["Description"];
            var currency = Request.Form["Currency"];
            var amount = Request.Form["Amount"];
            DbResult res = fdo.SaveFundTranfer(GetStatic.GetUser(), date, descritpion, currency, amount);
            Response.ContentType = "text/plain";
            Response.Write(JsonConvert.SerializeObject(res));
            Response.End();
        }
        
    }
}