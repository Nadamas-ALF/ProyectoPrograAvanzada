using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class FavoritoController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                int IdUsuario = Convert.ToInt32(Session["IdUsuario"]);

                using (var Servicio = new FavoritoService())
                {
                    List<FavoritoViewModel> Favoritos =
                        Servicio.ConsultarFavoritos(IdUsuario);

                    return View(Favoritos);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("FavoritoController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar sus favoritos.";

                return View(new List<FavoritoViewModel>());
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Agregar(int idProducto, string urlRetorno)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                int IdUsuario = Convert.ToInt32(Session["IdUsuario"]);

                using (var Servicio = new FavoritoService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.AgregarFavorito(IdUsuario, idProducto);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("FavoritoController", "Agregar", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al agregar el producto a favoritos.";
            }

            return RedirigirDeVuelta(urlRetorno, idProducto);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(int idProducto, string urlRetorno)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                int IdUsuario = Convert.ToInt32(Session["IdUsuario"]);

                using (var Servicio = new FavoritoService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.EliminarFavorito(IdUsuario, idProducto);

                    if (Resultado.Exitoso)
                    {
                        TempData["MensajeExito"] = Resultado.Mensaje;
                    }
                    else
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;
                    }
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("FavoritoController", "Eliminar", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al retirar el producto de favoritos.";
            }

            return RedirigirDeVuelta(urlRetorno, idProducto);
        }

        private ActionResult RedirigirDeVuelta(string urlRetorno, int idProducto)
        {
            if (!string.IsNullOrWhiteSpace(urlRetorno) && Url.IsLocalUrl(urlRetorno))
            {
                return Redirect(urlRetorno);
            }

            return RedirectToAction("Detalle", "Catalogo", new { id = idProducto });
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
