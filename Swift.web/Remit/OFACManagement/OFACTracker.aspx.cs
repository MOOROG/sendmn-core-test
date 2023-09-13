using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.OFACManagement;
using Swift.web.Library;

namespace Swift.web.Remit.OFACManagement
{
    public partial class OFACTracker : System.Web.UI.Page
    {
        readonly SwiftLibrary _sl = new SwiftLibrary();
        OFACDao obj = new OFACDao();
        private const string ViewFunctionId = "20199001";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        private string UppercaseFirst(string s)
        {
            // Check for empty string.
            if (string.IsNullOrEmpty(s))
            {
                return string.Empty;
            }
            // Return char and concat substring.
            return char.ToUpper(s[0]) + s.Substring(1);
        }
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            DataTable dt = obj.SearchSDN(GetStatic.GetUser(), name.Text);

            var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");
            string contentValue = "";
            //string searchCriteria = name.Text.Trim().ToUpper().Replace("  ", " ");
            string searchCriteria = name.Text.Trim().ToUpper();
            string strContent = "";
            var strArr = searchCriteria.ToString().Split(' ');
            var arrlen = strArr.Length;

            var cols = dt.Columns.Count;
            if (dt.Rows.Count > 0)
            {
                str.Append("<tr>");
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
                        if(i==1)
                        {
                            contentValue = dr[i].ToString().ToUpper();
                            for (int j = 0; j < arrlen; j++)
                            {
                                if (strArr[j].Length > 3)
                                {
                                    if (j == 0)
                                    {
                                        contentValue = contentValue.Replace(strArr[j], GetStatic.PutRedBackGround(strArr[j]));
                                        contentValue = contentValue.Replace(strArr[j].ToUpper(), GetStatic.PutRedBackGround((strArr[j].ToUpper())));
                                        contentValue = contentValue.Replace(strArr[j].ToLower(), GetStatic.PutRedBackGround((strArr[j].ToLower())));
                                        contentValue = contentValue.Replace(UppercaseFirst(strArr[j]), GetStatic.PutRedBackGround(UppercaseFirst(strArr[j])));
                                    }
                                    else if (j == 1)
                                    {
                                        contentValue = contentValue.Replace(strArr[j], GetStatic.PutYellowBackGround(strArr[j]));
                                        contentValue = contentValue.Replace(strArr[j].ToUpper(), GetStatic.PutYellowBackGround((strArr[j].ToUpper())));
                                        contentValue = contentValue.Replace(strArr[j].ToLower(), GetStatic.PutYellowBackGround((strArr[j].ToLower())));
                                        contentValue = contentValue.Replace(UppercaseFirst(strArr[j]), GetStatic.PutYellowBackGround(UppercaseFirst(strArr[j])));
                                    }
                                    else if (j == 2)
                                    {
                                        contentValue = contentValue.Replace(strArr[j], GetStatic.PutHalfYellowBackGround(strArr[j]));
                                        contentValue = contentValue.Replace(strArr[j].ToUpper(), GetStatic.PutHalfYellowBackGround((strArr[j].ToUpper())));
                                        contentValue = contentValue.Replace(strArr[j].ToLower(), GetStatic.PutHalfYellowBackGround((strArr[j].ToLower())));
                                        contentValue = contentValue.Replace(UppercaseFirst(strArr[j]), GetStatic.PutHalfYellowBackGround(UppercaseFirst(strArr[j])));
                                    }
                                    else
                                    {
                                        contentValue = contentValue.Replace(strArr[j], GetStatic.PutBlueBackGround(strArr[j]));
                                        contentValue = contentValue.Replace(strArr[j].ToUpper(), GetStatic.PutBlueBackGround((strArr[j].ToUpper())));
                                        contentValue = contentValue.Replace(strArr[j].ToLower(), GetStatic.PutBlueBackGround((strArr[j].ToLower())));
                                        contentValue = contentValue.Replace(UppercaseFirst(strArr[j]), GetStatic.PutBlueBackGround(UppercaseFirst(strArr[j])));
                                    }
                                }
                            }

                            //contentValue = contentValue.Replace(searchCriteria, GetStatic.PutYellowBackGround(searchCriteria));

                            //contentValue = contentValue.Replace(SCUpper, GetStatic.PutYellowBackGround(SCUpper));
                            //contentValue = contentValue.Replace(SCLower, GetStatic.PutYellowBackGround(SCLower));
                            //contentValue = contentValue.Replace(SCFirstUpper, GetStatic.PutYellowBackGround(SCFirstUpper));
                           
                            str.Append("<td align=\"left\">" + contentValue + "</td>"); 
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[i] + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
            }
            else
            {
                str.Append("<tr>");
                str.Append("<th align=\"left\">No Record Found!</th>");
                str.Append("</tr>");
            }
           
            str.Append("</table>");

            rpt_grid.InnerHtml = str.ToString();
            
        }

    }
}