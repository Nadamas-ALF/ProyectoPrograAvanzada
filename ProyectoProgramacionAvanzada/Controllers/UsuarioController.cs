using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class UsuarioController : Controller
    {
        [HttpGet]
        public ActionResult Detalle(int? IdUsuario)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            int IdUsuarioConsulta = IdUsuario
                ?? Convert.ToInt32(Session["IdUsuario"]);

            using (var Servicio = new UsuarioService())
            {
                UsuarioModel Modelo =
                    Servicio.ConsultarUsuarioPorId(IdUsuarioConsulta);

                if (Modelo == null)
                {
                    return HttpNotFound();
                }

                CargarDatosVista(
                    Servicio,
                    IdUsuarioConsulta,
                    Modelo.IdRol,
                    Modelo.IdEstado
                );

                return View(Modelo);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarUsuario(UsuarioModel Modelo)
        {
            ModelState.Remove("Contrasenna");
            ModelState.Remove("ConfirmarContrasenna");
            ModelState.Remove("NombreRol");
            ModelState.Remove("NombreEstado");

            if (!ModelState.IsValid)
            {
                using (var Servicio = new UsuarioService())
                {
                    CargarDatosVista(
                        Servicio,
                        Modelo.IdUsuario,
                        Modelo.IdRol,
                        Modelo.IdEstado
                    );
                }

                return View("Detalle", Modelo);
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.ActualizarUsuario(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "ActualizarUsuario",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible actualizar el usuario.";
            }

            return RedirectToAction(
                "Detalle",
                new { IdUsuario = Modelo.IdUsuario }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RestablecerContrasenna(
            UsuarioModel Modelo)
        {
            ModelState.Clear();

            if (string.IsNullOrWhiteSpace(Modelo.Contrasenna))
            {
                TempData["MensajeError"] =
                    "La nueva contraseña es obligatoria.";

                return RedirectToAction(
                    "Detalle",
                    new { IdUsuario = Modelo.IdUsuario }
                );
            }

            if (Modelo.Contrasenna.Length < 8)
            {
                TempData["MensajeError"] =
                    "La contraseña debe tener al menos 8 caracteres.";

                return RedirectToAction(
                    "Detalle",
                    new { IdUsuario = Modelo.IdUsuario }
                );
            }

            if (Modelo.Contrasenna != Modelo.ConfirmarContrasenna)
            {
                TempData["MensajeError"] =
                    "Las contraseñas no coinciden.";

                return RedirectToAction(
                    "Detalle",
                    new { IdUsuario = Modelo.IdUsuario }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.RestablecerContrasenna(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "RestablecerContrasenna",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible restablecer la contraseña.";
            }

            return RedirectToAction(
                "Detalle",
                new { IdUsuario = Modelo.IdUsuario }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AgregarDireccion(DireccionModel Modelo)
        {
            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    "Revise los datos de la dirección.";

                return RedirectToAction(
                    "Detalle",
                    new { IdUsuario = Modelo.IdUsuario }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.InsertarDireccion(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "AgregarDireccion",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible agregar la dirección.";
            }

            return RedirectToAction(
                "Detalle",
                new { IdUsuario = Modelo.IdUsuario }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarDireccion(
            DireccionModel Modelo)
        {
            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    "Revise los datos de la dirección.";

                return RedirectToAction(
                    "Detalle",
                    new { IdUsuario = Modelo.IdUsuario }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.ActualizarDireccion(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "ActualizarDireccion",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible actualizar la dirección.";
            }

            return RedirectToAction(
                "Detalle",
                new { IdUsuario = Modelo.IdUsuario }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DesactivarDireccion(
            int IdDireccion,
            int IdUsuario)
        {
            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.DesactivarDireccion(
                            IdDireccion,
                            IdUsuario
                        );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "DesactivarDireccion",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible desactivar la dirección.";
            }

            return RedirectToAction(
                "Detalle",
                new { IdUsuario }
            );
        }

        [HttpGet]
        public JsonResult ConsultarCantones(int IdProvincia)
        {
            using (var Servicio = new UsuarioService())
            {
                var Cantones =
                    Servicio.ConsultarCantonesPorProvincia(IdProvincia);

                return Json(
                    Cantones,
                    JsonRequestBehavior.AllowGet
                );
            }
        }

        [HttpGet]
        public JsonResult ConsultarDistritos(int IdCanton)
        {
            using (var Servicio = new UsuarioService())
            {
                var Distritos =
                    Servicio.ConsultarDistritosPorCanton(IdCanton);

                return Json(
                    Distritos,
                    JsonRequestBehavior.AllowGet
                );
            }
        }

        private void CargarDatosVista(
            UsuarioService Servicio,
            int IdUsuario,
            int IdRol,
            int IdEstado)
        {
            ViewBag.Direcciones =
                Servicio.ConsultarDirecciones(IdUsuario);

            ViewBag.Roles = new SelectList(
                Servicio.ConsultarRoles(),
                "Value",
                "Text",
                IdRol
            );

            ViewBag.Estados = new SelectList(
                Servicio.ConsultarEstados(),
                "Value",
                "Text",
                IdEstado
            );

            ViewBag.Provincias = new SelectList(
                Servicio.ConsultarProvincias(),
                "Value",
                "Text"
            );
        }

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion)
        {
            try
            {
                string UsuarioSistema =
                    Convert.ToString(Session["NombreUsuario"]);

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