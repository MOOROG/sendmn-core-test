using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly CustomersDao _obj = new CustomersDao();
        private const string ViewFunctionId = "20111400";
        private const string AddEditFunctionId = "20111410";
        private const string ApproveFunctionId = "20111430";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string GridName = "grdcusgrd";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GetStatic.PrintMessage(Page);
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
            GetStatic.ResizeFrame(Page);
        }

        private void LoadApproveGrid()
        {
            bool allowApprove = _sdd.HasRight(ApproveFunctionId);
            var ds = _obj.GetCustomerUnapproveList(GetStatic.GetUser(), fromDate.Text, toDate.Text, agent.Value, status.Text, isDocUploaded.Text, memId.Text, sZone.Text, agentGrp.Text, district.Text);

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            int cols = dt.Columns.Count;
            int cnt = 0;
            var colIndex = -1;
            sbHead.Append("<table class='table table-responsive table-bordered table-striped' id =\"" + GridName + "_body\">");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<tr>");
                for (int i = 1; i < cols; i++)
                {
                    var filterFunction = "ShowFilter(this, '" + GridName + "', " + (++colIndex) + ");";
                    var sortText = "<span style = \"float:left;cursor:pointer;height:30px;width:100%\" onclick =\"" + filterFunction + "\"><b>" + dt.Columns[i].ColumnName + "</b></span>";
                    sb.Append("<th>" + sortText + "</th>");
                }
                if (allowApprove)
                    sb.Append("<th></th>");
                sb.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sb.AppendLine(cnt % 2 == 1
                                       ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                       : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                    for (int i = 1; i < cols; i++)
                    {
                        sb.Append("<td>" + dr[i] + "</td>");
                    }
                    if (allowApprove)
                        sb.Append("<td><img style='cursor:pointer' title = 'View Details' alt = 'View Details' src = '" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png' onclick = 'ViewDetails(" + dr["customerId"].ToString() + ");' /></td>");
                    sb.Append("</tr>");
                }
            }
            //sbHead.Append("<tr><td colspan='" + cols + "' nowrap='nowrap'>");
            //sbHead.Append("" + dt.Rows.Count.ToString() + "  Customer(s) found :Approve Customer List</td>");
            //sbHead.Append("</tr>");
            sbHead.Append(sb.ToString());
            sbHead.Append("</table>");
            rptGrid.InnerHtml = sbHead.ToString();
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadApproveGrid();
        }

        private void PopulateDdl()
        {
            _sdd.SetDDL(ref agentGrp, "EXEC [proc_dropDownLists] @flag='agent-grp'", "valueId", "detailTitle", "", "All");
        }
    }
}