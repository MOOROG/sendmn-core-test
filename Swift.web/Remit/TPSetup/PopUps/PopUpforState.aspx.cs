using Swift.API.Common.SyncModel;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.Remittance.SyncDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.TPSetup.PopUps
{
    public partial class PopUpforState : System.Web.UI.Page
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

        private void Authenticate()
        {
            sl.CheckSession();
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            AddressRequest requestObj = new AddressRequest()
            {
                CountryIsoCode = ddlcountryName.SelectedValue,
                ProviderId = ddlApiPartner.SelectedValue,
                MethodType = RequestBy(),
                StateId = GetStateId()
            };

            SyncStateCityTownService serviceObj = new SyncStateCityTownService();
            var response = serviceObj.GetAddressList(requestObj);
            DbResult res = new DbResult();
            if (response.ResponseCode == "0")
            {
                BankBranchDao _dao = new BankBranchDao();
                var responseData = response.Data;
                var xml = ApiUtility.ObjectToXML(responseData);
                if (RequestBy().ToLower() == "state")
                {
                    res = _dao.SyncState(GetStatic.GetUser(), xml, ddlcountryName.SelectedItem.ToString(), ddlApiPartner.SelectedValue);
                }
                else if (RequestBy().ToLower() == "city")
                {
                    res = _dao.SyncCity(GetStatic.GetUser(), xml, ddlcountryName.SelectedItem.ToString(), ddlApiPartner.SelectedValue);
                }
                //else
                //{
                //	res=_dao.SyncTown(GetStatic.GetUser(), xml, ddlcountryName.SelectedItem.ToString(), ddlApiPartner.SelectedValue);
                //}
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
            else
            {
                GetStatic.AlertMessage(this, response.Msg);
            }
        }

        private string RequestBy()
        {
            return GetStatic.ReadQueryString("requestBy", "");
        }

        private string GetStateId()
        {
            var a = GetStatic.ReadQueryString("stateId", "");
            return a;
        }
    }
}