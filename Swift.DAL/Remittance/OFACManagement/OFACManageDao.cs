
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.OFACManagement
{
    public class OFACManagementDao : RemittanceDao
    {


        public DbResult Update(string user
                       , string rowId
                       , string entNum
                       , string name
                       , string vesselType
                       , string address
                       , string city
                       , string state
                       , string zip
                       , string country
                       , string remarks
                       , string dataSource
                     )
        {
            string sql = "EXEC [proc_OFACManualEntry]";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user         = " + FilterString(user);
            sql += ", @rowId        = " + FilterString(rowId);
            sql += ", @entNum       = " + FilterString(entNum);
            sql += ", @name         = " + FilterString(name);
            sql += ", @vesselType   = " + FilterString(vesselType);
            sql += ", @address      = " + FilterString(address);
            sql += ", @city         = " + FilterString(city);
            sql += ", @state        = " + FilterString(state);
            sql += ", @zip          = " + FilterString(zip);
            sql += ", @country      = " + FilterString(country);
            sql += ", @remarks      = " + FilterString(remarks);
            sql += ", @dataSource   = " + FilterString(dataSource);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string OfacId)
        {
            string sql = "EXEC proc_OFACManualEntry";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(OfacId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_OFACManualEntry";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }


}
