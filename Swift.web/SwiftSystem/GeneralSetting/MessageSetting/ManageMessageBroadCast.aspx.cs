using System;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageMessageBroadCast : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        readonly MessageBroadCastDao mbcd = new MessageBroadCastDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
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
            return GetStatic.ReadNumericDataFromQueryString("msgBroadCastId");
        }
        private void PopulateDdl(DataRow dr)
        {
            var _sdd = new StaticDataDdl();
            _sdd.SetStaticDdlTitle(ref userType, "7300", GetStatic.GetRowData(dr, "userType"), "All");
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = mbcd.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            country.Text = dr["countryName"].ToString();
            country.Value = dr["countryId"].ToString();
            agent.Text = dr["agentName"].ToString();
            agent.Value = dr["agentId"].ToString();
            branch.Text = dr["branchName"].ToString();
            branch.Value = dr["branchId"].ToString();
            isActive.Text = dr["isActive"].ToString();
            msgTitle.Text = dr["msgTitle"].ToString();
            msgDetail.Text = dr["msgDetail"].ToString();
            PopulateDdl(dr);
        }

        protected void Update()
        {
            DbResult dbResult = mbcd.Update(country.Value, agent.Value, msgDetail.Text ,branch.Value,
                                             isActive.Text, msgTitle.Text, GetStatic.GetUser(), GetId().ToString(),userType.Text);
            ManageMessage(dbResult);
        }

        protected void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListMessageBroadCast.aspx");
            }
            else
                GetStatic.PrintMessage(Page, dbResult);
        }
        #endregion
        #region Element Method

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("ListMessageBroadCast.aspx");
        }

        protected void btnClick_Save(object sender, EventArgs e)
        {
            Update();
        }
        #endregion

      
    }
}