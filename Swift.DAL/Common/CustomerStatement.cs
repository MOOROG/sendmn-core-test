namespace Swift.DAL.Common
{
    public class CustomerStatement
    {
        public int RowId { get; set; }
        public string TransactionDate { get; set; }
        public string Particular { get; set; }
        public string WalletIn { get; set; }
        public string WalletOut { get; set; }
        public string ClosingAmount { get; set; }
    }
}
