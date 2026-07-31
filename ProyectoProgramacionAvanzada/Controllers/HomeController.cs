using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {

            var Modelo = new PortadaViewModel();

            try
            {
                using (var Servicio = new CatalogoService())
                {
                    int? IdUsuario = Session["IdUsuario"] as int?;

                    Modelo.Catalogo = Servicio.ConsultarCatalogo(
                        null,
                        null,
                        null,
                        IdUsuario,
                        1,
                        10
                    );
                }

                using (var ServicioPortada = new PortadaService())
                {
                    Modelo.Destacados =
                        ServicioPortada.ConsultarDestacados(4);
                }


                if (Modelo.Destacados.Count == 0)
                {
                    Modelo.Destacados = Modelo.Catalogo.Productos
                        .Where(Producto => Producto.Disponible)
                        .Take(4)
                        .Select(Producto => new ProductoDestacadoViewModel
                        {
                            IdProducto = Producto.IdProducto,
                            NombreProducto = Producto.NombreProducto,
                            Precio = Producto.Precio,
                            RutaImagen = Producto.RutaImagen,
                            NombreCategoria = Producto.NombreCategoria
                        })
                        .ToList();
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "HomeController",
                    "Index",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );
            }

            return View(Modelo);
        }


        [HttpGet]
        public ActionResult Login()
        {
            if (Session["IdUsuario"] != null)
            {
                return RedirigirSegunRol();
            }

            return View(new InicioSesionModel());
        }



        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(InicioSesionModel Modelo)
        {
            if (!ModelState.IsValid)
            {
                return View(Modelo);
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    SP_ConsultarUsuarioInicioSesion_Result Usuario =
                        Servicio.ValidarCredenciales(Modelo);

                    if (Usuario == null)
                    {
                        ModelState.AddModelError(
                            string.Empty,
                            "El correo o la contraseña son incorrectos, o el usuario no está activo."
                        );

                        return View(Modelo);
                    }

                    Session["IdUsuario"] = Usuario.IdUsuario;
                    Session["NombreUsuario"] =
                        Usuario.Nombre + " " + Usuario.Apellido;
                    Session["IdRol"] = Usuario.IdRol;
                    Session["NombreRol"] = Usuario.NombreRol;
                    Session["IdEstado"] = Usuario.IdEstado;
                    Session["NombreEstado"] = Usuario.NombreEstado;


                    return RedirigirSegunRol();
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "HomeController",
                    "Login",
                    Excepcion,
                    Modelo.Email
                );

                ModelState.AddModelError(
                    string.Empty,
                    "Ocurrió un error al procesar el inicio de sesión. Intente nuevamente."
                );

                return View(Modelo);
            }
        }



        [HttpGet]
        public ActionResult Principal()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction(
                    "Login",
                    "Home"
                );
            }

            try
            {
                using (var Servicio = new DashboardService())
                {
                    DashboardViewModel Modelo =
                        Servicio.ConsultarDashboard();

                    return View(
                        "Principal",
                        Modelo
                    );
                }
            }
            catch (Exception Excepcion)
            {
                try
                {
                    using (var ServicioError =
                        new ErrorService())
                    {
                        ServicioError.RegistrarError(
                            "HomeController",
                            "Principal",
                            Excepcion,
                            Convert.ToString(
                                Session["NombreUsuario"]
                            ),
                            Request.Url != null
                                ? Request.Url.ToString()
                                : null
                        );
                    }
                }
                catch
                {
                }

                TempData["MensajeError"] =
                    "No fue posible cargar el panel principal.";

                return View(
                    "Principal",
                    new DashboardViewModel()
                );
            }
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CerrarSesion()
        {
            Session.Clear();
            Session.Abandon();

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public ActionResult Registro()
        {
            if (Session["IdUsuario"] != null)
            {
                return RedirigirSegunRol();
            }

            return View(new UsuarioModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registro(UsuarioModel Modelo)
        {
            ModelState.Remove("IdRol");
            ModelState.Remove("IdEstado");
            ModelState.Remove("FechaRegistro");
            ModelState.Remove("NombreRol");
            ModelState.Remove("NombreEstado");

            if (string.IsNullOrWhiteSpace(Modelo.Contrasenna))
            {
                ModelState.AddModelError(
                    "Contrasenna",
                    "La contraseña es obligatoria."
                );
            }

            if (string.IsNullOrWhiteSpace(Modelo.ConfirmarContrasenna))
            {
                ModelState.AddModelError(
                    "ConfirmarContrasenna",
                    "Debe confirmar la contraseña."
                );
            }

            if (!string.IsNullOrWhiteSpace(Modelo.Contrasenna) &&
                Modelo.Contrasenna.Length < 8)
            {
                ModelState.AddModelError(
                    "Contrasenna",
                    "La contraseña debe tener al menos 8 caracteres."
                );
            }

            if (!string.Equals(
                Modelo.Contrasenna,
                Modelo.ConfirmarContrasenna,
                StringComparison.Ordinal))
            {
                ModelState.AddModelError(
                    "ConfirmarContrasenna",
                    "Las contraseñas no coinciden."
                );
            }

            if (!ModelState.IsValid)
            {
                return View(Modelo);
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    string Mensaje =
                        Servicio.RegistrarUsuario(Modelo);

                    TempData["MensajeExito"] = Mensaje;
                }

                return RedirectToAction("Login");
            }
            catch (InvalidOperationException Excepcion)
            {
                ModelState.AddModelError(
                    string.Empty,
                    Excepcion.Message
                );

                return View(Modelo);
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "HomeController",
                    "Registro",
                    Excepcion,
                    Modelo.Email
                );

                ModelState.AddModelError(
                    string.Empty,
                    "No fue posible crear la cuenta. Intente nuevamente."
                );

                return View(Modelo);
            }
        }


        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }



        [HttpGet]
        public ActionResult ForgotPassword()
        {
            if (Session["IdUsuario"] != null)
            {
                return RedirigirSegunRol();
            }

            return View(new UsuarioModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ForgotPassword(UsuarioModel Modelo)
        {
            ModelState.Clear();

            if (string.IsNullOrWhiteSpace(Modelo.Email))
            {
                ModelState.AddModelError(
                    "Email",
                    "El correo electrónico es obligatorio."
                );

                return View(Modelo);
            }

            if (!new System.ComponentModel.DataAnnotations
                .EmailAddressAttribute()
                .IsValid(Modelo.Email))
            {
                ModelState.AddModelError(
                    "Email",
                    "Ingrese un correo electrónico válido."
                );

                return View(Modelo);
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    SP_ConsultarUsuarioRecuperacion_Result Usuario =
                        Servicio.ConsultarUsuarioRecuperacion(
                            Modelo.Email
                        );

 
                    if (Usuario != null)
                    {
                        string ContrasennaTemporal =
                            Servicio.GenerarContrasennaTemporal();

                        int VigenciaMinutos = int.Parse(
                            System.Configuration
                                .ConfigurationManager
                                .AppSettings["VigenciaMinutos"]
                        );

                        DateTime Vigencia =
                            DateTime.Now.AddMinutes(
                                VigenciaMinutos
                            );

                        Servicio.ActualizarContrasennaTemporal(
                            Usuario.IdUsuario,
                            ContrasennaTemporal,
                            Vigencia
                        );

                        string RutaHtml = System.IO.Path.Combine(
                            AppDomain.CurrentDomain.BaseDirectory,
                            "Content",
                            "Correos",
                            "RecuperacionContrasenna.html"
                        );

                        string Contenido =
                            System.IO.File.ReadAllText(
                                RutaHtml
                            );

                        Contenido = Contenido.Replace(
                            "{{NOMBRE}}",
                            Usuario.Nombre
                        );

                        Contenido = Contenido.Replace(
                            "{{PASSWORD}}",
                            ContrasennaTemporal
                        );

                        Contenido = Contenido.Replace(
                            "{{MINUTOS}}",
                            VigenciaMinutos.ToString()
                        );

                        Contenido = Contenido.Replace(
                            "{{ANNO}}",
                            DateTime.Now.Year.ToString()
                        );

                        var ServicioCorreo =
                            new CorreoService();

                        ServicioCorreo.EnviarCorreo(
                            Usuario.Email,
                            "Recuperación de acceso - LEN",
                            Contenido
                        );
                    }
                }

                TempData["MensajeExito"] =
                    "Si el correo está asociado a una cuenta activa, " +
                    "recibirás las instrucciones de recuperación.";

                return RedirectToAction("Login");
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "HomeController",
                    "ForgotPassword",
                    Excepcion,
                    Modelo.Email
                );

                ModelState.AddModelError(
                    string.Empty,
                    "No fue posible procesar la recuperación. " +
                    "Intente nuevamente."
                );

                return View(Modelo);
            }
        }


        private bool EsAdministrador()
        {
            return string.Equals(
                Session["NombreRol"] as string,
                "Administrador",
                StringComparison.OrdinalIgnoreCase
            );
        }

        private ActionResult RedirigirSegunRol()
        {
            if (EsAdministrador())
            {
                return RedirectToAction("Principal", "Home");
            }

            return RedirectToAction("Index", "Home");
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