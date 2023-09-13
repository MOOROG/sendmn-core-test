using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.ReceivingLimit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private readonly ReceiveTranLimitDao obj = new ReceiveTranLimitDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                    PopulateDataById();
                else
                    PopulateDdl(null);
            }
            MakeNumericTextBox();
            GetStatic.ResizeFrame(Page);
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeAmountTextBox(ref maxLimitAmt);
            Misc.MakeNumericTextbox(ref acLengthFrom);
            Misc.MakeNumericTextbox(ref acLengthTo);
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
            return GetStatic.ReadNumericDataFromQueryString("rtlId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateCountryMaxLimit()
        {
            var maxLimit = obj.GetCountryMaxLimit(GetStatic.GetUser(), GetAgentId().ToString());
            countryMaxLim.Text = GetStatic.ShowDecimal(maxLimit.ToString());
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref sendingCountry, "EXEC proc_countryMaster @flag = 'scl'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "sendingCountry"), "Any");
            sdd.SetDDL(ref tranType, "EXEC proc_dropDownLists @flag = 'recModeByAgentWithCountry', @param = " + sdd.FilterString(GetAgentId().ToString()), "serviceTypeId", "typeTitle",
                       GetStatic.GetRowData(dr, "tranType"), "Select");
            sdd.SetDDL(ref currency, "EXEC proc_dropDownLists @flag = 'currListByAgent', @param = " + sdd.FilterString(GetAgentId().ToString()), "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currency"), "");
            sdd.SetStaticDdl(ref customerType, "4700", GetStatic.GetRowData(dr, "customerType"), "Any");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            maxLimitAmt.Text = dr["maxLimitAmt"].ToString();
            branchSelection.SelectedValue = dr["branchSelection"].ToString();
            benificiaryIdreq.SelectedValue = dr["benificiaryIdReq"].ToString();
            relationshipReq.SelectedValue = dr["relationshipReq"].ToString();
            benificiaryContactReq.SelectedValue = dr["benificiaryContactReq"].ToString();
            acLengthFrom.Text = dr["acLengthFrom"].ToString();
            acLengthTo.Text = dr["acLengthTo"].ToString();
            acNumberType.SelectedValue = dr["acNumberType"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser()
                                            , GetId().ToString()
                                            , GetAgentId().ToString()
                                            , ""
                                            , ""
                                            , sendingCountry.Text
                                            , maxLimitAmt.Text
                                            , ""
                                            , currency.Text
                                            , tranType.Text
                                            , customerType.Text
                                            , branchSelection.Text
                                            , benificiaryIdreq.Text
                                            , relationshipReq.Text
                                            , benificiaryContactReq.Text
                                            , acLengthFrom.Text
                                            , acLengthTo.Text
                                            , acNumberType.Text);
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

        protected void tranType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (tranType.Text != "")
            {
                string scCategory = sdd.GetServiceTypeCategory(tranType.Text);
                if (scCategory == "bank")
                {
                    acShowHide.Visible = true;
                    RequiredFieldValidator4.Enabled = true;
                    RequiredFieldValidator5.Enabled = true;
                }
                else
                {
                    acShowHide.Visible = false;
                    RequiredFieldValidator4.Enabled = false;
                    RequiredFieldValidator5.Enabled = false;
                }
            }
        }

        protected void sendingCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            trcountryLimit.Visible = !(string.IsNullOrWhiteSpace(sendingCountry.Text));
            if (!string.IsNullOrWhiteSpace(sendingCountry.Text))
                PopulateCountryMaxLimit();
        }
    }
}