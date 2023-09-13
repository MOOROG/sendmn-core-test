using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.SendingLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private readonly SendTranLimitDao obj = new SendTranLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
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

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref minLimitAmt);
            Misc.MakeNumericTextbox(ref maxLimitAmt);
            Misc.MakeAmountTextBox(ref minLimitAmt);
            Misc.MakeAmountTextBox(ref maxLimitAmt);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #region Method

        protected string GetAgentName()
        {
            return "Agent Name : " + sdd.GetAgentName(GetAgentId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("stlId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref receivingCountry, "EXEC proc_countryMaster @flag = 'rcl'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "receivingCountry"), "Any");
            sdd.SetStaticDdl(ref collMode, "2200", GetStatic.GetRowData(dr, "collMode"), "Any");
            LoadCollMode(GetAgentId().ToString(), GetStatic.GetRowData(dr, "collMode"));
            if (!string.IsNullOrEmpty(receivingCountry.Text))
                LoadReceivingMode(receivingCountry.Text, GetStatic.GetRowData(dr, "tranType"));
            sdd.SetDDL(ref currency, "EXEC proc_dropDownLists @flag = 'currListByAgent', @param = " + sdd.FilterString(GetAgentId().ToString()), "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
            sdd.SetStaticDdl(ref customerType, "4700", GetStatic.GetRowData(dr, "customerType"), "Any");
        }

        private void LoadCollMode(string agentId, string defaultValue)
        {
            sdd.SetDDL(ref collMode, "EXEC proc_dropDownLists @flag = 'collModeByAgent', @param = " + sdd.FilterString(agentId), "valueId", "detailTitle", defaultValue, "Any");
        }

        private void LoadReceivingMode(string countryId, string defaultValue)
        {
            sdd.SetDDL(ref tranType, "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + sdd.FilterString(countryId), "serviceTypeId", "typeTitle", defaultValue, "Any");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            minLimitAmt.Text = GetStatic.FormatData(dr["minLimitAmt"].ToString(), "M");
            minLimitAmt.Text = GetStatic.FormatData(dr["maxLimitAmt"].ToString(), "M");
            PopulateDdl(dr);
            LoadReceivingAgent(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser()
                                            , GetId().ToString()
                                            , GetAgentId().ToString()
                                            , ""
                                            , ""
                                            , receivingCountry.Text
                                            , receivingAgent.Text
                                            , minLimitAmt.Text
                                            , maxLimitAmt.Text
                                            , currency.Text
                                            , collMode.Text
                                            , tranType.Text
                                            , customerType.Text);
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgentId());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion Method

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion Element Method

        private void LoadReceivingAgent(DataRow dr)
        {
            sdd.SetDDL(ref receivingAgent, "EXEC proc_dropDownLists @flag = 'agent', @country=" + sdd.FilterString(receivingCountry.Text), "agentId", "agentName",
                       GetStatic.GetRowData(dr, "receivingAgent"), "Any");
        }

        protected void receivingCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadReceivingAgent(null);
            LoadReceivingMode(receivingCountry.Text, "");
        }
    }
}