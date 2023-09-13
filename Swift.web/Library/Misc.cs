using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.Library
{
    public static class Misc
    {
        #region Methods

        public static string GetMessageForNoRecords()
        {
            return "<span class =\"no-record\">No records</span>";
        }

        public static string DataTableToHtmlTable(ref DataTable dt)
        {
            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"table table-responsive table-bordered table-striped\" cellpadding=\"5\" cellspacing=\"5\" align=\"center\">");
            str.Append("<tr>");
            var cols = dt.Columns.Count;

            for (var i = 0; i < cols; i++)
            {
                str.Append("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                for (var i = 0; i < cols; i++)
                {
                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
                }
                str.Append("</tr>");
            }
            str.Append("</table>");

            return str.ToString();
        }

        public static void BeginForm(string formCaption)
        {
            var htmlCode = new StringBuilder("");

            htmlCode.AppendLine("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"fromTable\" align=\"left\">");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<th colspan=\"4\" class=\"frmTitle\">" + formCaption + " </th>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td>");
            HttpContext.Current.Response.Write(htmlCode.ToString());
            htmlCode.Clear();
        }

        public static void EndForm()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</table>");
            HttpContext.Current.Response.Write(htmlCode.ToString());
            htmlCode.Clear();
        }

        public static void CreateBredCrom(string headerCaption)
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("<table width=\"700px\" border=\"0\" align=\"left\" cellpadding=\"0\" cellspacing=\"0\">");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td align=\"left\" valign=\"top\" class=\"bredCrom\">" + headerCaption + "</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td height=\"10\" class=\"shadowBG\"></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</table>");
            htmlCode.AppendLine("<div style =\"clear:both\"></div>");
            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public static void BeginHeaderForGrid(string headerCaption, string childAlign)
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("<table width=\"100%\" border=\"0\">");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td valign=\"bottom\" class=\"\" valign=\"buttom\">");
            htmlCode.AppendLine("<div class=\"BredCurm\">" + headerCaption + "</div>");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td valign=\"top\" align=\"" + childAlign + "\">");

            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public static void BeginHeaderForGrid(string headerCaption)
        {
            BeginHeaderForGrid(headerCaption, "center");
        }

        public static void EndHeaderForGrid()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</table>");

            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        #region TrackChanges

        public static void EnableTrackChanges(ref System.Web.UI.WebControls.TextBox tb, string hddField)
        {
            tb.Attributes.Add("onkeyup", "return TrackChanges('" + hddField + "');");
            tb.Attributes.Add("onpaste", "return TrackChanges('" + hddField + "');");
        }

        public static void EnableTrackChanges(ref System.Web.UI.WebControls.DropDownList ddl, string hddField)
        {
            ddl.Attributes.Add("onchange", "return TrackChanges('" + hddField + "');");
            ddl.Attributes.Add("onclick", "return TrackChanges('" + hddField + "');");
        }

        #endregion TrackChanges

        #region MakeNumericTextbox

        public static void MakeAmountTextBox(ref System.Web.UI.WebControls.TextBox tb)
        {
            tb.Attributes.Add("onblur", "UpdateComma(this);");
        }

        public static void MakeDisabledTextbox(ref System.Web.UI.WebControls.TextBox tb)
        {
            tb.Enabled = false;
            //tb.BackColor = System.Drawing.Color.Gray;
        }

        public static void MakeNumericTextbox(ref System.Web.UI.WebControls.TextBox tb)
        {
            tb.Attributes.Add("onfocus", "resetInput(this, '0', 1, true);");
            tb.Attributes.Add("onblur", "resetInput(this, '0', 2, true);");
            tb.Attributes.Add("onkeydown", "return numericOnly(this, (event?event:evt), true);");
            tb.Attributes.Add("onpaste", "return manageOnPaste(this);");
        }

        public static void MakeNumericTextbox(ref System.Web.UI.WebControls.TextBox tb, bool allowBlank)
        {
            MakeNumericTextbox(ref tb, allowBlank, false);
        }

        public static void MakeNumericTextbox(ref System.Web.UI.WebControls.TextBox tb, bool allowBlank, bool donotSupportNegative)
        {
            tb.Attributes.Add("onfocus", "resetInput(this, '0', 1, true);");
            tb.Attributes.Add("onblur", "resetInput(this, '0', 2, true, " + (allowBlank ? "true" : "false") + ");");
            tb.Attributes.Add("onkeydown", "return numericOnly(this, (event?event:evt), true, " + (donotSupportNegative ? "true" : "false") + ");");
            tb.Attributes.Add("onpaste", "return manageOnPaste(this);");
        }

        public static void DisableInput(ref System.Web.UI.WebControls.TextBox tb)
        {
            tb.Attributes.Add("onkeydown", "return false;");
            tb.Attributes.Add("onpaste", "return false;");
        }

        public static string MakeNumericTextbox()
        {
            return MakeNumericTextbox("");
        }

        public static string MakeNumericTextbox(string id)
        {
            return MakeNumericTextbox(id, id);
        }

        public static string MakeNumericTextbox(object value)
        {
            return MakeNumericTextbox("", value);
        }

        public static string MakeNumericTextbox(string id, string name)
        {
            return MakeNumericTextbox(id, name, "");
        }

        public static string MakeNumericTextbox(string id, object value)
        {
            return MakeNumericTextbox(id, "", value);
        }

        public static string MakeNumericTextbox(string id, string name, object value)
        {
            return MakeNumericTextbox(id, name, value, "", "");
        }

        public static string MakeNumericTextbox(string id, string name, object value, string attributes, string callBackFunction)
        {
            if (string.IsNullOrEmpty(name))
                name = id;

            var html = new StringBuilder("");
            html.Append("<input type = \"text\"");
            if (!string.IsNullOrEmpty(id))
                html.Append(" id=\"" + id + "\"");
            if (!string.IsNullOrEmpty(name))
                html.Append(" name=\"" + name + "\"");
            if (!string.IsNullOrEmpty((value ?? "").ToString()))
                html.Append(" value=\"" + value + "\"");
            if (!string.IsNullOrEmpty(attributes))
                html.Append(" " + attributes);

            html.Append(" onfocus = \"resetInput(this, '0', 1);" + callBackFunction + "\"");
            html.Append("onblur = \"resetInput(this, '0', 2);" + callBackFunction + "\"");
            html.Append("onkeydown =\"return numericOnly(this, (event?event:evt), true);" + callBackFunction + "\"");
            html.Append("onpaste = \"return false;" + callBackFunction + "\"");

            html.Append(" />");

            return html.ToString();
        }

        public static void MakeIntegerTextbox(ref System.Web.UI.WebControls.TextBox tb, bool allowBlank, bool donotSupportNegative)
        {
            tb.Attributes.Add("onfocus", "resetInput(this, '0', 1, true);");
            tb.Attributes.Add("onblur", "resetInput(this, '0', 2, true, " + (allowBlank ? "true" : "false") + ");");
            tb.Attributes.Add("onkeydown", "return numericOnly(this, (event?event:evt), false, " + (donotSupportNegative ? "true" : "false") + ");");
            tb.Attributes.Add("onpaste", "return false;");
        }

        public static string MakeIntegerTextbox(string id, string name, object value, string attributes, string callBackFunction)
        {
            if (string.IsNullOrEmpty(name))
                name = id;

            var html = new StringBuilder("");
            html.Append("<input type = \"text\"");
            if (!string.IsNullOrEmpty(id))
                html.Append(" id=\"" + id + "\"");
            if (!string.IsNullOrEmpty(name))
                html.Append(" name=\"" + name + "\"");
            if (!string.IsNullOrEmpty((value ?? "").ToString()))
                html.Append(" value=\"" + value + "\"");
            if (!string.IsNullOrEmpty(attributes))
                html.Append(" " + attributes);

            html.Append(" onfocus = \"resetInput(this, '0', 1);" + callBackFunction + "\""); ;
            html.Append(" onblur = \"IntegerOnly(this);" + callBackFunction + "\"");

            html.Append(" />");

            return html.ToString();
        }

        public static string MakeFloatTextbox(string id, string name, object value, string attributes, string callBackFunction)
        {
            if (string.IsNullOrEmpty(name))
                name = id;

            var html = new StringBuilder("");
            html.Append("<input type = \"text\"");
            if (!string.IsNullOrEmpty(id))
                html.Append(" id=\"" + id + "\"");
            if (!string.IsNullOrEmpty(name))
                html.Append(" name=\"" + name + "\"");
            if (!string.IsNullOrEmpty((value ?? "").ToString()))
                html.Append(" value=\"" + value + "\"");
            if (!string.IsNullOrEmpty(attributes))
                html.Append(" " + attributes);

            html.Append(" onfocus = \"resetInput(this, '0', 1);" + callBackFunction + "\""); ;
            html.Append(" onblur = \"FloatOnly(this);" + callBackFunction + "\"");

            html.Append(" />");

            return html.ToString();
        }

        #endregion MakeNumericTextbox

        #region SwiftCloseButton

        public static void SwiftCloseButton()
        {
            SwiftCloseButton((object)null);
        }

        public static void SwiftCloseButton(object id)
        {
            SwiftCloseButton(id, "Close");
        }

        public static void SwiftCloseButton(string text)
        {
            SwiftCloseButton(null, text);
        }

        public static void SwiftCloseButton(object id, string text)
        {
            var html = "";
            if (id != null)
            {
                html += "<input class=\"button\"  id =\"" + id + "\" type = \"button\" value = \"" + text + "\" onclick = \"CloseDialog(null);\">";
            }
            else
            {
                html += "<input class=\"button\" type = \"button\" value = \"" + text + "\" onclick = \"CloseDialog(null);\">";
            }
            HttpContext.Current.Response.Write(html);
        }

        #endregion SwiftCloseButton

        #region SwiftBackButton

        public static void SwiftBackButton()
        {
            SwiftBackButton((object)null);
        }

        public static void SwiftBackButton(object id)
        {
            SwiftBackButton(id, "Back");
        }

        public static void SwiftBackButton(string text)
        {
            SwiftBackButton(null, text);
        }

        public static void SwiftBackButton(object id, string text)
        {
            var html = "";
            if (id != null)
            {
                html += "<input class=\"button\"  id =\"" + id + "\" type = \"button\" value = \"" + text + "\" onclick = \"GoBack();\">";
            }
            else
            {
                html += "<input class=\"button\" type = \"button\" value = \"" + text + "\" onclick = \"GoBack();\">";
            }

            HttpContext.Current.Response.Write(html);
        }

        #endregion SwiftBackButton

        #endregion Methods

        public static string GetIcon(string iconType)
        {
            switch (iconType.ToLower())
            {
                case "edit":
                    return "<img class = \"showHand\" border = \"0\" title = \"Edit\" alt=\"Edit\" src=\"" + GetStatic.GetUrlRoot() + "/images/edit.gif\" />";

                case "ba":
                    return "<img class = \"showHand\" border = \"0\" title = \"Show Bank Account List\" alt=\"Edit\" src=\"" + GetStatic.GetUrlRoot() + "/images/ba.gif\" />";

                case "delete":
                    return "<img class = \"showHand\" border = \"0\" title = \"Delete\" alt=\"Delete\" src=\"" + GetStatic.GetUrlRoot() + "/images/delete.gif\" />";

                case "add":
                    return "<img class = \"showHand\" border = \"0\" title = \"Add\" alt=\"Add\" src=\"" + GetStatic.GetUrlRoot() + "/images/add.gif\"/>";

                case "wait":
                    return "<img class = \"showHand\" border = \"0\" title = \"Waiting for approval\" alt=\"Waiting for approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\"/>";

                case "viewchanges":
                    return "<img class = \"showHand\" border = \"0\" title = \"View Changes\" alt=\"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\"/>";

                case "vd":
                    return "<img class = \"showHand\" border = \"0\" title = \"View Details\" alt=\"View Details\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png\"/>";

                case "file-format":
                    return "<img class = \"showHand\" border = \"0\" title = \"File Format\" alt=\"File Format\" src=\"" + GetStatic.GetUrlRoot() + "/images/file-format.png\"/>";

                case "info":
                    return "<img class = \"showHand\" border = \"0\" title = \"More Info\" alt=\"More Info\" src=\"" + GetStatic.GetUrlRoot() + "/images/info.gif\"/>";

                default:
                    return iconType;
            }
        }

        public static void DisableInput(ref System.Web.UI.WebControls.TextBox tb, string defVal)
        {
            tb.Attributes.Add("onkeydown", "return DisableInput(this, (event?event:evt));");
            if (defVal != null)
            {
                tb.Attributes.Add("value", defVal);
            }
            tb.Attributes.Add("onpaste", "return false;");
        }

        public static string GetIcon(string iconType, string onClickFunction)
        {
            var html = new StringBuilder("<a href=\"#\" onclick = \"" + onClickFunction + "\" >");
            html.Append(GetIcon(iconType));
            html.Append("</a>");
            return html.ToString();
        }

        public static string JQueryCalUtil()
        {
            return @"
                <script type='text/javascript' language='javascript'>
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
                    function EndRequest(sender, args) {
                        if (args.get_error() == undefined) {
                            LoadAllCal();
                        }
                    }
                    LoadAllCal();
                </script> ";
        }
    }
}