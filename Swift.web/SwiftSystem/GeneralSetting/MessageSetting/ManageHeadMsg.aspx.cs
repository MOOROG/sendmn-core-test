using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageHeadMsg : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        private const string ApproveRejectFunctionId = "10111130";
        private readonly MessageSettingDao obj = new MessageSettingDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
              
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

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("msgId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "countryId"), "All");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdMsgBlock1(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            textarea1.Text = dr["headMsg"].ToString();
            ddlIsActive.SelectedValue = dr["isActive"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateHeadMsg(GetStatic.GetUser(), GetId().ToString(), country.Text,ddlIsActive.Text, textarea1.Text);
            ManageMessage(dbResult);

        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListHeadMsg.aspx");
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