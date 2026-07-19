using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    /// <summary>
    /// Módulo administrativo de categorías del catálogo (apoyo a RF-11).
    /// </summary>
    public class CategoriaController : Controller
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
        public ActionResult Index()
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                using (var Servicio = new CategoriaAdminService())
                {
                    return View(Servicio.ConsultarCategorias());
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError("CategoriaController", "Index", Excepcion);

                TempData["MensajeError"] =
                    "No fue posible cargar el listado de categorías.";

                return View(new System.Collections.Generic.List<CategoriaAdminViewModel>());
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Crear(CategoriaFormViewModel Categoria)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                if (!ModelState.IsValid)
                {
                    TempData["MensajeError"] =
                        "El nombre de la categoría es obligatorio (máximo 100 caracteres).";

                    return RedirectToAction("Index");
                }

                using (var Servicio = new CategoriaAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.InsertarCategoria(Categoria);

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
                RegistrarError("CategoriaController", "Crear", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al crear la categoría.";

                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Editar(CategoriaFormViewModel Categoria)
        {
            if (!EsAdministrador())
            {
                return RedirectToAction("Login", "Home");
            }

            try
            {
                if (!ModelState.IsValid)
                {
                    TempData["MensajeError"] =
                        "El nombre de la categoría es obligatorio (máximo 100 caracteres).";

                    return RedirectToAction("Index");
                }

                using (var Servicio = new CategoriaAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.ActualizarCategoria(Categoria);

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
                RegistrarError("CategoriaController", "Editar", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al actualizar la categoría.";

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
                using (var Servicio = new CategoriaAdminService())
                {
                    OperacionAdminResult Resultado =
                        Servicio.CambiarEstadoCategoria(id);

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
                RegistrarError("CategoriaController", "CambiarEstado", Excepcion);

                TempData["MensajeError"] =
                    "Ocurrió un error al cambiar el estado de la categoría.";

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
