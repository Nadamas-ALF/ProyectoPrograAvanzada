using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class PagoController : Controller
    {
        [HttpGet]
        public ActionResult AdministracionPagos()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            string NombreRol =
                Convert.ToString(
                    Session["NombreRol"]
                );

            if (!string.Equals(
                NombreRol,
                "Administrador",
                StringComparison.OrdinalIgnoreCase))
            {
                TempData["MensajeError"] =
                    "No tiene permisos para consultar los pagos.";

                return RedirectToAction(
                    "Principal",
                    "Home"
                );
            }

            try
            {
                using (var Servicio = new PagoService())
                {
                    PagoViewModel Modelo =
                        Servicio.ConsultarPagos();

                    return View(
                        "AdministracionPagos",
                        Modelo
                    );
                }
            }
            catch (Exception Excepcion)
            {
                try
                {
                    using (var ServicioError =
                        new ErrorService())
                    {
                        ServicioError.RegistrarError(
                            "PagoController",
                            "AdministracionPagos",
                            Excepcion,
                            Convert.ToString(
                                Session["NombreUsuario"]
                            ),
                            Request.Url != null
                                ? Request.Url.ToString()
                                : null
                        );
                    }
                }
                catch
                {
                }

                TempData["MensajeError"] =
                    "No fue posible consultar los pagos.";

                return View(
                    "AdministracionPagos",
                    new PagoViewModel()
                );
            }
        }
    }
}