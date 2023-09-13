using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting.SystemEmailSetup
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10111600";
        private const string AddEditFunctionId = "10111610";
        private readonly SwiftLibrary _sl1 = new SwiftLibrary();
        private SystemEmailSetupDao _dao = new SystemEmailSetupDao();
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

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref country, "EXEC [proc_dropdownLists] @flag = 'countryOp'", "countryName", "countryName",
                GetStatic.GetRowData(dr, "country") == "" || GetStatic.GetRowData(dr, "country") == null ? "Nepal" : GetStatic.GetRowData(dr, "country"), "Select");
            sdd.SetDDL(ref agent, "EXEC [proc_agentMaster] @flag = 'al5'", "agentId", "agentName",
                       GetStatic.GetRowData(dr, "agent"), "Select");
        }

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }

        private void Authenticate()
        {
            _sl1.CheckAuthentication(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = _dao.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            name.Text = dr["name"].ToString();
            email.Text = dr["email"].ToString();
            mobile.Text = dr["mobile"].ToString();

            PopulateDdl(dr);

            if (dr["isCancel"].ToString()=="Yes")
                cancel.Checked = true;

            if (dr["isTrouble"].ToString() == "Yes")
                trouble.Checked = true;

            if (dr["isAccount"].ToString() == "Yes")
                account.Checked = true;

            if (dr["isXRate"].ToString() == "Yes")
                xRate.Checked = true;

            if (dr["isSummary"].ToString() == "Yes")
                summary.Checked = true;

            if (dr["isBonus"].ToString() == "Yes")
                Bonus.Checked = true;

            if (dr["isEodRpt"].ToString() == "Yes")
                eodCash.Checked = true;

            if (dr["isbankGuaranteeExpiry"].ToString() == "Yes")
                bankGuaranteeExpiry.Checked = true;
        }

        private void Update()
        {
            string isCancel = "";
            string isTrouble = "";
            string isAccount = "";
            string isXRate = "";
            string isSummary = "";
            string isBonus = "";
            string isEodRpt = "";
            string isbankGuaranteeExpiry = "";

            if(cancel.Checked == true)
                isCancel = "Yes";
            if(trouble.Checked == true)
                isTrouble = "Yes";
            if (account.Checked == true)
                isAccount = "Yes";
            if (xRate.Checked == true)
                isXRate = "Yes";
            if (summary.Checked == true)
                isSummary = "Yes";
            if (Bonus.Checked == true)
                isBonus = "Yes";
            if (eodCash.Checked == true)
                isEodRpt = "Yes";
            if (bankGuaranteeExpiry.Checked)
                isbankGuaranteeExpiry = "Yes";
       
            DbResult dbResult = _dao.Update(GetStatic.GetUser()
                                , GetId().ToString()
                                , name.Text
                                , email.Text
                                , mobile.Text
                                , agent.Text
                                , isCancel
                                , isTrouble
                                , isAccount
                                , isXRate
                                , isSummary
                                , isBonus
                                , isEodRpt
                                ,isbankGuaranteeExpiry
                                , country.Text
                                );
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

        #endregion
    }
}