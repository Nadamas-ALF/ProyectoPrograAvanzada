using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    /// <summary>
    /// Módulo administrativo de pedidos (RF-13):
    /// listado, detalle, cambio de estado y cancelación.
    /// </summary>
    public class PedidoAdminController : Controller
    {
        private const int TamanoPagina = 10;

        private bool EsAdministrador()
        {
            return Session["IdUsuario"] != null
                && string.Equals(
                       Session["NombreRol"] as string,
                       "Administrador",
                       StringComparison.OrdinalIgnoreCase
                   );
        }

        [HttpGet]
        public ActionResult Index(
            string busqueda = null,
            int? idEstado = null,
            DateTime? fechaInicio = null,
            DateTime? fechaFin = null,
            int pagina = 1)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new PedidoAdminService())
                {
                    ListadoPedidosAdminViewModel Modelo =
                        Servicio.ConsultarPedidos(
                            busqueda,
                            idEstado,
                            fechaInicio,
                            fechaFin,
                            pagina,
                            TamanoPagina
                        );

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("PedidoAdminController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el listado de pedidos.";

                return View(new ListadoPedidosAdminViewModel
                {
                    PaginaActual = 1,
                    TamanoPagina = TamanoPagina
                });
            }
        }

        [HttpGet]
        public ActionResult Detalle(int id)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new PedidoAdminService())
                {
                    DetallePedidoAdminViewModel Modelo =
                        Servicio.ConsultarDetalle(id);

                    if (Modelo == null)
                    {
                        TempData["MensajeError"] =
                            "No se encontró el pedido solicitado.";

                        return RedirectToAction("Index");
                    }

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("PedidoAdminController", "Detalle", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el detalle del pedido.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarEstado(
            int id,
            int idEstadoNuevo,
            string motivoCancelacion = null)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new PedidoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.ActualizarEstadoPedido(
                            id,
                            idEstadoNuevo,
                            motivoCancelacion
                        );

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }

                    return RedirectToAction("Detalle", new { id });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("PedidoAdminController", "ActualizarEstado", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al actualizar el estado del pedido.";

                return RedirectToAction("Detalle", new { id });
            }
        }

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion)
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
                        Session["NombreUsuario"] as string,
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
