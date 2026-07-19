using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Globalization;
using System.Text;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    /// <summary>
    /// Módulo administrativo de reportes de ventas (RF-14):
    /// resumen por período, productos más vendidos y exportación.
    /// </summary>
    public class ReporteController : Controller
    {
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
            DateTime? fechaInicio = null,
            DateTime? fechaFin = null)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            DateTime Inicio = fechaInicio ?? DateTime.Today.AddDays(-30);
            DateTime Fin = fechaFin ?? DateTime.Today;

            if (Inicio > Fin)
            {
                TempData["MensajeError"] =
                    "La fecha de inicio no puede ser posterior a la fecha de fin.";

                Inicio = Fin.AddDays(-30);
            }

            try
            {
                using (var Servicio = new PedidoAdminService())
                {
                    ReporteVentasViewModel Modelo =
                        Servicio.ConsultarReporteVentas(Inicio, Fin);

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ReporteController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible generar el reporte de ventas.";

                return View(new ReporteVentasViewModel
                {
                    FechaInicio = Inicio,
                    FechaFin = Fin
                });
            }
        }

        /// <summary>
        /// RF-14, escenario 3: exportación del reporte en un
        /// archivo CSV descargable con los datos del período.
        /// </summary>
        [HttpGet]
        public ActionResult Exportar(
            DateTime fechaInicio,
            DateTime fechaFin)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new PedidoAdminService())
                {
                    ReporteVentasViewModel Modelo =
                        Servicio.ConsultarReporteVentas(fechaInicio, fechaFin);

                    CultureInfo Cultura = CultureInfo.InvariantCulture;
                    StringBuilder Csv = new StringBuilder();

                    Csv.AppendLine("Reporte de ventas LEN");
                    Csv.AppendLine(
                        "Periodo;" +
                        fechaInicio.ToString("yyyy-MM-dd") + ";" +
                        fechaFin.ToString("yyyy-MM-dd")
                    );
                    Csv.AppendLine();

                    Csv.AppendLine("Resumen");
                    Csv.AppendLine("Total ventas;Cantidad pedidos;Productos vendidos");
                    Csv.AppendLine(
                        Modelo.Resumen.TotalVentas.ToString("0.00", Cultura) + ";" +
                        Modelo.Resumen.CantidadPedidos + ";" +
                        Modelo.Resumen.ProductosVendidos
                    );
                    Csv.AppendLine();

                    Csv.AppendLine("Ventas por dia");
                    Csv.AppendLine("Fecha;Cantidad pedidos;Total ventas");

                    foreach (VentaPorDiaViewModel Dia in Modelo.VentasPorDia)
                    {
                        Csv.AppendLine(
                            Dia.Fecha.ToString("yyyy-MM-dd") + ";" +
                            Dia.CantidadPedidos + ";" +
                            Dia.TotalVentas.ToString("0.00", Cultura)
                        );
                    }

                    Csv.AppendLine();
                    Csv.AppendLine("Productos mas vendidos");
                    Csv.AppendLine("Producto;Categoria;Unidades vendidas;Total vendido");

                    foreach (ProductoMasVendidoViewModel Producto in Modelo.ProductosMasVendidos)
                    {
                        Csv.AppendLine(
                            Producto.NombreProducto.Replace(";", ",") + ";" +
                            Producto.NombreCategoria.Replace(";", ",") + ";" +
                            Producto.UnidadesVendidas + ";" +
                            Producto.TotalVendido.ToString("0.00", Cultura)
                        );
                    }

                    string NombreArchivo =
                        "ReporteVentas_" +
                        fechaInicio.ToString("yyyyMMdd") + "_" +
                        fechaFin.ToString("yyyyMMdd") + ".csv";

                    /* BOM UTF-8 + contenido, para que Excel muestre
                       correctamente tildes y símbolos */
                    byte[] Bom = Encoding.UTF8.GetPreamble();
                    byte[] Cuerpo = Encoding.UTF8.GetBytes(Csv.ToString());
                    byte[] Contenido = new byte[Bom.Length + Cuerpo.Length];

                    Buffer.BlockCopy(Bom, 0, Contenido, 0, Bom.Length);
                    Buffer.BlockCopy(Cuerpo, 0, Contenido, Bom.Length, Cuerpo.Length);

                    return File(Contenido, "text/csv", NombreArchivo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ReporteController", "Exportar", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible exportar el reporte.";

                return RedirectToAction("Index", new { fechaInicio, fechaFin });
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
