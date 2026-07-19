using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class UsuarioController : Controller
    {
        // =====================================================
        // ADMINISTRACIÓN DE USUARIOS
        // =====================================================

        [HttpGet]
        public ActionResult Administracion()
        {
            if (!UsuarioEsAdministrador())
            {
                return RedireccionAccesoNoAutorizado();
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    CargarCatalogosAdministracion(Servicio);

                    List<UsuarioModel> Usuarios =
                        Servicio.ConsultarUsuarios();

                    return View(
                        "Administracion",
                        Usuarios
                    );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "Administracion",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible consultar los usuarios.";

                /*
                 * Los catálogos deben volver a cargarse porque
                 * la vista contiene los modales de agregar y editar.
                 */
                try
                {
                    using (var Servicio = new UsuarioService())
                    {
                        CargarCatalogosAdministracion(Servicio);
                    }
                }
                catch
                {
                }

                return View(
                    "Administracion",
                    new List<UsuarioModel>()
                );
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AgregarUsuario(
            UsuarioModel Modelo)
        {
            if (!UsuarioEsAdministrador())
            {
                return RedireccionAccesoNoAutorizado();
            }

            PrepararModelStateAgregarUsuario();

            ValidarUsuarioAdministracion(
                Modelo,
                true
            );

            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    ObtenerPrimerErrorModelo();

                TempData["AbrirModalAgregarUsuario"] =
                    true;

                return RedirectToAction(
                    "Administracion"
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio
                            .RegistrarUsuarioAdministracion(
                                Modelo
                            );
                }
            }
            catch (InvalidOperationException Excepcion)
            {
                TempData["MensajeError"] =
                    Excepcion.Message;

                TempData["AbrirModalAgregarUsuario"] =
                    true;
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "AgregarUsuario",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible registrar el usuario.";

                TempData["AbrirModalAgregarUsuario"] =
                    true;
            }

            return RedirectToAction(
                "Administracion"
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditarUsuario(
            UsuarioModel Modelo)
        {
            if (!UsuarioEsAdministrador())
            {
                return RedireccionAccesoNoAutorizado();
            }

            PrepararModelStateEditarUsuario();

            ValidarUsuarioAdministracion(
                Modelo,
                false
            );

            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    ObtenerPrimerErrorModelo();

                return RedirectToAction(
                    "Administracion"
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.ActualizarUsuario(
                            Modelo
                        );
                }
            }
            catch (InvalidOperationException Excepcion)
            {
                TempData["MensajeError"] =
                    Excepcion.Message;
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "EditarUsuario",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible actualizar el usuario.";
            }

            return RedirectToAction(
                "Administracion"
            );
        }

        // =====================================================
        // DETALLE Y ACTUALIZACIÓN DEL USUARIO
        // =====================================================

        [HttpGet]
        public ActionResult Detalle(
            int? IdUsuario)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            int IdUsuarioSesion =
                Convert.ToInt32(
                    Session["IdUsuario"]
                );

            int IdUsuarioConsulta =
                IdUsuario ?? IdUsuarioSesion;

            /*
             * Un usuario normal solamente puede consultar
             * su propio perfil.
             */
            if (!UsuarioEsAdministrador()
                && IdUsuarioConsulta != IdUsuarioSesion)
            {
                TempData["MensajeError"] =
                    "No tiene permisos para consultar ese usuario.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = IdUsuarioSesion
                    }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    UsuarioModel Modelo =
                        Servicio.ConsultarUsuarioPorId(
                            IdUsuarioConsulta
                        );

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

                    return View(
                        "Detalle",
                        Modelo
                    );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "Detalle",
                    Excepcion
                );

                TempData["MensajeError"] =
                    "No fue posible consultar el usuario.";

                return RedirectToAction(
                    "Principal",
                    "Home"
                );
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarUsuario(
            UsuarioModel Modelo)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            int IdUsuarioSesion =
                Convert.ToInt32(
                    Session["IdUsuario"]
                );

            if (!UsuarioEsAdministrador()
                && Modelo.IdUsuario != IdUsuarioSesion)
            {
                TempData["MensajeError"] =
                    "No tiene permisos para modificar ese usuario.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = IdUsuarioSesion
                    }
                );
            }

            ModelState.Remove("Contrasenna");
            ModelState.Remove("ConfirmarContrasenna");
            ModelState.Remove("NombreRol");
            ModelState.Remove("NombreEstado");
            ModelState.Remove("FechaRegistro");

            /*
             * Un usuario normal no puede cambiar
             * su propio rol ni su estado.
             */
            if (!UsuarioEsAdministrador())
            {
                try
                {
                    using (var Servicio = new UsuarioService())
                    {
                        UsuarioModel UsuarioActual =
                            Servicio.ConsultarUsuarioPorId(
                                IdUsuarioSesion
                            );

                        if (UsuarioActual == null)
                        {
                            TempData["MensajeError"] =
                                "No fue posible consultar el usuario.";

                            return RedirectToAction(
                                "Principal",
                                "Home"
                            );
                        }

                        Modelo.IdRol =
                            UsuarioActual.IdRol;

                        Modelo.IdEstado =
                            UsuarioActual.IdEstado;
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
                        "No fue posible consultar los datos actuales.";

                    return RedirectToAction(
                        "Detalle",
                        new
                        {
                            IdUsuario = IdUsuarioSesion
                        }
                    );
                }
            }

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

                return View(
                    "Detalle",
                    Modelo
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.ActualizarUsuario(
                            Modelo
                        );
                }

                if (Modelo.IdUsuario == IdUsuarioSesion)
                {
                    Session["NombreUsuario"] =
                        Modelo.Nombre + " " +
                        Modelo.Apellido;
                }
            }
            catch (InvalidOperationException Excepcion)
            {
                TempData["MensajeError"] =
                    Excepcion.Message;
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
                new
                {
                    IdUsuario = Modelo.IdUsuario
                }
            );
        }

        // =====================================================
        // CONTRASEÑA
        // =====================================================

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RestablecerContrasenna(
            UsuarioModel Modelo)
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            int IdUsuarioSesion =
                Convert.ToInt32(
                    Session["IdUsuario"]
                );

            if (!UsuarioEsAdministrador()
                && Modelo.IdUsuario != IdUsuarioSesion)
            {
                TempData["MensajeError"] =
                    "No tiene permisos para modificar esa contraseña.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = IdUsuarioSesion
                    }
                );
            }

            ModelState.Clear();

            if (string.IsNullOrWhiteSpace(
                Modelo.Contrasenna
            ))
            {
                TempData["MensajeError"] =
                    "La nueva contraseña es obligatoria.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = Modelo.IdUsuario
                    }
                );
            }

            if (Modelo.Contrasenna.Length < 8)
            {
                TempData["MensajeError"] =
                    "La contraseña debe tener al menos 8 caracteres.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = Modelo.IdUsuario
                    }
                );
            }

            if (Modelo.Contrasenna !=
                Modelo.ConfirmarContrasenna)
            {
                TempData["MensajeError"] =
                    "Las contraseñas no coinciden.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = Modelo.IdUsuario
                    }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.RestablecerContrasenna(
                            Modelo
                        );
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
                new
                {
                    IdUsuario = Modelo.IdUsuario
                }
            );
        }

        // =====================================================
        // DIRECCIONES
        // =====================================================

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AgregarDireccion(
            DireccionModel Modelo)
        {
            if (!PuedeModificarUsuario(
                Modelo.IdUsuario
            ))
            {
                return RedireccionAccesoNoAutorizado();
            }

            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    "Revise los datos de la dirección.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = Modelo.IdUsuario
                    }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.InsertarDireccion(
                            Modelo
                        );
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
                new
                {
                    IdUsuario = Modelo.IdUsuario
                }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ActualizarDireccion(
            DireccionModel Modelo)
        {
            if (!PuedeModificarUsuario(
                Modelo.IdUsuario
            ))
            {
                return RedireccionAccesoNoAutorizado();
            }

            if (!ModelState.IsValid)
            {
                TempData["MensajeError"] =
                    "Revise los datos de la dirección.";

                return RedirectToAction(
                    "Detalle",
                    new
                    {
                        IdUsuario = Modelo.IdUsuario
                    }
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    TempData["MensajeExito"] =
                        Servicio.ActualizarDireccion(
                            Modelo
                        );
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
                new
                {
                    IdUsuario = Modelo.IdUsuario
                }
            );
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DesactivarDireccion(
            int IdDireccion,
            int IdUsuario)
        {
            if (!PuedeModificarUsuario(
                IdUsuario
            ))
            {
                return RedireccionAccesoNoAutorizado();
            }

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
                new
                {
                    IdUsuario
                }
            );
        }

        // =====================================================
        // CATÁLOGOS JSON
        // =====================================================

        [HttpGet]
        public JsonResult ConsultarCantones(
            int IdProvincia)
        {
            if (Session["IdUsuario"] == null)
            {
                return Json(
                    new
                    {
                        Exitoso = false,
                        Mensaje = "La sesión ha expirado."
                    },
                    JsonRequestBehavior.AllowGet
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    object Cantones =
                        Servicio
                            .ConsultarCantonesPorProvincia(
                                IdProvincia
                            );

                    return Json(
                        Cantones,
                        JsonRequestBehavior.AllowGet
                    );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "ConsultarCantones",
                    Excepcion
                );

                return Json(
                    new
                    {
                        Exitoso = false,
                        Mensaje = "No fue posible consultar los cantones."
                    },
                    JsonRequestBehavior.AllowGet
                );
            }
        }

        [HttpGet]
        public JsonResult ConsultarDistritos(
            int IdCanton)
        {
            if (Session["IdUsuario"] == null)
            {
                return Json(
                    new
                    {
                        Exitoso = false,
                        Mensaje = "La sesión ha expirado."
                    },
                    JsonRequestBehavior.AllowGet
                );
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    object Distritos =
                        Servicio
                            .ConsultarDistritosPorCanton(
                                IdCanton
                            );

                    return Json(
                        Distritos,
                        JsonRequestBehavior.AllowGet
                    );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "UsuarioController",
                    "ConsultarDistritos",
                    Excepcion
                );

                return Json(
                    new
                    {
                        Exitoso = false,
                        Mensaje = "No fue posible consultar los distritos."
                    },
                    JsonRequestBehavior.AllowGet
                );
            }
        }

        // =====================================================
        // MÉTODOS PRIVADOS DE VALIDACIÓN
        // =====================================================

        private bool UsuarioEsAdministrador()
        {
            if (Session["IdUsuario"] == null)
            {
                return false;
            }

            string NombreRol =
                Convert.ToString(
                    Session["NombreRol"]
                );

            return string.Equals(
                NombreRol,
                "Administrador",
                StringComparison.OrdinalIgnoreCase
            );
        }

        private bool PuedeModificarUsuario(
            int IdUsuario)
        {
            if (Session["IdUsuario"] == null)
            {
                return false;
            }

            if (UsuarioEsAdministrador())
            {
                return true;
            }

            int IdUsuarioSesion =
                Convert.ToInt32(
                    Session["IdUsuario"]
                );

            return IdUsuario ==
                   IdUsuarioSesion;
        }

        private ActionResult RedireccionAccesoNoAutorizado()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            TempData["MensajeError"] =
                "No tiene permisos para realizar esta operación.";

            return RedirectToAction(
                "Principal",
                "Home"
            );
        }

        private void PrepararModelStateAgregarUsuario()
        {
            ModelState.Remove("IdUsuario");
            ModelState.Remove("NombreRol");
            ModelState.Remove("NombreEstado");
            ModelState.Remove("FechaRegistro");
        }

        private void PrepararModelStateEditarUsuario()
        {
            ModelState.Remove("Contrasenna");
            ModelState.Remove("ConfirmarContrasenna");
            ModelState.Remove("NombreRol");
            ModelState.Remove("NombreEstado");
            ModelState.Remove("FechaRegistro");
        }

        private void ValidarUsuarioAdministracion(
            UsuarioModel Modelo,
            bool ValidarContrasenna)
        {
            if (Modelo == null)
            {
                ModelState.AddModelError(
                    string.Empty,
                    "Los datos del usuario no son válidos."
                );

                return;
            }

            if (Modelo.IdRol <= 0)
            {
                ModelState.AddModelError(
                    "IdRol",
                    "Debe seleccionar un rol."
                );
            }

            if (Modelo.IdEstado <= 0)
            {
                ModelState.AddModelError(
                    "IdEstado",
                    "Debe seleccionar un estado."
                );
            }

            if (!ValidarContrasenna)
            {
                if (Modelo.IdUsuario <= 0)
                {
                    ModelState.AddModelError(
                        "IdUsuario",
                        "El usuario seleccionado no es válido."
                    );
                }

                return;
            }

            if (string.IsNullOrWhiteSpace(
                Modelo.Contrasenna
            ))
            {
                ModelState.AddModelError(
                    "Contrasenna",
                    "La contraseña es obligatoria."
                );
            }
            else if (Modelo.Contrasenna.Length < 8)
            {
                ModelState.AddModelError(
                    "Contrasenna",
                    "La contraseña debe tener al menos 8 caracteres."
                );
            }

            if (Modelo.Contrasenna !=
                Modelo.ConfirmarContrasenna)
            {
                ModelState.AddModelError(
                    "ConfirmarContrasenna",
                    "Las contraseñas no coinciden."
                );
            }
        }

        private string ObtenerPrimerErrorModelo()
        {
            foreach (
                ModelState EstadoCampo
                in ModelState.Values)
            {
                foreach (
                    ModelError Error
                    in EstadoCampo.Errors)
                {
                    if (!string.IsNullOrWhiteSpace(
                        Error.ErrorMessage
                    ))
                    {
                        return Error.ErrorMessage;
                    }

                    if (Error.Exception != null)
                    {
                        return
                            "Uno de los datos ingresados no es válido.";
                    }
                }
            }

            return "Revise los datos ingresados.";
        }

        // =====================================================
        // CARGA DE DATOS PARA LAS VISTAS
        // =====================================================

        private void CargarCatalogosAdministracion(
            UsuarioService Servicio)
        {
            ViewBag.Roles = new SelectList(
                Servicio.ConsultarRoles(),
                "Value",
                "Text"
            );

            ViewBag.Estados = new SelectList(
                Servicio.ConsultarEstados(),
                "Value",
                "Text"
            );
        }

        private void CargarDatosVista(
            UsuarioService Servicio,
            int IdUsuario,
            int IdRol,
            int IdEstado)
        {
            ViewBag.Direcciones =
                Servicio.ConsultarDirecciones(
                    IdUsuario
                );

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

        // =====================================================
        // REGISTRO DE ERRORES
        // =====================================================

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion)
        {
            try
            {
                string UsuarioSistema =
                    Convert.ToString(
                        Session["NombreUsuario"]
                    );

                string Url =
                    Request.Url != null
                        ? Request.Url.ToString()
                        : null;

                using (var ServicioError =
                    new ErrorService())
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