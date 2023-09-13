using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.RateMask
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "grid_rateMask";
        private const string ViewFunctionId = "30012000";
        private const string AddEditFunctionId = "30012010";
        private const string ApproveFunctionId = "30012030";
        private const string ApproveFunctionId2 = "";

        private RateMaskDao rm = new RateMaskDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        private string _popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
        public string PopUpParam
        {
            set { _popUpParam = value; }
            get { return _popUpParam; }
        }

        private string _approveText = "<img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /> ";
        public string ApproveText
        {
            set { _approveText = value; }
            get { return _approveText; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeNumericTextbox(ref mulBd);
                Misc.MakeNumericTextbox(ref mulAd);
                //Misc.MakeNumericTextbox(ref divBd);
                //Misc.MakeNumericTextbox(ref divAd);
                GetStatic.PrintMessage(Page);
                PopulateDdl(null);
                LoadGrid();
            }

        }
        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }
        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private string LoadPagingBlock(DataTable dtPaging)
        {
            string pagingTable = "";
            foreach (DataRow row in dtPaging.Rows)
            {
                pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
            }
            return pagingTable;
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<tr><td colspan='20'><table class='table table-responsive table-bordered table-striped'>");
            str.Append("<tr>");
            str.Append("<td nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
            str.Append("<select name=\"ddl_per_page\" onChange=\"submit_form();\">");
            str.Append("<option value=\"10\"" + autoSelect("10", _page_size.ToString()) + ">10</option>");
            str.Append("<option value=\"20\"" + autoSelect("20", _page_size.ToString()) + ">20</option>");
            str.Append("<option value=\"30\"" + autoSelect("30", _page_size.ToString()) + ">30</option>");
            str.Append("<option value=\"40\"" + autoSelect("40", _page_size.ToString()) + ">40</option>");
            str.Append("<option value=\"50\"" + autoSelect("50", _page_size.ToString()) + ">50</option>");
            str.Append("<option value=\"100\"" + autoSelect("100", _page_size.ToString()) + ">100</option>");
            str.Append("</select>&nbsp;&nbsp;per page&nbsp;&nbsp;");
            str.AppendLine("<select name=\"" + GridName + "_ddl_pageNumber\"  onChange=\"nav(this.value);\">");
            int remainder = _total_record % _page_size;
            int total_page = (_total_record - remainder) / _page_size;
            if (remainder > 0)
                total_page++;

            for (var i = 1; i <= total_page; i++)
            {
                str.AppendLine("<option value=\"" + i + "\"" + autoSelect(i.ToString(), _page.ToString()) + ">" + i + "</option>");
            }
            str.Append("</td>");
            str.AppendLine("<td width=\"100%\" align='right'>");

            if (_page > 1)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"nav(" + (_page - 1) + ");\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            if (_page * _page_size < _total_record)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ");\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            str.AppendLine("<a onclick=\"ShowDiv();\" title=\"Add New Record\"><img src='" +
                                    GetStatic.GetUrlRoot() + "/images/add.gif' border='0'></a>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table></td></tr>");


            return str.ToString();
        }

        private void LoadGrid()
        {
            string _page_size = "10";
            string sortd = "ASC";
            int _page = 1;

            if (Request.Form["hdd_curr_page"] != null)
                _page = Convert.ToInt32(Request.Form["hdd_curr_page"].ToString());

            if (Request.Cookies["page_size"] != null)
                _page_size = Request.Cookies["page_size"].Value.ToString();

            if (Request.Form["ddl_per_page"] != null)
                _page_size = Request.Form["ddl_per_page"].ToString();

            Response.Cookies["page_size"].Value = _page_size;

            int page_size = Convert.ToUInt16(_page_size);

            var ds = rm.LoadGrid(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), "currency", sortd, currencyFilter.Text);
            var dtPaging = ds.Tables[0];
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<div class=\"table table-responsive\">");
            html.Append("<table class=\"table table-responsive table-bordered table-striped\">");
            html.Append(LoadPagingBlock(dtPaging));
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" rowspan='2'>S.N.</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" rowspan='2'>Base Currency</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" rowspan='2'>Quote Currency</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" rowspan='2'>Currency Name</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Rate Mask-Multiplication</center></th>");
            //html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Rate Mask-Division</center></th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Send</center></th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" colspan='2'><center>Receive</center></th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\" rowspan='2'>&nbsp;</th>");
            html.Append("<th class=\"headingTH\" nowrap=\"nowrap\" rowspan=\"2\">Last Updated</th>");
            html.Append("</tr>");
            html.Append("<tr>");
            html.Append("<td  class=\"headingTH\" nowrap=\"nowrap\"><center>Before Decimal</center></td>");
            html.Append("<td  class=\"headingTH\" nowrap=\"nowrap\"><center>After Decimal</center></td>");
            //html.Append("<td  class=\"headingTH\" nowrap=\"nowrap\"><center>Before Decimal</center></td>");
            //html.Append("<td  class=\"headingTH\" nowrap=\"nowrap\"><center>After Decimal</center></td>");
            html.Append("<td  class=\"thcoll\" nowrap=\"nowrap\"><center>Min Rate</center></td>");
            html.Append("<td  class=\"thcoll\" nowrap=\"nowrap\"><center>Max Rate</center></td>");
            html.Append("<td  class=\"thpay\" nowrap=\"nowrap\"><center>Min Rate</center></td>");
            html.Append("<td  class=\"thpay\" nowrap=\"nowrap\"><center>Max Rate</center></td>");
            html.Append("</tr>");

            var i = 0;
            int cnt = 0;
            var allowAddEdit = sdd.HasRight(AddEditFunctionId);
            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;
                var id = Convert.ToInt32(dr["rmId"]);
                //html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"oddbg\" onmouseover=\"if(this.className=='oddbg'){this.className='GridOddRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){} else{this.className='oddbg'}\">" : "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"evenbg\" onmouseover=\"if(this.className=='evenbg'){this.className='GridEvenRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){}else{this.className='evenbg'}\">");
                html.Append("<td>" + cnt + "</td>");
                html.Append("<td>" + dr["baseCurrency"] + "</td>");
                html.Append("<td>" + dr["currency"] + "</td>");
                html.Append("<td>" + dr["currencyName"] + "</td>");
                html.Append("<td><center><input onblur=\"ManageMask(" + id + ");\" class='form-control' type=\"text\" id = \"rateMaskMulBd_" + id + "\" maxlength='1' value=\"" + dr["rateMaskMulBd"] + "\"/>" + "</center></td>");
                html.Append("<td><center><input onblur=\"ManageMask(" + id + ");\" class='form-control' type=\"text\" id = \"rateMaskMulAd_" + id + "\" maxlength='1'  value=\"" + dr["rateMaskMulAd"] + "\"/>" + "</center></td>");
                //html.Append("<td><center><input onblur=\"ManageMask(" + id + ");\" class='inputBox' type=\"text\" id = \"rateMaskDivBd_" + id + "\" maxlength='1'  value=\"" + dr["rateMaskDivBd"] + "\"/>" + "</center></td>");
                //html.Append("<td><center><input onblur=\"ManageMask(" + id + ");\" class='inputBox' type=\"text\" id = \"rateMaskDivAd_" + id + "\" maxlength='1'  value=\"" + dr["rateMaskDivAd"] + "\"/>" + "</center></td>");
                html.Append("<td class=\"tdColl\"><center><input class='form-control' type=\"text\" id = \"cMin_" + id + "\" value=\"" + dr["cMin"] + "\"/>" + "</center></td>");
                html.Append("<td class=\"tdColl\"><center><input class='form-control' type=\"text\" id = \"cMax_" + id + "\" value=\"" + dr["cMax"] + "\"/>" + "</center></td>");
                html.Append("<td class=\"tdPay\"><center><input class='form-control' type=\"text\" id = \"pMin_" + id + "\" value=\"" + dr["pMin"] + "\"/>" + "</center></td>");
                html.Append("<td class=\"tdPay\"><center><input class='form-control' type=\"text\" id = \"pMax_" + id + "\" value=\"" + dr["pMax"] + "\"/>" + "</center></td>");

                html.Append("<td nowrap='nowrap'>");
                if (allowAddEdit)
                    html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" disabled=\"disabled\" class=\"buttonDisabled btn btn-primary\" onclick=\"UpdateRate(" + id + ");\" title = \"Confirm Update\" value=\"Update\" />");
                html.Append("</td>");
                html.Append("<td nowrap=\"nowrap\">" + dr["modifiedDate"] + "<br/>" + dr["modifiedBy"] + "</td>");
                html.Append("</tr>");
            }

            html.Append("</table>");
            html.Append("</div>");
            rpt_grid.InnerHtml = html.ToString();
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            var dbResult = rm.Update(GetStatic.GetUser(), hdnratemaskId.Value, "", "", hdnmulBd.Value, hdnmulAd.Value, hdndivBd.Value, hdndivAd.Value, hdnCMin.Value, hdnCMax.Value, hdnPMin.Value, hdnPMax.Value);

            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            GetStatic.PrintMessage(Page);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref baseCurrency, "EXEC proc_currencyMaster @flag = 'bc'", "currencyCode", "currencyCode", "", "Select");
            sdd.SetDDL(ref currency, "EXEC proc_countryCurrency @flag = 'lAll'", "currencyId",
                       "currencyCode", "", "Select");

        }


        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }


        private void Update()
        {
            DbResult dbResult = rm.Update(GetStatic.GetUser(), ratemaskId.Value, baseCurrency.Text,
                                           currency.SelectedItem.Text, mulBd.Text, mulAd.Text, "", "", cMin.Text, cMax.Text, pMin.Text, pMax.Text);
            ManageMessage(dbResult);
            LoadGrid();
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        public static string GetRowData(DataRow dr, string fieldName)
        {
            return GetRowData(dr, fieldName, "");
        }

        public static string GetRowData(DataRow dr, string fieldName, string defValue)
        {
            return dr == null ? defValue : dr[fieldName].ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}