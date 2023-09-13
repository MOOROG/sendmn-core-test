using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.include
{
    public partial class CreateGL : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private StringBuilder _str = new StringBuilder();
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            LoadGL();
            CreateNewGL();
        }

        private void LoadGL()
        {
            string pId = GetReportParentId();
            var dt = _obj.GetLedgerSubHeader(pId);
            _str.Append("<div class=\"row\">");
            _str.Append("<ul style='margin-bottom:-10px'>");
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            foreach (DataRow dr in dt.Rows)
            {
                _str.Append("<li style='margin-bottom:-10px'>");
                _str.Append("<i class='fa fa-folder-open' alt='click' style='font-size:14px; color:#FFC300; padding:0 5px;'></i> &nbsp;");
                _str.Append("<label>" + dr["gl_code"] + "</label>");
                // _str.Append("
                // <label>
                // " +DropDownList[]+ "
                // </label>
                // ");

                _str.Append("<span class=\"action-icon\" onclick=\"ShowReportSubHead('" + dr["gl_code"] + "','tdshow" + dr["gl_code"] + "');\" style=\"cursor: pointer; font-size: 14px; padding:0 10px;\">" + dr["gl_code"] + "-" + dr["gl_desec"] + "(" + dr["tree_sape"] + ")");

                _str.Append("</span><a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\" class=\"btn btn-xs btn-primary\" onclick=\"EditLedger('" + dr["gl_code"] + "','" + GetReportParentId() + "')\" style=\"text-decoration:none;font-size:12px;\"><i class=\"fa fa-pencil-square-o\"></i></a>&nbsp;&nbsp;&nbsp;<a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Delete\" class=\"btn btn-xs btn-danger\" onclick=\"DeleteLedger('" + dr["gl_code"] + "')\" style=\"text-decoration:none;font-size:12px;\"><i class=\"fa fa-trash-o\"></i></a>");
                _str.Append("</li>");

                _str.Append("<li>");
                _str.Append("<label id=\"tdshow" + dr["gl_code"] + "\" style=\"display:none\">&nbsp;</label>");
                _str.Append("</li>");
                //_str.Append("</div>");
            }
            _str.Append("</ul>");
            getLedgerGl.InnerHtml = _str.ToString();
        }

        private void CreateNewGL()
        {
            var str = new StringBuilder();
            str.Append("<div class=\"row\">");
            str.Append("<div class=\"col-md-12\">");
            str.Append("<i class='fa fa-files-o' alt='click' style='font-size:12; color:#fff;'></i>");
            str.Append("<a href=\"#\" onclick=\"ShowMessage('" + GetReportParentId() + "','" + GetReportParentId() + "')\" style=\"text-decoration:none;font-size:12px; padding:0 5px;\">New GL</a>");
            //str.Append("<a  href=\"#\" onclick=\"ShowMessageSubcodeAccount('" + GetReportParentId() + "')\" > New AC</a>");
            str.Append("</div>");
            str.Append("</div>");
            _str.Append("</div>");
            newDL.InnerHtml = str.ToString();
        }

        private string GetReportParentId()
        {
            return GetStatic.ReadQueryString("q", "");
        }
    }
}