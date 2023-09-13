using Swift.DAL.SwiftDAL;
using System.Collections;
using System.Collections.Generic;
using System.Data;

namespace Swift.DAL.Remittance
{
    public class RemittanceGridDao : RemittanceDao
    {
        public ArrayList GetGridDataSource(string sql, bool hasFilter, bool loadGridOnFilterOnly)
        {
            var dataSource = new ArrayList();
            var columnList = new ArrayList();
            List<Hashtable> rows = null;
            DataSet ds;
            if (loadGridOnFilterOnly)
            {

                if (hasFilter)
                {
                    ds = ExecuteDataset(sql);

                    dataSource.Add(ds.Tables[0].Rows[0]["totalRow"].ToString());

                    rows = new List<Hashtable>();

                    foreach (DataRow dataRow in ds.Tables[1].Rows)
                    {
                        var row = new Hashtable();
                        foreach (DataColumn dataColumn in ds.Tables[1].Columns)
                        {
                            var columnName = dataColumn.ColumnName;
                            columnList.Add(columnName);
                            row.Add(columnName.ToLower().Replace(' ', '_'), dataRow[columnName].ToString());
                        }
                        rows.Add(row);
                    }
                    dataSource.Add(rows);
                    dataSource.Add(columnList);
                }
                else
                {
                    dataSource.Add("0");
                    dataSource.Add(null);
                    dataSource.Add(null);
                }
            }
            else
            {
        sql = sql.Replace("@searchValue = ", "@searchValue = N");
        ds = ExecuteDataset(sql);

                dataSource.Add(ds.Tables[0].Rows[0]["totalRow"].ToString());

                rows = new List<Hashtable>();

                foreach (DataRow dataRow in ds.Tables[1].Rows)
                {
                    var row = new Hashtable();
                    foreach (DataColumn dataColumn in ds.Tables[1].Columns)
                    {
                        var columnName = dataColumn.ColumnName;
                        columnList.Add(columnName);
                        row.Add(columnName.ToLower().Replace(' ', '_'), dataRow[columnName].ToString());
                    }
                    rows.Add(row);
                }
                dataSource.Add(rows);
                dataSource.Add(columnList);
            }
            return dataSource;
        }
    }
}
