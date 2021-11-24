using System.Web;
using System.Web.Mvc;

namespace Dent_Oil_Canning2
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
