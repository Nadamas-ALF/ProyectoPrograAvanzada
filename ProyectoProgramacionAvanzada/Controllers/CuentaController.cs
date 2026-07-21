using ProyectoProgramacionAvanzada.Filtros;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{

    [SesionRequerida]
    public class CuentaController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                var Modelo = new CuentaViewModel();

                using (var Servicio = new UsuarioService())
                {
                    Modelo.Usuario =
                        Servicio.ConsultarUsuarioPorId(IdUsuario);

                    Modelo.Direcciones = Servicio
                        .ConsultarDirecciones(IdUsuario)
                        .Where(Direccion => string.Equals(
                            Direccion.NombreEstado,
                            "Activo",
                            StringComparison.OrdinalIgnoreCase))
                        .ToList();
                }

                if (Modelo.Usuario == null)
                {
                    return RedirectToAction("Login", "Home");
                }

                return View(Modelo);
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CuentaController",
                    "Index",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar su cuenta. Intente nuevamente.";

                return RedirectToAction("Index", "Home");
            }
        }

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion,
            string UsuarioSistema)
        {
            try
            {
                string Url = Request.Url != null
                    ? Request.Url.ToString()
                    : null;

                using (var ServicioError = new ErrorService())
                {
                    ServicioError.RegistrarError(
                        Origen,
                        Metodo,
                        Excepcion,
                        UsuarioSistema,
                        Url
                    );
                }
            }
            catch
            {

            }
        }
    }
}
