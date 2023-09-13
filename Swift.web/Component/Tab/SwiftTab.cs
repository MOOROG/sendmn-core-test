using System.Collections.Generic;
using System.Text;

namespace Swift.web.Component.Tab
{
    public class SwiftTab
    {
        public int NoOfTabPerRow { get; set; }
        public List<TabField> TabList { get; set; }

        public string CreateTab()
        {
            var html = new StringBuilder();
            var noOfRows = 1;
            var totalTabs = TabList.Count;
            if (totalTabs > NoOfTabPerRow)
                noOfRows = totalTabs / NoOfTabPerRow + 1;
            else
                NoOfTabPerRow = totalTabs;
            int j = 0;

            for (int i = 0; i < noOfRows; i++)
            {
                html.Append("<div class=\"listtabs\">");
                html.Append("<ul class=\"nav nav-tabs\" role=\"tablist\">");
                int k = j;
                j = 0;
                if (totalTabs > NoOfTabPerRow && k != 0)
                    NoOfTabPerRow = totalTabs - k;
                while (j < NoOfTabPerRow)
                {
                    var tabField = TabList[j + k];
                    var _class = tabField.IsSelected ? "active" : "deactive";
                    var refPage = tabField.RefPage == "" ? "#" : tabField.RefPage;
                    html.Append("<li class=\"" + _class + "\"><a href=\"" + refPage + "\" >" + tabField.TabDesc +
                                "</a></li>");
                    j++;
                }
                html.Append("</ul>");
                html.Append("</div>");
                //html.Append(
                //    "<table class=\"tabs\" width=\"98%\" border=\"0\" align=\"left\" cellpadding=\"0\" cellspacing=\"0\" style=\"clear: both\">");
                //html.Append("<tr>");
                //html.Append("<td height=\"10\">");
                //html.Append("<ul>");
                //int k = j;
                //j = 0;
                //if (totalTabs > NoOfTabPerRow && k != 0)
                //    NoOfTabPerRow = totalTabs - k;
                //while (j < NoOfTabPerRow)
                //{
                //    var tabField = TabList[j + k];
                //    var _class = tabField.IsSelected ? "selected" : "";
                //    var refPage = tabField.RefPage == "" ? "#" : tabField.RefPage;
                //    html.Append("<li><a href=\"" + refPage + "\" class=\"" + _class + "\">" + tabField.TabDesc +
                //                "</a></li>");
                //    j++;
                //}
                //html.Append("</ul>");
                //html.Append("</td>");
                //html.Append("</tr>");
                //html.Append("</table><br/>");
            }
            return html.ToString();
        }
    }
}