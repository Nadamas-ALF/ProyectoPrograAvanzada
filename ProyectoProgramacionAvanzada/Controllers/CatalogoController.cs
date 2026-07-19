using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class CatalogoController : Controller
    {
        private const int TamanoPagina = 12;

        [HttpGet]
        public ActionResult Index(
            string busqueda = null,
            int? idCategoria = null,
            string color = null,
            int pagina = 1)
        {
            try
            {
                using (var Servicio = new CatalogoService())
                {
                    CatalogoViewModel Modelo = Servicio.ConsultarCatalogo(
                        busqueda,
                        idCategoria,
                        color,
                        ObtenerIdUsuarioActual(),
                        pagina,
                        TamanoPagina
                    );

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("CatalogoController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el catálogo de productos.";

                return View(new CatalogoViewModel
                {
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
                using (var Servicio = new CatalogoService())
                {
                    ProductoDetalleViewModel Producto =
                        Servicio.ConsultarProductoPorId(id, ObtenerIdUsuarioActual());

                    if (Producto == null)
                    {
                        TempData["MensajeError"] =
                            "El producto no existe o ya no está disponible.";

                        return RedirectToAction("Index");
                    }

                    return View(Producto);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("CatalogoController", "Detalle", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el detalle del producto.";

                return RedirectToAction("Index");
            }
        }

        private int? ObtenerIdUsuarioActual()
        {
            if (Session["IdUsuario"] == null)
            {
                return null;
            }

            return Convert.ToInt32(Session["IdUsuario"]);
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
