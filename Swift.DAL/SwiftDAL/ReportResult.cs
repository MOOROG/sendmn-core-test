using System.Data;

namespace Swift.DAL.SwiftDAL
{
    public class ReportResult : DbResult
    {
        private DataTable _resultSet;
        private DataSet _result;
        private string _filters;
        private string _reportHead;
        private string _sql;

        public DataSet Result
        {
            set { _result = value; }
            get { return _result; }
        }

        public DataTable ResultSet
        {
            set { _resultSet = value; }
            get { return _resultSet; }
        }

        public string Filters
        {
            set { _filters = value;}
            get { return _filters;}
        }

        public string ReportHead
        {
            set { _reportHead = value; }
            get { return _reportHead; }
        }
        public string Sql
        {
            set { _sql = value; }
            get { return _sql; }
        }
    }
}
