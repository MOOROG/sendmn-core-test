using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.DAL.BL.System.GeneralSettings;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageNewsFeeder : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        private readonly MessageSettingDao obj = new MessageSettingDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceDao _sDao = new RemittanceDao();

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
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "countryId"), "All");

            _sdd.SetStaticDdlTitle(ref userType, "7300", GetStatic.GetRowData(dr, "userType"), "Select");

            _sdd.SetDDL(ref agent, "EXEC [proc_dropDownLists2] @flag = 'agentNewsFeed',@param=" + _sDao.FilterString(country.Text) + "", "agentId", "agentName",
                       GetStatic.GetRowData(dr, "agentId"), "All");

            _sdd.SetDDL(ref branch, "EXEC [proc_dropDownLists2] @flag = 'branchNewsFeed',@param=" + _sDao.FilterString(agent.Text) + "", "agentId", "agentName",
                       GetStatic.GetRowData(dr, "branchId"), "All");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdNewsFeeder(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            country.SelectedValue = dr["countryId"].ToString();
            msgType.SelectedValue = dr["msgType"].ToString();
            agent.SelectedValue = dr["agentId"].ToString();
            branch.SelectedValue = dr["branchId"].ToString();
            textarea1.Text = dr["newsFeederMsg"].ToString();
            ddlIsActive.SelectedValue = dr["isActive"].ToString();

            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateNewsFeeder(GetStatic.GetUser(), GetId().ToString(), country.Text, msgType.Text, agent.Text, branch.Text ,textarea1.Text, ddlIsActive.Text, userType.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListNewsFeeder.aspx");
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

        protected void btnDelete_Click(object sender, EventArgs e)
        {

        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (country.Text != "")
            {
                _sdd.SetDDL(ref agent, "EXEC proc_dropDownLists2 @flag = 'agentNewsFeed',@param=" + _sDao.FilterString(country.Text) + "", "agentId", "agentName", "", "All");
            }
            else
            {
                agent.Text = "";
            }
        }

        protected void agent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (agent.Text != "")
            {
                _sdd.SetDDL(ref branch, "EXEC proc_dropDownLists2 @flag = 'branchNewsFeed',@param=" + _sDao.FilterString(agent.Text) + "", "agentId", "agentName", "", "All");
            }
            else
            {
                branch.Text = "";
            }
        }
    }
}