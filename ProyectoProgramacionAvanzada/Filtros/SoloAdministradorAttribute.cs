using System;
using System.Web;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Filtros
{
    /// <summary>
    /// Exige que la sesión activa pertenezca a un usuario con rol
    /// Administrador (Session["NombreRol"]). Si no hay sesión o el
    /// rol no coincide, redirige a Home/Index.
    ///
    /// Disponible para que los controllers administrativos
    /// (Producto, Categoria, PedidoAdmin, Reporte, Usuario
    /// Administracion) lo adopten cuando el equipo lo decida;
    /// reemplazaría sus validaciones manuales de rol repetidas.
    /// No se aplicó a esos controllers en esta fase para no
    /// invadir módulos ajenos sin acuerdo previo.
    /// </summary>
    public class SoloAdministradorAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            HttpSessionStateBase Sesion = filterContext.HttpContext.Session;

            bool EsAdministrador = Sesion != null &&
                string.Equals(
                    Sesion["NombreRol"] as string,
                    "Administrador",
                    StringComparison.OrdinalIgnoreCase
                );

            if (EsAdministrador)
            {
                base.OnActionExecuting(filterContext);
                return;
            }

            UrlHelper Url = new UrlHelper(filterContext.RequestContext);

            filterContext.Result = new RedirectResult(
                Url.Action("Index", "Home")
            );
        }
    }
}
