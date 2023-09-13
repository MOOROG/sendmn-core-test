using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace Swift.web.Library
{
    /// <summary>
    /// Summary description for SwiftDao
    /// </summary>
    public class SwiftLibrary : SwiftDao
    {
        public SwiftLibrary()
        {
            // TODO: Add constructor logic here
        }

        public string CreateDynamicDropDownBox(string name, string sql, string valueField, string textField, string defaultValue)
        {
            var html = new StringBuilder("");
            var width = ""; //string.IsNullOrEmpty(width.Trim()) ? "" : " width = \"" + width + "\"";

            var dt = ExecuteDataset(sql).Tables[0];
            html.Append("<select " + width + " name=\"" + name + "\" id =\"" + name + "\" class = \"form-control\">");

            foreach (DataRow row in dt.Rows)
            {
                html.Append("<option value=\"" + row[valueField].ToString() + "\"" + AutoSelect(row[valueField].ToString(), defaultValue) + ">" + row[textField].ToString() + "</option>");
            }

            html.Append("</select>");

            return html.ToString();
        }

        public void SetDefaultDdl(ref DropDownList ddl, string label, bool isClearItem)
        {
            if (isClearItem)
                ddl.Items.Clear();
            var item = new ListItem(label, "");
            ddl.Items.Add(item);
        }

        public void SetList(ref ListBox ddl, string sql, string valueField, string textField)
        {
            var dt = ExecuteDataset(sql).Tables[0];

            ddl.Items.Clear();

            foreach (DataRow row in dt.Rows)
            {
                ListItem item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();
                ddl.Items.Add(item);
            }

            dt.Dispose();
        }

        public void SetDDL(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var ds = ExecuteDataset(sql);
            ListItem item = null;
            if (ds.Tables.Count == 0)
            {
                if (label != "")
                {
                    item = new ListItem(label, "");
                    ddl.Items.Add(item);
                }
                return;
            }
            var dt = ds.Tables[0];

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[valueField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SetDDL2(ref DropDownList ddl, string sql, string textField, string valueToBeSelected, string label)
        {
            var dt = ExecuteDataset(sql).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[textField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SetDDL3(ref DropDownList ddl, string sql, string valueField, string textField, string valueToBeSelected, string label)
        {
            var dt = ExecuteDataset(sql).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void SetStaticDDL(ref DropDownList ddl, string staticId, string valueField, string textField, string valueToBeSelected, string label)
        {
            if (string.IsNullOrWhiteSpace(staticId))
                return;
            var dt = ExecuteDataset("exec proc_dropDownList @FLAG = 'staticDdl',@typeId=" + FilterString(staticId)).Tables[0];
            ListItem item = null;

            ddl.Items.Clear();

            if (label != "")
            {
                item = new ListItem(label, "");
                ddl.Items.Add(item);
            }
            foreach (DataRow row in dt.Rows)
            {
                item = new ListItem();
                item.Value = row[valueField].ToString();
                item.Text = row[textField].ToString();

                if (row[textField].ToString().ToUpper() == valueToBeSelected.ToUpper())
                    item.Selected = true;
                ddl.Items.Add(item);
            }
        }

        public void BeginForm(string formCaption)
        {
            var htmlCode = new StringBuilder("");

            htmlCode.AppendLine("<table class=\"container\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"40%\">");
            htmlCode.AppendLine("<tbody>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td width=\"1%\" class=\"container_tl\"><div></div></td>");
            htmlCode.AppendLine("<td width=\"91%\" class=\"container_tmid\"><div>" + formCaption + "</div></td>");
            htmlCode.AppendLine("<td width=\"8%\" class=\"container_tr\"><div></div></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td class=\"container_l\"></td>");
            htmlCode.AppendLine("<td class=\"container_content\">");

            HttpContext.Current.Response.Write(htmlCode.ToString());
            htmlCode.Clear();
        }

        public void EndForm()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("<td class=\"container_r\"></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("<tr>");
            htmlCode.AppendLine("<td class=\"container_bl\"></td>");
            htmlCode.AppendLine("<td class=\"container_bmid\"></td>");
            htmlCode.AppendLine("<td class=\"container_br\"></td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</tbody>");
            htmlCode.AppendLine("</table>");
            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public void BeginHeaderForGrid(string headerCaption, string childAlign)
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

        public void BeginHeaderForGrid(string headerCaption)
        {
            BeginHeaderForGrid(headerCaption, "center");
        }

        public void EndHeaderForGrid()
        {
            var htmlCode = new StringBuilder("");
            htmlCode.AppendLine("</td>");
            htmlCode.AppendLine("</tr>");
            htmlCode.AppendLine("</table>");

            HttpContext.Current.Response.Write(htmlCode.ToString());

            htmlCode.Clear();
        }

        public string GetLoginUserName(string userId)
        {
            var obj = new SwiftDao();
            return obj.GetSingleResult("SELECT userName FROM applicationUsers WHERE userId = " + obj.FilterString(userId));
        }

        public string GetUserName(string userId)
        {
            var obj = new SwiftDao();
            return
                obj.GetSingleResult("SELECT name = ISNULL(firstName, '') + ISNULL( ' ' + middleName, '')+ ISNULL( ' ' + lastName, '') FROM applicationUsers WITH(NOLOCK) WHERE userId = " +
                                    obj.FilterString(userId));
        }

        public string GetPackageName(string packageId)
        {
            var obj = new SwiftDao();
            return obj.GetSingleResult("select ltrim(rtrim(dbo.[FNAGetDataValue](" + packageId + ")))");
        }

        public bool CheckAuthentication(string functionId)
        {
            CheckSession();

            if (!HasRight(functionId))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetAuthenticationPage());
            }

            return true;
        }

        public void CheckSession()
        {
            var user = GetStatic.GetUser();
            if (string.IsNullOrWhiteSpace(user))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }

            UserPool userPool = UserPool.GetInstance();
            var loggedUser = GetStatic.GetLoggedInUser();
            if (string.IsNullOrWhiteSpace(loggedUser.UserName))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }

            if (!userPool.IsUserExists(GetStatic.GetUser()))
            {
                HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
            }
        }

        public bool HasRight(string functionId)
        {
            var applicationUserDao = new ApplicationUserDao();
            return applicationUserDao.HasRight(functionId, GetStatic.GetUser());
        }

        public int GetSessionTimeOutPeriod()
        {
            var obj = new SwiftDao();
            var res =
                obj.GetSingleResult(@"SELECT sessionTimeOutPeriod FROM applicationUsers WITH(NOLOCK) WHERE userName = " + obj.FilterString(GetStatic.GetUser()));
            return (Convert.ToInt32(res));
        }

        public DataRow GetSessionUserDetail(string username)
        {
            var obj = new SwiftDao();
            var sql = @"EXEC proc_applicationUsers @flag = 'userDetail', @userName = " + obj.FilterString(username);
            var ds = obj.ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #region Grid

        public string CreateGrid(string gridName, string gridWidth, string sql, string rowIdField, bool showCheckBox, bool multiSelect, string columns, string cssClass, string callBackFunction)//, string editPage, bool allowEdit, bool allowDelete, bool allowApprove, string customLink, string customVariableList)
        {
            if (string.IsNullOrEmpty(cssClass))
                cssClass = "TBLReport";

            var html = new StringBuilder();

            var dt = ExecuteDataset(sql).Tables[0];
            var columnList = columns.Split(',');

            html.AppendLine(
                "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\" class=\"" + cssClass + "\" width = \"" +
                gridWidth + "px\" id =\"" + gridName + "_body\">");

            if (showCheckBox)
            {
                var headerFuntion = "SelectAll(this, '" + gridName + "'," + (multiSelect ? "true" : "false") + ");" + callBackFunction;
                html.AppendLine("<th Class=\"" + cssClass + "\" nowrap style = \"cursor:pointer;text-align: center\" onclick =\"" + headerFuntion + "\">" + (multiSelect ? "√" : "×") + "</th>");
            }

            var columnIndexArray = new ArrayList();

            foreach (var str in columnList)
            {
                columnIndexArray.Add(str);
            }

            var columnArray = new ArrayList();
            foreach (DataColumn col in dt.Columns)
            {
                columnArray.Add(col);
            }

            for (var i = 0; i < columnArray.Count; i++)
            {
                if (columns.Trim().Equals(""))
                {
                    html.AppendLine("<th align=\"left\" nowrap >" + columnArray[i] + "</th>");
                }
                else
                {
                    if (columnIndexArray.Contains(i.ToString()))
                    {
                        html.AppendLine("<th align=\"left\" nowrap >" + columnArray[i] + "</th>");
                    }
                }
            }

            html.AppendLine("</tr>");

            var checkBoxFunction = "";

            if (showCheckBox)
            {
                checkBoxFunction = "ManageSelection(this, '" + gridName + "'," + (multiSelect ? "true" : "false") + ");" +
                                   callBackFunction;
            }

            foreach (DataRow row in dt.Rows)
            {
                html.AppendLine("<tr>");
                if (showCheckBox)
                {
                    html.AppendLine("<td align=\"center\"><input type = \"checkbox\" value = \"" +
                                    row[rowIdField.ToLower()] + "\" name =\"" + gridName + "_rowId\" onclick = \"" +
                                    checkBoxFunction + "\"></td>");
                }

                for (var i = 0; i < dt.Columns.Count; i++)
                {
                    var data = row[i].ToString();
                    if (columns.Trim().Equals(""))
                    {
                        html.AppendLine("<td align=\"left\">" + GetStatic.FormatData(data, "") + "</td>");
                    }
                    else
                    {
                        if (columnIndexArray.Contains(i.ToString()))
                        {
                            html.AppendLine("<td align=\"left\">" + GetStatic.FormatData(data, "") + "</td>");
                        }
                    }
                }
                html.AppendLine("</tr>");
            }

            html.AppendLine("</table>");

            return html.ToString();
        }

        #endregion Grid
    }
}