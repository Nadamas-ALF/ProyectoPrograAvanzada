using System;
using System.Web;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Filtros
{
 
    public class SesionRequeridaAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
 
            if (filterContext.IsChildAction)
            {
                base.OnActionExecuting(filterContext);
                return;
            }

            HttpSessionStateBase Sesion = filterContext.HttpContext.Session;

            if (Sesion != null && Sesion["IdUsuario"] != null)
            {
                base.OnActionExecuting(filterContext);
                return;
            }

            UrlHelper Url = new UrlHelper(filterContext.RequestContext);
            string UrlLogin = Url.Action("Login", "Home");

            if (filterContext.HttpContext.Request.IsAjaxRequest())
            {
                filterContext.Result = new JsonResult
                {
                    Data = new
                    {
                        exitoso = false,
                        requiereLogin = true,
                        mensaje = "Debe iniciar sesión para continuar.",
                        urlLogin = UrlLogin
                    },
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet
                };

                return;
            }

            filterContext.Result = new RedirectResult(UrlLogin);
        }
    }
}
