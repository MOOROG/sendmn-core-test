using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.include
{
    public partial class CreateSubGL : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private StringBuilder _str = new StringBuilder();
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            LoadSubGL();
            CreateNewSubGL();
        }

        private void LoadSubGL()
        {
            string pId = GetReportParentId();
            var dt = _obj.GetLedgerSubHeader(pId);
            if (dt == null || dt.Rows.Count == 0)
            {
                // GetAccount();
            }
            else
                GetSubGL(dt);

            GetAccount();
            //_str.Append("<div class=\"row\">");
            //foreach (DataRow dr in dt.Rows)
            //{
            //    _str.Append("<div class=\"col-md-12\">");
            //    _str.Append("<ul style='margin-bottom:0'>");
            //    _str.Append("<li>");
            //    _str.Append("<i class='fa fa-files-o' alt='click' style='font-size:14px; color:#666; padding:0 5px;'></i> &nbsp;");
            //    _str.Append("<label>" + dr["acct_id"] + "</label> ");
            //    _str.Append("" + dr["acct_num"] + "-" + dr["acct_name"] + " (" + GetStatic.ShowDecimal(dr["clr_bal_amt"].ToString()) + ")" + "");
            //    _str.Append("<span class=\"action-icon\"><a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\" class=\"btn btn-xs btn-primary\" onclick=\"EditLedgerAcccode('" + dr["acct_id"] + "')\" style=\"text-decoration:none;font-size:12px;\"><i class=\"fa fa-pencil-square-o\"></i></a>&nbsp;&nbsp;&nbsp;<a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Delete\" class=\"btn btn-xs btn-danger\" onclick=\"DeleteLedgerAcccode('" + dr["acct_id"] + "')\" style=\"text-decoration:none;font-size:12px;\"><i class=\"fa fa-trash-o\"></i></a></span>");
            //    _str.Append("</li>");
            //    _str.Append("</ul>");
            //    _str.Append("</div>");
            //    _str.Append("</div>");

            //}

            //CreateNewSubGL();
        }

        private void GetSubGL(DataTable dt)
        {
            _str.Append("<div class=\"row\">");
            // _str.Append("<div class=\"row\">");
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            _str.Append("<ul style='margin-top:-10px'>");
            foreach (DataRow dr in dt.Rows)
            {
                _str.Append("<li style='margin-bottom:-10px; font-size:12px; font-weight: 500;'>");
                _str.Append("<i class='fa fa-files-o' alt='click' style='padding:0 5px;'></i> &nbsp;");
                //_str.Append("<span class='fa fa-files-o'></span>");

                _str.Append("<label>" + dr["gl_code"] + "</label> ");
                _str.Append("<span class=\"action-icon\" onclick=\"ShowReportSubHead('" + dr["gl_code"] + "','tdshow" + dr["gl_code"] + "');\"  style=\"cursor: pointer;  padding:0 10px;\">" + dr["gl_code"] + "-" + dr["gl_desec"] + "(" + dr["tree_sape"] + ")");
                _str.Append("</span><a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\" class=\"btn btn-xs btn-primary\" onclick=\"EditLedger('" + dr["gl_code"] + "','" + GetParentCode() + "')\"  style=\"text-decoration:none;\"><i class=\"fa fa-pencil-square-o\"></i></a>&nbsp;&nbsp;&nbsp;<a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Delete\" class=\"btn btn-xs btn-danger\" onclick=\"DeleteLedger('" + dr["gl_code"] + "')\" style=\"text-decoration:none;\"><i class=\"fa fa-trash-o\"></i></a>");

                _str.Append("</li>");

                //_str.Append("</div>");
                _str.Append("<li style='margin-bottom:-10px; font-size:12px; font-weight: 500;'>");
                _str.Append("<label id=\"tdshow" + dr["gl_code"] + "\" style=\"display:none\" \" >&nbsp;</label>");
                _str.Append("</li>");
            }
            _str.Append("</ul>");
            getSubLedgerGL.InnerHtml = _str.ToString();
        }

        private string GetParentCode()
        {
            string a = GetStatic.ReadQueryString("code", "");
            string b = a.Replace("tdshow", "");
            return b;
        }

        private void CreateNewSubGL()
        {
            var str = new StringBuilder();
            str.Append("<div class=\"row\">");
            //str.Append("<div class=\"col-md-12\">");
            //str.Append("<i class='fa fa-file-o' alt='click' style='font-size:14;'></i>");
            str.Append("<a href=\"#\" onclick=\"ShowMessage('" + GetReportParentId() + "','r" + GetReportParentId() + "')\" style=\"text-decoration:none;font-size:12px;\">New GL</a>");
            str.Append("<a  href=\"#\" onclick=\"ShowMessageSubcodeAccount('" + GetReportParentId() + "')\" style=\"text-decoration:none;font-size:12px; padding:0 5px;\"> New AC</a>");
            //str.Append("<a  href=\"#\" onclick=\"ShowMessageSubcodeAccount('" + GetReportParentId() + "')\" > New AC</a>");
            //str.Append("</div>");
            str.Append("</div>");
            _str.Append("</div>");
            getSubLedgerGL.InnerHtml = _str.ToString();
            newSubDL.InnerHtml = str.ToString();
        }

        private string GetReportParentId()
        {
            return GetStatic.ReadQueryString("q", "");
        }

        private void GetAccount()
        {
            string pId = GetReportParentId();
            var dt = _obj.GetLedgerSubGL(pId);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

            _str.Append("<ul style='margin-top:-10px;'>");

            foreach (DataRow dr in dt.Rows)
            {
                _str.Append("<li style='margin-bottom:-10px; font-size:12px; font-weight: 500;'>");
                _str.Append("<i class='fa fa-file-o' alt='click' style='padding:0 5px;'></i> &nbsp;");
                _str.Append("<label>" + dr["acct_id"] + "</label> ");
                _str.Append("" + dr["acct_num"] + "-" + dr["acct_name"] + " (" + GetStatic.ShowDecimal(dr["clr_bal_amt"].ToString()) + ")" + "");
                _str.Append("<span class=\"action-icon\"><a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\" class=\"btn btn-xs btn-primary\" onclick=\"EditLedgerAcccode('" + dr["acct_id"] + "')\" style=\"text-decoration:none;\"><i class=\"fa fa-pencil-square-o\"></i></a>&nbsp;&nbsp;&nbsp;<a href=\"#\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Delete\" class=\"btn btn-xs btn-danger\" onclick=\"DeleteLedgerAcccode('" + dr["acct_id"] + "')\" style=\"text-decoration:none;\"><i class=\"fa fa-trash-o\"></i></a></span>");
                _str.Append("</li>");
            }

            _str.Append("</ul>");
            CreateNewSubGL();
        }
    }
}