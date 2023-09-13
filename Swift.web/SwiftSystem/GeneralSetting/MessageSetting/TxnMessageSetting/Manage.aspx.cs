using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting.TxnMessageSetting
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20231200";
        private const string AddEditFunctionId = "20231210";
        private readonly TxnMessageSettingDao obj = new TxnMessageSettingDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.SetActiveMenu(ViewFunctionId);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }
        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
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

            country.Text = dr["country"].ToString();
            service.Text =  dr["service"].ToString();
            codeDesc.Text = dr["codeDescription"].ToString();
            paymentMethodDesc.Text = dr["paymentMethodDesc"].ToString();
            messageType.SelectedValue = dr["flag"].ToString();
            isActive.SelectedValue = dr["isActive"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), country.Text,
                                           service.Text, codeDesc.Text, paymentMethodDesc.Text,messageType.Text,isActive.Text);
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

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion
    }
}