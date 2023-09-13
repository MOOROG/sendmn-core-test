using Swift.API.Common.SyncModel;
using Swift.API.Common.SyncModel.Bank;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.Remittance.SyncDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.PopUps
{
    public partial class PopUpForBank : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
            }
        }

        private void PopulateDDL()
        {
            sl.SetDDL(ref ddlApiPartner, "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'API-PARTNER',@user='" + GetStatic.GetUser() + "'", "value", "text", "", "Select..");
            sl.SetDDL(ref ddlcountryName, "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'countryList',@user='" + GetStatic.GetUser() + "'", "value", "text", "", "Select..");
        }

    protected void ddlCountryChanged(object sender, EventArgs e) {
      sl.SetDDL(ref ddlCurrency, "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'currencyList',@user='" + GetStatic.GetUser() + "', @CntryCode = '" + ddlcountryName.SelectedValue +"'", "value", "text", "", "Select..");
    }

        private void Authenticate()
        {
            sl.CheckSession();
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            BankRequest requestObj = new BankRequest()
            {
                CountryCode = ddlcountryName.SelectedValue,
                ProviderId = ddlApiPartner.SelectedValue,
              CurrencyCode = ddlCurrency.SelectedValue
            };

            SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
            var response = serviceObj.GetBankList(requestObj);
            if (response.ResponseCode == "0")
            {
                BankBranchDao _dao = new BankBranchDao();
                var responseData = response.Data;
                var xml = ApiUtility.ObjectToXML(responseData);
                DbResult res = _dao.SyncBank(GetStatic.GetUser(), xml, ddlcountryName.SelectedItem.ToString(), ddlApiPartner.SelectedValue);
                if (res.ErrorCode == "0")
                {
                    GetStatic.AlertMessage(this, res.Msg);
                    GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + res + "');");
                }
                else
                {
                    GetStatic.AlertMessage(this, "Bank Sycn Failed!!!!");
                }
            }
        }
    }
}