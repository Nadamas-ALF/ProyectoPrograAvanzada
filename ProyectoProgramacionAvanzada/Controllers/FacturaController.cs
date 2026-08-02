using ProyectoProgramacionAvanzada.Filtros;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{

    [SoloAdministrador]
    public class FacturaController : Controller
    {
        private const int TamanoPagina = 10;

        [HttpGet]
        public ActionResult Index(
            string busqueda = null,
            DateTime? fechaInicio = null,
            DateTime? fechaFin = null,
            int pagina = 1)
        {
            if (fechaInicio.HasValue
                && fechaFin.HasValue
                && fechaInicio > fechaFin)
            {
                TempData["MensajeError"] =
                    "La fecha de inicio no puede ser posterior a la fecha de fin.";

                fechaInicio = null;
                fechaFin = null;
            }

            try
            {
                using (var Servicio = new FacturaAdminService())
                {
                    ListadoFacturasViewModel Modelo =
                        Servicio.ConsultarFacturas(
                            busqueda,
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
                RegistrarError("FacturaController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el listado de facturas.";

                return View(new ListadoFacturasViewModel
                {
                    Busqueda = busqueda,
                    FechaInicio = fechaInicio,
                    FechaFin = fechaFin,
                    PaginaActual = 1,
                    TamanoPagina = TamanoPagina
                });
            }
        }

        [HttpGet]
        public ActionResult Detalle(int id)
        {
            try
            {
                using (var Servicio = new FacturaAdminService())
                {
                    DetalleFacturaViewModel Modelo =
                        Servicio.ConsultarDetalle(id);

                    if (Modelo == null)
                    {
                        TempData["MensajeError"] =
                            "La factura solicitada no existe.";

                        return RedirectToAction("Index");
                    }

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("FacturaController", "Detalle", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el detalle de la factura.";

                return RedirectToAction("Index");
            }
        }

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion)
        {
            try
            {
                using (var ServicioError = new ErrorService())
                {
                    ServicioError.RegistrarError(
                        Origen,
                        Metodo,
                        Excepcion,
                        Session["NombreUsuario"] as string,
                        Request.Url != null
                            ? Request.Url.ToString()
                            : null
                    );
                }
            }
            catch
            {
            }
        }
    }
}
