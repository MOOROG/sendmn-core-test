using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.CrossRateDecimalMask
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "30012200";
        private const string AddEditFunctionId = "30012210";
        protected const string GridName = "gCrm";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly CrossRateDecimalMaskDao obj = new CrossRateDecimalMaskDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                GetStatic.AlertMessage(Page);
                PopulateDdl();
                LoadGrid();
            }
            //DeleteRow();
        }

        #region QueryString

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref rateMaskAd);
            Misc.MakeNumericTextbox(ref displayUnit);
        }

        #endregion QueryString

        #region method

        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<tr><td colspan='11'><table class=\"table table-striped table-bordered table-responsive\">");
            str.Append("<td width=\"247\" class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
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
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page - 1) + ", '" + GridName + "');\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            if (_page * _page_size < _total_record)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ", '" + GridName + "');\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick
            // = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\" src='" + GetStatic.GetUrlRoot()
            // + "/images/excel.gif' border='0'>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table></td></tr>");

            return str.ToString();
        }

        private string loadPagingBlock(DataTable dtPaging)
        {
            string pagingTable = "";
            foreach (DataRow row in dtPaging.Rows)
            {
                pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
            }
            return pagingTable;
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
            var ds = obj.LoadGrid(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), "cCurrency", sortd, cCurrencyFilter.Text, pCurrencyFilter.Text);
            var dtPaging = ds.Tables[0];
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table class=\"table table-responsive table-striped table-bordered\">");
            html.Append(loadPagingBlock(dtPaging));
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">S.N.</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">Send Currency</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">Receive Currency</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">After Decimal Value</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">Display Unit</th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\"></th>");
            html.Append("<th  class=\"headingTH\" nowrap=\"nowrap\">Last Updated</th>");
            html.Append("</tr>");

            var i = 0;
            int cnt = 0;
            var allowAddEdit = _sl.HasRight(AddEditFunctionId);
            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;
                var id = Convert.ToInt32(dr["crdmId"]);
                //html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onmouseover=\"this.className='GridOddRowOver'\" onmouseout=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onmouseover=\"this.className='GridEvenRowOver'\" onmouseout=\"this.className='evenbg'\">");
                html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"oddbg\" onmouseover=\"if(this.className=='oddbg'){this.className='GridOddRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){} else{this.className='oddbg'}\">" : "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ");\" class=\"evenbg\" onmouseover=\"if(this.className=='evenbg'){this.className='GridEvenRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){}else{this.className='evenbg'}\">");
                html.Append("<td>" + cnt + "</td>");
                html.Append("<td>" + dr["cCurrency"] + "</td>");
                html.Append("<td>" + dr["pCurrency"] + "</td>");
                html.Append("<td><input class=\"form-control\" type=\"text\" id=\"rateMaskAd_" + id + "\" maxlength=\"1\" value=\"" + dr["rateMaskAd"] + "\"/></td>");
                html.Append("<td><input class=\"form-control\" type=\"text\" id=\"displayUnit_" + id + "\" value=\"" + dr["displayUnit"] + "\"/></td>");
                html.Append("<td nowrap='nowrap'>");
                if (allowAddEdit)
                    html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" disabled=\"disabled\" class=\"btn btn-primary m-t-25\" onclick=\"Update(" + id + ")\" value=\"Update\" ValidationGroup=\"\" title = \"Confirm Update\"/>");
                html.Append("</td>");
                html.Append("<td nowrap=\"nowrap\">" + dr["modifiedDate"] + "<br/>" + dr["modifiedBy"] + "</td>");
                html.Append("</tr>");
            }

            html.Append("</table>");
            rpt_grid.InnerHtml = html.ToString();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref cCurrency, "EXEC proc_currencyMaster @flag = 'l2'", "currencyCode", "currencyDesc", "", "All");
            _sl.SetDDL(ref pCurrency, "EXEC proc_currencyMaster @flag = 'l2'", "currencyCode", "currencyDesc", "", "Select");
        }

        private void PopulateDataById()
        {
            var dr = obj.SelectById(GetStatic.GetUser(), hdnCrdmId.Value);
            if (dr == null)
                return;
            cCurrency.Text = dr["cCurrency"].ToString();
            pCurrency.Text = dr["pCurrency"].ToString();
            rateMaskAd.Text = dr["rateMaskAd"].ToString();
            displayUnit.Text = dr["displayUnit"].ToString();
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
            }
        }

        #endregion method

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            Add();
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Add()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), hdnCrdmId.Value, cCurrency.Text, pCurrency.Text, rateMaskAd.Text, displayUnit.Text);
            ManageMessage(dbResult);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), hdnCrdmId.Value, cCurrency.Text, pCurrency.Text, hdnRateMaskAd.Value, hdnDisplayUnit.Value);
            ManageMessage(dbResult);
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}