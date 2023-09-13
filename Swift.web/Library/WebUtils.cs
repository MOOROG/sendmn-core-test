using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using System.Collections.Generic;

namespace Swift.web.Library
{
    public static class WebUtils
    {
        public static string LoadSlabGrid(string masterId, string masterIdDesc, string detailIdDesc, string proc)
        {
            var grid = new SwiftGrid();
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("fromAmt", "Amt From", "40", "M"),
                                      new GridColumn("toAmt", "Amt To", "40", "M"),
                                      new GridColumn("pcnt", "Perc", "30", "M"),
                                      new GridColumn("minAmt", "Min Amt", "40", "M"),
                                      new GridColumn("maxAmt", "Max Amt", "40", "M")
                                  };

            grid.GridName = "grd_slab";

            grid.GridType = 1;

            grid.EnableCookie = false;
            grid.EnableFilterCookie = false;
            grid.DisableJsFilter = true;
            grid.DisableSorting = true;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = detailIdDesc;

            grid.AllowEdit = false;
            grid.AllowDelete = false;
            grid.GridWidth = 225;

            string sql = "EXEC " + proc + " @flag = 's', @" + masterIdDesc + " = " + grid.FilterString(masterId);
            grid.SetComma();

            return grid.CreateGrid(sql);
        }
    }
}