using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class PedidoController : Controller
    {
        private const int TamanoPagina = 5;

        [HttpGet]
        public ActionResult Historial(int pagina = 1)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new PedidoService())
                {
                    HistorialViewModel Modelo =
                        Servicio.ConsultarHistorial(
                            IdUsuario,
                            pagina,
                            TamanoPagina
                        );

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "PedidoController",
                    "Historial",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar el historial de pedidos.";

                return View(new HistorialViewModel
                {
                    PaginaActual = 1,
                    TamanoPagina = TamanoPagina
                });
            }
        }

        [HttpGet]
        public ActionResult Detalle(int id)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new PedidoService())
                {
                    DetallePedidoViewModel Modelo =
                        Servicio.ConsultarDetalle(id, IdUsuario);

                    if (Modelo == null)
                    {
                        TempData["MensajeError"] =
                            "No se encontró el pedido solicitado.";

                        return RedirectToAction("Historial");
                    }

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "PedidoController",
                    "Detalle",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar el detalle del pedido.";

                return RedirectToAction("Historial");
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
