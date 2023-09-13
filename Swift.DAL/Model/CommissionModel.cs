using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.Model
{
   public class CommissionModel
    {
        public string ReferralId;
        public string ReferralCode;
        public int PartnerId;
        public decimal CommissionPercent;
        public decimal ForexPercent;
        public decimal FlatTxnWise;
        public decimal NewCustomer;
        public DateTime EffectiveFrom;
        public bool isActive;
        public string ROW_ID;
        public string deductTaxOnSC;
        public string deductPCommOnSC;

    }
}
