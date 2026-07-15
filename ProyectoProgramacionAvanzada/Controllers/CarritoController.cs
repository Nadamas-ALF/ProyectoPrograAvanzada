using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class CarritoController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

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
            if (Session["IdUsuario"] == null)
            {
                return JsonRequiereLogin();
            }

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
            if (Session["IdUsuario"] == null)
            {
                return JsonRequiereLogin();
            }

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
            if (Session["IdUsuario"] == null)
            {
                return JsonRequiereLogin();
            }

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

        private JsonResult JsonRequiereLogin()
        {
            return Json(new
            {
                exitoso = false,
                requiereLogin = true,
                mensaje = "Debe iniciar sesión para usar el carrito.",
                urlLogin = Url.Action("Login", "Home")
            });
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
