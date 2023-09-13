namespace Swift.web.Library
{
    public class FullName
    {
        private string _firstName;
        private string _middleName;
        private string _lastName1;
        private string _lastName2;

        public string FirstName
        {
            get { return _firstName; }
            set { _firstName = value; }
        }

        public string MiddleName
        {
            get { return _middleName; }
            set { _middleName = value; }
        }

        public string LastName1
        {
            get { return _lastName1; }
            set { _lastName1 = value; }
        }

        public string LastName2
        {
            get { return _lastName2; }
            set { _lastName2 = value; }
        }
    }
}