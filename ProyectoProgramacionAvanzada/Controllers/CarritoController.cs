using ProyectoProgramacionAvanzada.Filtros;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    [SesionRequerida]
    public class CarritoController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new CarritoService())
                {
                    CarritoViewModel Carrito =
                        Servicio.ConsultarCarrito(IdUsuario);

                    return View(Carrito);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CarritoController",
                    "Index",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar el carrito. Intente nuevamente.";

                return View(new CarritoViewModel());
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Agregar(int IdProducto, int Cantidad)
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new CarritoService())
                {
                    var Resultado = Servicio.AgregarProducto(
                        IdUsuario,
                        IdProducto,
                        Cantidad
                    );

                    return Json(new
                    {
                        exitoso = Resultado.Exitoso == true,
                        mensaje = Resultado.Mensaje,
                        cantidadItems = Resultado.CantidadItems
                    });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CarritoController",
                    "Agregar",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                return JsonErrorGenerico();
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ActualizarCantidad(int IdProducto, int Cantidad)
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new CarritoService())
                {
                    var Resultado = Servicio.ActualizarCantidad(
                        IdUsuario,
                        IdProducto,
                        Cantidad
                    );

                    return Json(new
                    {
                        exitoso = Resultado.Exitoso == true,
                        mensaje = Resultado.Mensaje
                    });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CarritoController",
                    "ActualizarCantidad",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                return JsonErrorGenerico();
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Eliminar(int IdProducto)
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new CarritoService())
                {
                    var Resultado = Servicio.EliminarProducto(
                        IdUsuario,
                        IdProducto
                    );

                    return Json(new
                    {
                        exitoso = Resultado.Exitoso == true,
                        mensaje = Resultado.Mensaje
                    });
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CarritoController",
                    "Eliminar",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                return JsonErrorGenerico();
            }
        }

 
        [ChildActionOnly]
        public ActionResult ContadorParcial()
        {
            if (Session["IdUsuario"] == null)
            {
                return PartialView("_ContadorCarrito", 0);
            }

            try
            {
                int IdUsuario = (int)Session["IdUsuario"];

                using (var Servicio = new CarritoService())
                {
                    int CantidadItems =
                        Servicio.ConsultarCarrito(IdUsuario).CantidadItems;

                    return PartialView("_ContadorCarrito", CantidadItems);
                }
            }
            catch
            {
                return PartialView("_ContadorCarrito", 0);
            }
        }

        private JsonResult JsonErrorGenerico()
        {
            return Json(new
            {
                exitoso = false,
                mensaje = "Ocurrió un error al procesar la solicitud. Intente nuevamente."
            });
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
