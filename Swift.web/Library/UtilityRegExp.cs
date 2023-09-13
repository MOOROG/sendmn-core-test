using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Swift.web.Library
{
    public class UtilityRegExp
    {
        /// <summary>
        /// <para>A Regular Expression to Match any null Json object in a string</para>
        /// <para>like "Samaj_Shekhar":null,</para>
        /// <para>Useful in removing nulls from serialized Json string</para>
        /// </summary>
        public static string JsonNullRegEx = "[\"][a-zA-Z0-9_]*[\"]:null[ ]*[,]?";

        /// <summary>
        /// <para>A Regular Expression to Match an array of null Json object in a string</para>
        /// <para>like [null, null]</para>
        /// <para>Useful in removing null array from serialized Json string</para>
        /// </summary>
        public static string JsonNullArrayRegEx = "\\[( *null *,? *)*]";

        /// <summary>
        /// <para>A Regular Expression to Match an Email Address</para>
        /// <para>Useful in validating email addresses</para>
        /// </summary>
        public static string ValidEmailRegEx = @"^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$";
    }
}