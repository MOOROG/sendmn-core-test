using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ServiceCharge
{
    public partial class ViewScDomestic : Page
    {
        private const string ViewFunctionId = "40112600";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.ResizeFrame(Page);
                PopulateDDL();
                //MakeNumericTextBox();
            }
        }
        private void MakeNumericTextBox()
        {
            //Misc.MakeNumericTextbox(ref sendAmount);
            //Misc.MakeNumericTextbox(ref sendAmount1);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref location, "EXEC proc_zoneDistrictMap @flag ='country'", "locationId", "locationName", "", "Select");
            _sdd.SetDDL(ref bankName, "EXEC proc_agentMaster @flag = 'banklist'", "agentId", "agentName", "", "Select");
           // _sdd.SetDDL2(ref deliveryMethod, "EXEC proc_serviceTypeMaster @flag='l2'", "typeTitle", "", "");
        }

        //protected void location_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (location.Text == "")
        //        district.Text = null;
        //    else
        //        _sdd.SetDDL(ref district, "EXEC proc_zoneDistrictMap @flag = 'd', @apiDistrictCode = '" + location.Text + "'", "districtId", "districtName", "", "");
        //}

        protected void bankName_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (bankName.Text == "")
                bankBranch.Text = "";
            else
                _sdd.SetDDL(ref bankBranch, "EXEC proc_agentMaster @flag = 'bbl', @parentId = '" + bankName.Text + "'", "agentId", "agentName", "", "Select");
        }

        private void LoadGridView()
        {

            var obj = new AgentDao();
            var ds = obj.DisplayMatchAgent(GetStatic.GetUser(), location.Text,sAgent.Value);

            if (ds == null)
            {
                divLoadGrid.Visible = false;
                PrintMessage("Agent not found!");
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<div class='panel panel-default'><div class='panel-heading panel-title'>Search Result</div><div class='panel-body'> <table class='table table-bordered table-condensed' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table></div></div>");
                divLoadGrid.Visible = true;
                divLoadGrid.InnerHtml = str.ToString();
            }
        }
        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }

        protected void btnAgentFind_Click(object sender, EventArgs e)
        {
            LoadGridView();
        }
    }
}