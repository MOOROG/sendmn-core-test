using Swift.DAL.BL.Remit.AgentRating;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AgentRating
{
    public partial class print : System.Web.UI.Page
    {
        protected const string GridName = "grid_agentRating";
        private string ViewFunctionId = "20191200,40241100";
        private string AddEditFunctionId = "20191210";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly AgentRatingDao obj = new AgentRatingDao();
        private string type = "";
        private bool ctrlEnable;

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            type = GetStatic.ReadQueryString("type", "").ToLower();

            if (!IsPostBack)
            {
                Authenticate();
                printRatingDetails();
                trratingDetails.Visible = true;

                //trRatingComment.Visible = true;
                trReviewercomment.Visible = true;
                trApproverComment.Visible = true;

                loadgrid(type);
            }
            if (type == "rating" || type == "review" || type == "approve" || type == "print")
                loadgrid(type, true);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void printRatingDetails()
        {
            AgentName.Text = GetStatic.ReadQueryString("aName", "");
            agentBranchName.Text = GetStatic.ReadQueryString("aBranchName", "");
            ReviewPeriod.Text = GetStatic.ReadQueryString("rPeriod", "");

            Reviewedon.Text = GetStatic.ReadQueryString("ron", "");
            Reviewer.Text = GetStatic.ReadQueryString("r", "");

            ratedby.Text = GetStatic.ReadQueryString("ratedby", "");
            ratedOn.Text = GetStatic.ReadQueryString("ratedon", "");

            approvedBy.Text = GetStatic.ReadQueryString("appby", "");
            approvedOn.Text = GetStatic.ReadQueryString("appon", "");
        }

        private void loadgrid(string actionType, bool isPagePostBack = false)
        {
            DataSet ds = null;

            var arDetaildId = GetStatic.ReadQueryString("arId", "");
            var agentId = GetStatic.ReadQueryString("aId", "");
            var agentType = GetStatic.ReadQueryString("atype", "");

            ds = obj.ratingCriteria(GetStatic.GetUser(), agentId, agentType, arDetaildId);

            //ctrlEnable = (!isPagePostBack) ? true : ctrlEnable;

            if (null != ds)
            {
                if (ds.Tables.Count > 2)
                {
                    DataTable scoringCriteria = ds.Tables[2];
                    for (int i = 0; i < scoringCriteria.Rows.Count; i++)
                    {
                        hdnscoringCriteria.Value += scoringCriteria.Rows[i]["scoreTo"].ToString() + ":" + scoringCriteria.Rows[i]["rating"].ToString() + ":";
                    }
                }

                if (!isPagePostBack)
                {
                    string expression = "type = 'C'";
                    DataRow[] drows;
                    drows = ds.Tables[0].Select(expression);

                    if (drows[0]["ratingDate"].ToString() != "")
                    {
                        //ratingComment.InnerText = drows[0]["ratingComment"].ToString();
                        //trRatingComment.Visible = true;
                        ctrlEnable = false;
                    }
                }

                WriteRow(ds, ctrlEnable);
                PrintSummaryTable(ds);
            }
            if (actionType == "riskhistory" || actionType == "approve" || actionType == "print")
            {
                string expression = "type = 'C'";
                DataRow[] drows;
                drows = ds.Tables[0].Select(expression);

                if (drows[0]["reviewedDate"].ToString() != "")
                {
                    trReviewercomment.Visible = true;
                    reviewersComment.InnerText = drows[0]["reviewerComment"].ToString();
                }

                if (drows[0]["approvedDate"].ToString() != "")
                {
                    trApproverComment.Visible = true;

                    approversComment.InnerText = drows[0]["approverComment"].ToString();
                }
            }
        }

        private void WriteRow(DataSet ds, bool ctrlEnable)
        {
            bool isControlReadOnly = true; //(actionType == "rating") ? true : false;

            myData.CssClass = "TBL";
            myData.Rows.Clear();

            // Header
            var tr = new TableRow();
            tr.Style.Add("background-color", "#cccccc");

            var td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "Risk Category";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            tr.Cells.Add(td);

            td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "Scoring";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            tr.Cells.Add(td);

            myData.Rows.Add(tr);

            tr = new TableRow();
            tr.Style.Add("background-color", "#333333");
            td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "";
            tr.Cells.Add(td);

            td = new TableCell();
            td.Text = "Marks (1-5)";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            td.Style.Add(HtmlTextWriterStyle.Color, "white");
            tr.Cells.Add(td);

            td = new TableCell();
            td.Text = "Remarks";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            td.Style.Add(HtmlTextWriterStyle.Color, "white");
            tr.Cells.Add(td);
            myData.Rows.Add(tr);

            int index = 0;
            int subCatIndex = 0;
            var Category = "";
            foreach (DataRow item in ds.Tables[0].Rows)
            {
                index++;

                tr = new TableRow();

                if (item["type"].ToString() == "A")
                {
                    td = new TableCell();
                    td.ColumnSpan = 4;
                    td.Text = item["description"].ToString();
                    Category = item["summaryDescription"].ToString();
                    tr.Style.Add("background-color", "Red");
                    td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
                    td.Style.Add(HtmlTextWriterStyle.Color, "white");
                    td.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
                    tr.Cells.Add(td);

                    subCatIndex = 0;
                }
                else if (item["type"].ToString() == "B")
                {
                    subCatIndex++;

                    string expression = "ParentId = '" + item["ParentId"] + "' and type = 'C'";
                    DataRow[] foundRows;
                    foundRows = ds.Tables[0].Select(expression); // Use the Select method to find all rows matching the filter.

                    td = new TableCell();
                    td.RowSpan = foundRows.Length + 1;
                    td.Text = subCatIndex.IntToLetter();
                    td.CssClass = "tdSubCatIndex";
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.CssClass = "tdContent";
                    td.Text = item["description"].ToString();
                    td.Style.Add("font-weight", "bold");
                    td.Width = 400;
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.Text = "";
                    td.ColumnSpan = 2;
                    td.Width = 200;
                    tr.Cells.Add(td);
                }
                else if (item["type"].ToString() == "C")
                {
                    td = new TableCell();
                    td.CssClass = "tdContent";

                    HiddenField hdnId = new HiddenField();
                    hdnId.Value = item["rowId"].ToString();
                    hdnId.ID = "hdn_" + index.ToString();
                    td.Controls.Add(hdnId);

                    System.Web.UI.HtmlControls.HtmlGenericControl dvContent =
                    new System.Web.UI.HtmlControls.HtmlGenericControl("DIV");
                    dvContent.Style.Add(HtmlTextWriterStyle.Width, "500px");
                    dvContent.Attributes.Add("class", "tdContent");
                    dvContent.InnerHtml = "<i>(" + Convert.ToInt32(item["displayOrder"].ToString()).ToRomanNumeral() + ") " + item["description"].ToString() + "</i>";

                    td.Controls.Add(dvContent);
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.CssClass = "tdddl";
                    var ddl = new DropDownList();
                    ddl.ID = "ddl_" + index.ToString();
                    //ddl.Width = 100;
                    ddl.CssClass = "ddl";
                    ddl.Items.Insert(0, new ListItem("Select", ""));
                    for (int i = 0; i <= 5; i++)
                    {
                        ddl.Items.Insert(i + 1, new ListItem((i).ToString("0.00") + " - " + ((i == 0 || i == 1) ? "Low" : (i == 2 || i == 3) ? "Medium" : "High"), (i).ToString("0.00")));
                    }

                    ddl.SelectedValue = item["score"].ToString();
                    ddl.Enabled = false;
                    td.Controls.Add(ddl);
                    tr.Cells.Add(td);

                    td = new TableCell();
                    var txt = new System.Web.UI.HtmlControls.HtmlGenericControl("DIV");

                    txt.ID = "txt_" + index.ToString();
                    //txt.CssClass = "RemarksTextBox";
                    //txt.TextMode = TextBoxMode.MultiLine;
                    //txt.Rows = 3;
                    txt.InnerText = item["remarks"].ToString();
                    //txt.ReadOnly = true;

                    td.Controls.Add(txt);
                    tr.Cells.Add(td);
                }

                myData.Rows.Add(tr);
            }
            hdnRowsCount.Value = index.ToString();
        }

        private void PrintSummaryTable(DataSet ds)
        {
            Dictionary<string, decimal> CatTotalList = new Dictionary<string, decimal>();

            //string[,] weight = new string[,] { {"","","","" }, { } };

            var catWeightList = new ItemList<string, decimal>();
            //ItemList<string, decimal> subCatTotalList;

            var maxScore = 5;
            var totalMaxScore = 0; // maxScore*itemCount
            decimal totalScore = 0;
            decimal Score = 0;

            string strTable = @" <table runat='server' id='tblSummary' width='300px'>
                                <tr>
                                    <th width='200px' style='text-align: left;'>
                                        Risk Category
                                    </th>
                                    <th width='50px' style='text-align: left;'>
                                        Score
                                    </th>
                                    <th width='50px' style='text-align: left;'>
                                        Rating
                                    </th>
                                </tr>";

            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 1)
            {
                DataTable dtSummary = ds.Tables[1];
                if (dtSummary.Rows.Count > 1)
                {
                    for (int i = 0; i < dtSummary.Rows.Count; i++)
                    {
                        decimal score;
                        decimal ratingScore = 0;

                        if (decimal.TryParse(dtSummary.Rows[i]["score"].ToString(), out score))
                            ratingScore = score;

                        strTable += "<tr class='" + rating(ratingScore).ToLower() + "'><td>";
                        strTable += dtSummary.Rows[i]["riskCategory"].ToString() + "</td><td>";

                        strTable += ratingScore.ToString("0.00") + "</td><td>" + rating(ratingScore) + "</td></tr>";
                    }
                }
            }
            else
            {
                string expression = "type = 'A'";
                DataRow[] Category;
                Category = ds.Tables[0].Select(expression);
                int index = 0;

                foreach (var item in Category)
                {
                    index++;

                    strTable += "<tr><td>";
                    strTable += item["summaryDescription"].ToString() + "</td><td>";

                    catWeightList.Add(item["summaryDescription"].ToString(), Convert.ToDecimal(item["weight"].ToString()));

                    string expression1 = "ParentId Like '" + index.ToString() + ".%' and type = 'B'";
                    DataRow[] SubCategory;
                    SubCategory = ds.Tables[0].Select(expression1);

                    decimal subCatWeight = Convert.ToDecimal(item["weight"].ToString()) / ((SubCategory.Length > 0) ? SubCategory.Length : 1);

                    int subCatIndex = 0;

                    //subCatTotalList = new ItemList<string, decimal>();

                    Dictionary<string, decimal> subCatTotalList = new Dictionary<string, decimal>();

                    foreach (var subCat in SubCategory)
                    {
                        subCatIndex++;

                        expression = "ParentId Like '" + index.ToString() + "." + subCatIndex.ToString() + "' and type = 'C'";
                        DataRow[] foundRows;
                        foundRows = ds.Tables[0].Select(expression);

                        var itemCount = foundRows.Length;
                        totalMaxScore = maxScore * itemCount;

                        decimal subTotal = 0;

                        foreach (var row in foundRows)
                        {
                            if (decimal.TryParse(row["score"].ToString(), out Score))
                                subTotal += Score;
                        }

                        subCatTotalList.Add(subCatIndex.IntToLetter(), (subTotal / totalMaxScore) * subCatWeight);
                    }

                    decimal subCatTotal = 0;

                    foreach (KeyValuePair<string, decimal> kvp in subCatTotalList)
                    {
                        subCatTotal += kvp.Value;
                    }

                    var score = (subCatTotal / Convert.ToDecimal(item["weight"].ToString())) * maxScore;

                    strTable += (score).ToString("0.00") + "</td><td>" + rating(score) + "</td></tr>";
                    totalScore += score * Convert.ToDecimal(item["weight"].ToString()) / 100;
                }

                strTable += "<tr><td>";
                strTable += "Overall " + "</td><td>";

                strTable += (totalScore).ToString("0.00") + "</td><td>" + rating(totalScore) + "</td></tr>";
            }

            strTable += "</table>";

            divSummary.InnerHtml = strTable;

            //DataSet ds1 = ConvertHTMLTablesToDataSet(strTable);
        }

        private string rating(decimal score)
        {
            string result = "";

            string[] scoringCriteria = hdnscoringCriteria.Value.Split(':');

            if (scoringCriteria.Length >= 3)
            {
                if (score <= Convert.ToDecimal(scoringCriteria[0]))
                    result = scoringCriteria[1];
                else if (score <= Convert.ToDecimal(scoringCriteria[2]))
                    result = scoringCriteria[3];
                else if (score > Convert.ToDecimal(scoringCriteria[2]))
                    result = scoringCriteria[5];
            }
            return result;
        }
    }
}