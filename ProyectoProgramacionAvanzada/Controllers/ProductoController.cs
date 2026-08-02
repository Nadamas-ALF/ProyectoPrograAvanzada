using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    /// <summary>
    /// Módulo administrativo de productos.
    /// RF-11: gestión de productos e imágenes.
    /// RF-12: gestión de inventario.
    /// </summary>
    public class ProductoController : Controller
    {
        private const int TamanoPagina = 10;


        private const int TamanoMaximoImagenMbPredeterminado = 2;

        private static readonly string[] ExtensionesPermitidas =
            { ".jpg", ".jpeg", ".png", ".webp" };

        private static int ObtenerTamanoMaximoImagenMb()
        {
            string Valor = ConfigurationManager
                .AppSettings["TamanoMaximoImagenMB"];

            int Megas;

            if (!string.IsNullOrWhiteSpace(Valor)
                && int.TryParse(
                       Valor,
                       NumberStyles.Integer,
                       CultureInfo.InvariantCulture,
                       out Megas)
                && Megas > 0)
            {
                return Megas;
            }

            return TamanoMaximoImagenMbPredeterminado;
        }

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
            int? idCategoria = null,
            int pagina = 1)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    ListadoProductosViewModel Modelo =
                        Servicio.ConsultarProductos(
                            busqueda,
                            idCategoria,
                            pagina,
                            TamanoPagina
                        );

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el listado de productos.";

                return View(new ListadoProductosViewModel
                {
                    PaginaActual = 1,
                    TamanoPagina = TamanoPagina
                });
            }
        }

        [HttpGet]
        public ActionResult Crear()
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    return View(new ProductoFormViewModel
                    {
                        Categorias = Servicio.ConsultarCategoriasActivas()
                    });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Crear", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el formulario de producto.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Crear(ProductoFormViewModel Producto)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    if (!ModelState.IsValid)
                    {
                        Producto.Categorias =
                            Servicio.ConsultarCategoriasActivas();

                        return View(Producto);
                    }

                    OperacionAdminResult Resultado =
                        Servicio.InsertarProducto(Producto);

                    if (!Resultado.Exitoso)
                    {
                        ModelState.AddModelError(string.Empty, Resultado.Mensaje);

                        Producto.Categorias =
                            Servicio.ConsultarCategoriasActivas();

                        return View(Producto);
                    }

                    TempData["MensajeExito"] = Resultado.Mensaje;

                    if (Resultado.IdGenerado.HasValue)
                    {
                        return RedirectToAction(
                            "Imagenes",
                            new { id = Resultado.IdGenerado.Value }
                        );
                    }

                    return RedirectToAction("Index");
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Crear", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al crear el producto.";

                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        public ActionResult Editar(int id)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    ProductoFormViewModel Producto =
                        Servicio.ConsultarProductoPorId(id);

                    if (Producto == null)
                    {
                        TempData["MensajeError"] =
                            "No se encontró el producto solicitado.";

                        return RedirectToAction("Index");
                    }

                    return View(Producto);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Editar", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el producto.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Editar(ProductoFormViewModel Producto)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    if (!ModelState.IsValid)
                    {
                        Producto.Categorias =
                            Servicio.ConsultarCategoriasActivas();

                        return View(Producto);
                    }

                    OperacionAdminResult Resultado =
                        Servicio.ActualizarProducto(Producto);

                    if (!Resultado.Exitoso)
                    {
                        ModelState.AddModelError(string.Empty, Resultado.Mensaje);

                        Producto.Categorias =
                            Servicio.ConsultarCategoriasActivas();

                        return View(Producto);
                    }

                    TempData["MensajeExito"] = Resultado.Mensaje;

                    return RedirectToAction("Index");
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Editar", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al actualizar el producto.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CambiarEstado(int id)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.CambiarEstadoProducto(id);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }

                    return RedirectToAction("Index");
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "CambiarEstado", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al cambiar el estado del producto.";

                return RedirectToAction("Index");
            }
        }

        /* ================= RF-12: INVENTARIO ================= */

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarStock(int id, int stock)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.ActualizarStock(id, stock);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }

                    return RedirectToAction("Index");
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "ActualizarStock", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al actualizar el inventario.";

                return RedirectToAction("Index");
            }
        }

        /* ================= IMÁGENES (RF-11) ================= */

        [HttpGet]
        public ActionResult Imagenes(int id)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    ProductoFormViewModel Producto =
                        Servicio.ConsultarProductoPorId(id);

                    if (Producto == null)
                    {
                        TempData["MensajeError"] =
                            "No se encontró el producto solicitado.";

                        return RedirectToAction("Index");
                    }

                    return View(new ImagenesProductoViewModel
                    {
                        IdProducto = id,
                        NombreProducto = Producto.NombreProducto,
                        Imagenes = Servicio.ConsultarImagenes(id)
                    });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "Imagenes", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar las imágenes del producto.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SubirImagen(int id, HttpPostedFileBase archivo)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                if (archivo == null || archivo.ContentLength == 0)
                {
                    TempData["MensajeError"] =
                        "Debe seleccionar un archivo de imagen.";

                    return RedirectToAction("Imagenes", new { id });
                }

                string Extension = Path
                    .GetExtension(archivo.FileName)
                    .ToLowerInvariant();

                if (!ExtensionesPermitidas.Contains(Extension))
                {
                    TempData["MensajeError"] =
                        "Solo se permiten imágenes JPG, PNG o WEBP.";

                    return RedirectToAction("Imagenes", new { id });
                }

                int TamanoMaximoMb = ObtenerTamanoMaximoImagenMb();

                if (archivo.ContentLength > TamanoMaximoMb * 1024 * 1024)
                {
                    /* El mensaje se arma con el límite real configurado. */
                    TempData["MensajeError"] =
                        "La imagen no puede superar los "
                        + TamanoMaximoMb
                        + " MB.";

                    return RedirectToAction("Imagenes", new { id });
                }

                string CarpetaFisica =
                    Server.MapPath("~/Content/Images/Productos");

                if (!Directory.Exists(CarpetaFisica))
                {
                    Directory.CreateDirectory(CarpetaFisica);
                }

                /*
                 * La imagen se normaliza a un lienzo cuadrado
                 * (1:1) antes de guardarla: las vistas la muestran
                 * con object-fit: cover dentro de contenedores
                 * cuadrados y cualquier otra proporción se veía
                 * recortada. Se escala completa y se centra, sin
                 * recortar nada. El resultado siempre es .jpg.
                 */
                string NombreArchivo =
                    Guid.NewGuid().ToString("N") + ".jpg";

                ImagenProductoService.GuardarNormalizada(
                    archivo.InputStream,
                    Path.Combine(CarpetaFisica, NombreArchivo)
                );

                string RutaRelativa =
                    "Content/Images/Productos/" + NombreArchivo;

                using (var Servicio = new ProductoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.InsertarImagen(id, RutaRelativa);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }
                }

                return RedirectToAction("Imagenes", new { id });
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "SubirImagen", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al subir la imagen.";

                return RedirectToAction("Imagenes", new { id });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult MarcarPrincipal(int id, int idProducto)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.MarcarImagenPrincipal(id);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }

                    return RedirectToAction("Imagenes", new { id = idProducto });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "MarcarPrincipal", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al actualizar la imagen principal.";

                return RedirectToAction("Imagenes", new { id = idProducto });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EliminarImagen(int id, int idProducto)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new ProductoAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.EliminarImagen(id);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }

                    return RedirectToAction("Imagenes", new { id = idProducto });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("ProductoController", "EliminarImagen", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al eliminar la imagen.";

                return RedirectToAction("Imagenes", new { id = idProducto });
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
