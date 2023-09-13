using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageMessage3 : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111900";
        private const string AddEditFunctionId = "10111910";
        private readonly MessageSettingDao _obj = new MessageSettingDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

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
                ////msgType.Items.Add(new ListItem("All",""));
                ////msgType.Items.Add(new ListItem("Send", "S"));
                ////msgType.Items.Add(new ListItem("Receive", "R"));
                ////msgType.Items.Add(new ListItem("Both", "B"));
                //LoadDdl();
            }
        }
        private void LoadDdl()
        {
            // _sl.SetDDL(ref tranType, "exec proc_serviceTypeMaster @flag='l2'", "serviceTypeId", "typeTitle", "", "All");
            _sdd.SetDDL(ref msgType, "SELECT NULL VALUEf,'All' Textf union all select 's','Send' union all select 'r','Receiving' union all select 'b','Both'", "valuef", "textf", "", "All");

        }
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
                       GetStatic.GetRowData(dr, "countryId"), "Select");


            _sdd.SetDDL(ref trasactionType, "EXEC proc_serviceTypeMaster @flag='l2'", "serviceTypeId", "typeTitle",
                      GetStatic.GetRowData(dr, "transactionType"), "All");

            _sdd.SetDDL(ref agent, "Exec [proc_message] @flag='populateAgent',@msgType='" + msgType.Text + "'", "agentId", "agentName",
                    GetStatic.GetRowData(dr, "agentId"), "All");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectByIdMsgBlock3(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            msgType.SelectedValue = dr["msgType"].ToString();
            textarea1.Value = dr["promotionalMsg"].ToString();
            ddlIsActive.SelectedValue = dr["isActive"].ToString();

            PopulateDdl(dr);
            //_sdd.SetDDL(ref country, " EXEC proc_serviceTypeMaster @flag='l2'", "serveiceTypeId", "typeTitle",
            //          GetStatic.GetRowData(dr, "transactionType"), "Select");

            //_sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
            //        GetStatic.GetRowData(dr, "countryId"), "Select");

            //_sdd.SetDDL(ref agent, "Exec [proc_message] @flag='populateAgent',@msgType='" + msgType.Text + "'", "agentId", "agentName",
            //        GetStatic.GetRowData(dr, "agentId"), "Select");
        }

        private void Update()
        {
            DbResult dbResult = _obj.UpdatePromotionalMsg(GetStatic.GetUser(), GetId().ToString(), agent.Text,ddlIsActive.Text,
                                                         textarea1.Value, msgType.Text,country.Text,trasactionType.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListMessage3.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void msgType_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if (msgType.Text != "")
                _sdd.SetDDL(ref agent, "Exec [proc_message] @flag='populateAgent',@msgType=" +_sdd.FilterString(msgType.Text) + "", "agentId", "agentName", "", "All");
            msgType.Focus();
        }
    }
}