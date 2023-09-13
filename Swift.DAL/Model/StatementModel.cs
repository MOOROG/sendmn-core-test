using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.Model
{
    public class StatementModel
    {
        public string tran_particular { get; set; }
        public string fcy_Curr { get; set; }
        public string tran_amt { get; set; }
        public string usd_amt { get; set; }
        public string ref_num { get; set; }
        public string tran_date { get; set; }
        public string acc_num { get; set; }
        public string tran_type { get; set; }
        public string part_tran_type { get; set; }
        public string dt { get; set; }
        public bool hasRight { get; set; }
    }
}
