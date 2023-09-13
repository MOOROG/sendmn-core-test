using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageMessage2 : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
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
            sdd.SetDDL(ref country, "EXEC proc_dropDownLists @flag = 'sCountry'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "countryId"), "All");

            sdd.SetDDL(ref receiveCountry, "EXEC proc_dropDownLists @flag = 'pCountry'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "rCountry"), "All");

            sdd.SetDDL(ref trasactionType, "EXEC proc_serviceTypeMaster @flag='l2'", "serviceTypeId", "typeTitle",
                      GetStatic.GetRowData(dr, "transactionType"), "All");

            sdd.SetDDL(ref agent, "Exec proc_dropDownLists @flag='agent',@country='" + country.Text + "'", "agentId", "agentName",
                   GetStatic.GetRowData(dr, "agentId"), "All");

            sdd.SetDDL(ref recivingAgent, "Exec proc_dropDownLists @flag='agent',@country='" + receiveCountry.Text + "'", "agentId", "agentName",
                   GetStatic.GetRowData(dr, "rAgent"), "All");   
            
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdMsgBlock2(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            PopulateDdl(dr);
            textarea1.Text = dr["countrySpecificMsg"].ToString();
            msgType.Text = dr["msgType"].ToString();
            ddlIsActive.SelectedValue = dr["isActive"].ToString();
            //agent.Text = dr["agentId"].ToString();
            //recivingAgent.Text = dr["rAgent"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateCountrySpecificMsg(GetStatic.GetUser(), GetId().ToString(), country.Text, ddlIsActive.Text,
                                                             textarea1.Text, msgType.Text,agent.Text,trasactionType.Text, receiveCountry.Text,recivingAgent.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListMessage2.aspx");
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

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            sdd.SetDDL(ref agent, "Exec proc_dropDownLists @flag='agent',@country='" + country.Text + "'", "agentId", "agentName", "", "All");
        }

        protected void receiveCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            sdd.SetDDL(ref recivingAgent, "Exec proc_dropDownLists @flag='agent',@country='" + receiveCountry.Text + "'", "agentId", "agentName", "", "All");  
        }

    }
}